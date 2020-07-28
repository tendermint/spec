# Block Sync Protocol

The block sync, or as you may have seen in various documentation Fast Sync, protocol's job is to facilitate a quick way to catch up to the block chains most recent block.

## Channel

Tendermint implements a multiplexed connection, you can read more about this [here](../p2p/connection.md#mconnection), meaning that communication between nodes for specific protocols happens on separate channels. The channel the communication takes place for the block sync protocol is `64` or `0x40`.

```go
// BlockchainChannel is a channel for blocks and status updates (`BlockStore` height)
BlockchainChannel = byte(0x40)
```

## Message Types

There are five distinct message types used by the block sync protocol.

```go
const (
    TypeBlockRequest    = byte(0x10)
    TypeBlockResponse   = byte(0x11)
    TypeNoBlockResponse = byte(0x12)
    TypeStatusResponse  = byte(0x20)
    TypeStatusRequest   = byte(0x21)
)
```

A node that is missing a block will request it from a number of peers.

```go
type BlockRequest struct {
    Height int64
}
```

If the peer does not have the block requested it will respond with the height that was requested.

```go
type NoBlockResponse struct {
    Height int64
}
```

If a peer has the block that was requested, it will respond with that block.

```go
type BlockResponse struct {
    Block Block
}
```

Request the Height of a peers blockstore.

```go
type StatusRequest struct {}
```

Respond with the highest block in the nodes blockstore.

```go
type StatusResponse struct {
    Height int64
}
```
