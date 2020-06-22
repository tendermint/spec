# Pex Messages

As you have read earlier [here](./pex.md) the job the Pex reactor is to handle peer exchange. The Pex reactor consists of two distinct messages.

## PexRequest Message

When a node is requesting peers from a node they will indicate this by sending a `PexRequest` message.

```protobuf
message PexRequest {}
```

## PexAddrs Message

When a node has received a request for peers it will respond with a slice of addresses.

```protobuf
message PexAddrs {
  repeated NetAddress addrs = 1;
}
```

The messages supported by the Pex reactor are wrapped in a `oneof`.

```protobuf
message Message {
  oneof sum {
    PexRequest pex_request = 1;
    PexAddrs   pex_addrs   = 2;
  }
}
```
