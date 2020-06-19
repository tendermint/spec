# Block Sync Messages

The Blockchain reactor has 5 distinct messages and one `oneof` message that groups all the messages. They are defined in Protocol Buffers because this is the encoding format we use throughout the clients.

`BlockRequest` requests a block for a specific height.

```protobuf
message BlockRequest {
  int64 height = 1;
}
```

`NoBlockResponse` informs the node that the peer does not have block at the requested height.

```protobuf
message NoBlockResponse {
  int64 height = 1;
}
```

`BlockResponse` returns the requested block.

```protobuf
message BlockResponse {
  tendermint.types.Block block = 1;
}
```

`StatusRequest` requests the status of a node (Height & Base).

- `Height` requests the current height of a peer
- `Base`  requests the lowest block height a node has

```protobuf
message StatusRequest {
  int64 height = 1;
  int64 base   = 2;
}
```

`StatusResponse` is a peer response to inform their status

- `Height` provides the peer with the nodes height block height
- `Base` provides the peer with the nodes lowest block height

```protobuf
message StatusResponse {
  int64 height = 1;
  int64 base   = 2;
}
```

`Message` wraps all the blockchain reactor messages in a `oneof`. A message that is sent from the blockchain reactor will always be encoded in a `oneof`

```protobuf
message Message {
  oneof sum {
    BlockRequest    block_request     = 1;
    NoBlockResponse no_block_response = 2;
    BlockResponse   block_response    = 3;
    StatusRequest   status_request    = 4;
    StatusResponse  status_response   = 5;
  }
}
```

The protobuf file with these messages are located [here](./msgs.proto)
