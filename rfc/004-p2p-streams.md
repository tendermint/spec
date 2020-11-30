# RFC 004: P2P Stream Support

## Changelog

- 2020-12-01: Initial draft

## Author(s)

- Erik Grinaker (@erikgrinaker)

## Context

The Tendermint Core team is currently refactoring the P2P stack, with a planned architecture outlined in [ADR 062](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-062-p2p-architecture.md). In parallel, Informal Systems is planning to implement P2P support in Tendermint-rs, and have expressed interest in using QUIC as a transport protocol instead of the current proprietary MConnection protocol.

In order to take full advantage of QUIC streams, the proposed new P2P architecture has first-class support for network streams. Each reactor channel maps onto a separate network stream. However, the current MConnection protocol, which uses multiplexing, cannot map onto an idiomatic stream API due to a couple of impedance mismatches. This leaves three options:

1. Make two changes to the MConnection protocol to fit with an idiomatic network stream API.

2. Use a non-idiomatic network API that is message-oriented rather than byte-oriented.

3. Don't support network streams (and by extension, don't take full advantage of QUIC).

### What's Multiplexing, and What's Wrong With It?

The current Tendermint P2P transport protocol is connection-oriented. This means that when communicating with a peer over the network it uses a single TCP connection with a single IO stream. In Go, this connection has the following (reduced) interface, with similar abstractions in other languages:

```go
type Connection interface {
    // Read reads incoming bytes into the given byte slice.
    Read([]byte) (int, error)

    // Write writes outgoing bytes to the connection.
    Write([]byte) (int, error)

    // Close closes the connection.
    Close() error
}
```

The Tendermint MConnection protocol has a concept of logical channels, used to separate messages passed by different reactors for different purposes. For example, consensus vote messages are passed via channel `0x22` and mempool transaction messages are passed via channel `0x30`. These channels are [multiplexed](https://en.wikipedia.org/wiki/Multiplexing) onto a single TCP connection by fragmenting and sending data in Protobuf packet messages written to the TCP stream in a FIFO (first-in first-out) manner:

```protobuf
message PacketMsg {
  int32 channel_id = 1; // The logical channel ID
  bool  eof        = 2; // Whether this packet is the last packet of a logical message
  bytes data       = 3; // The packet payload
}
```

One weakness with multiplexing is that if e.g. the mempool reactor is slow to process transaction messages then this may delay consensus vote messages that are queued behind them. This is known as [head-of-line blocking](https://en.wikipedia.org/wiki/Head-of-line_blocking).

### What Are QUIC Streams, and Why Do We Want Them?

[QUIC](https://en.wikipedia.org/wiki/QUIC) is a transport protocol originally designed to address head-of-line blocking in HTTP. HTTP/2 supports sending HTTP requests in parallel across multiple streams multiplexed onto a single TCP connection. However, as with Tendermint channel messages, a slow request at the head of the line will delay all requests queued behind it. QUIC does away with multiplexing, and instead provides fully-independent streams that do not affect each other, forming the basis of HTTP/3.

QUIC is therefore of interest to Tendermint since it will allow e.g. consensus messages to be exchanged independently of less-important messages for other components. A Tendermint reactor channel would map directly onto a separate QUIC stream.

The idiomatic way to expose such streams in network APIs is as follows:

```go
// Connection represents a single connection or session against a peer.
type Connection interface {
    // Stream creates a new stream within the connection.
    Stream() (Stream, error)

    // Close closes the connection and all streams within it.
    Close() error
}

// Stream represents a single logical stream within a connection.
type Stream interface {
    // Read reads incoming bytes into the given byte slice.
    Read([]byte) (int, error)

    // Write writes outgoing bytes to the stream.
    Write([]byte) (int, error)

    // Close closes the stream.
    Close() error
}
```

Notice how a `Stream` has the same API as a `Connection` does in the current implementation, but we can now open many such IO streams against a single peer. This IO stream API is idiomatic in Go, and can be composed with other IO stream APIs such as buffering (via `bufio.Reader`), compression (via `gzip.Reader`), Protobuf (un)marshaling (via `protoio.Reader`), and many others. Other languages have similar streaming IO abstractions.

### What's the Problem?

The MConnection protocol is currently implemented above the transport layer. In other words, channels are multiplexed onto a single IO stream regardless of transport protocol. This means that if we were to implement QUIC in this paradigm, we would be multiplexing channels onto a _single_ QUIC stream, thereby losing out on the main benefit that QUIC offers.

The MConnection protocol should be implemented as a transport-layer protocol which multiplexes channels onto a TCP connection. This would be a parallel implementation with QUIC which maps channels onto separate QUIC streams.

However, since MConnection multiplexing currently sits above the transport layer, it has more knowledge about the high-level Tendermint P2P protocol than a transport-layer protocol should. Two aspects in particular are problematic:

* MConnection is message-oriented, and responsible for message framing via the `PacketMsg.EOF` field. This can't really be made compatible with a byte stream-oriented API (i.e. `Read([]byte)` and `Write([]byte)`), since there is no way to mark message boundaries without injecting additional binary data into the byte stream (such as length-prefixing) and allocating multiple memory buffers for the same message (since `Read` must read into a buffer that's pre-allocated by the _caller_).

* Channels are currently listed in the initial connection handshake, but the stream API dynamically opens and closes channels on an ad-hoc basis. There is also no way for the two sides to agree on which QUIC stream corresponds to which reactor channel without a channel handshake.

In order to integrate both QUIC and the current MConnection protocol with a stream-based networking API in an idiomatic way we should move multiplexing concerns into the transport layer and decouple it from the higher-level message-oriented P2P protocol.

## Proposal

The preferred option is to change the MConnection protocol to fit into an idiomatic network stream API. This requires two changes:

### Message Framing

The `PacketMsg.EOF` field should be removed, such that `PacketMsg.Data` contents make up a continuous byte stream:

```diff
  message PacketMsg {
    int32 channel_id = 1; // The logical channel ID
-   bool  eof        = 2; // Whether this packet is the last packet of a logical message
    bytes data       = 3; // The packet payload
  }
```

P2P reactor messages should instead be framed by the message sender, using length-prefixed encoding (the de-facto standard for Protobuf). This allows using e.g. a standard `protoio.Reader` and `protoio.Writer` to automate framing. An additional benefit is that the length of a message is known prior to receiving it, such that an appropriately sized buffer can be initialized immediately.

### Channel Handshakes

When a QUIC stream is opened, the two sides must agree on which reactor channel the stream corresponds to. This can be done by introducing a channel handshake to the P2P protocol, which would also allow us to send additional P2P information such as the maximum message size accepted by each side, if so desired.

At minimum, this handshake must contain:

```protobuf
message ChannelInfo {
  uint32 id = 1; // The channel ID for this stream
}
```

The channel listing in the `NodeInfo` connection handshake is then no longer necessary:

```diff
  message DefaultNodeInfo {
    ProtocolVersion      protocol_version = 1;
    string               default_node_id  = 2;
    string               listen_addr      = 3;
    string               network          = 4;
    string               version          = 5;
-   bytes                channels         = 6;
    string               moniker          = 7;
    DefaultNodeInfoOther other            = 8;
  }
```

QUIC has built-in support for stream closure, but MConnection must also communicate this across the multiplexing protocol. This can be done by adding a field to `PacketMsg`:

```diff
  message PacketMsg {
    int32 channel_id = 1; // The logical channel ID
    bytes data       = 3; // The packet payload
+   bool  close      = 4; // If true, the channel is closed after this packet
  }
```

This would also provide a natural way for reactors to announce coming online or going offline, which would be useful e.g. during node startup where we don't want consensus to run while we're fast syncing - see [#4394](https://github.com/tendermint/tendermint/issues/4394).

An alternative is to use explicit stream IDs in the API, i.e. `Connection.Stream(id uint32)`, in which case each transport must implement its own transport-layer handshake as appropriate (MConnection doesn't need one, since it already has `PacketMsg.channel_id`, but QUIC does require this).

## Alternative Solutions

If we do not wish to make any changes to the current P2P protocol at all, we have two other options:

* Use a message-oriented, non-idiomatic network transport API - e.g.:

    ```go
    type Connection interface {
        // WriteMessage writes a message for the given channel.
        WriteMessage(channelID byte, msg []byte) error

        // ReadMessage reads the next message from the given channel.
        ReadMessage(channelID byte) ([]byte, error)
    }
    ```

  Here, it is up to the transport protocol implementation how channels are represented and how messages are framed and exchanged. This means that a QUIC implementation would need a custom protocol in between the P2P protocol and QUIC itself. Also, this cannot compose with other streaming IO libraries such as `protoio`, `bufio`, and `gzip`, or similar libraries in the Rust implementation.

* Do not add support for network streams, but use a connection-oriented transport abstraction instead. This would make adopting QUIC pointless.

## Status

Proposed

## Consequences

### Positive

* Takes full advantage of both QUIC and MConnection in a common, standardized, and idiomatic manner.

* Integrates better with other streaming IO libraries such as the Go stdlib and Rust's Tokio.

* Channel handshakes with additional metadata allows differing node configurations and versions to remain compatible.

* Streaming IO can be more resource-efficient than allocating and copying large memory buffers.

* Idiomatic network APIs are more familiar to new developers.

### Negative

* This is a breaking change to the P2P protocol.

* Additional channel handshakes may increase initial connection latency when connecting to peers (although pipelining would avoid multiple roundtrip penalties).

## References

- [ADR-062: P2P Architecture and Abstractions](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-062-p2p-architecture.md)
