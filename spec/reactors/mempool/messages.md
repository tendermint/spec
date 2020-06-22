# Mempool Messages

## P2P Messages

There is currently only one message that Mempool broadcasts
and receives over the p2p gossip network (via the reactor):

```protobuf
message BytesValue {
  bytes Values = 1;
}
```

This is a [wellknown type](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf) from protobuf ([google.protobuf.BytesValue](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.BytesValue)).

## RPC Messages

Mempool exposes `CheckTx([]byte)` over the RPC interface.

It can be posted via `broadcast_commit`, `broadcast_sync` or
`broadcast_async`. They all parse a message with one argument,
`"tx": "HEX_ENCODED_BINARY"` and differ in only how long they
wait before returning (sync makes sure CheckTx passes, commit
makes sure it was included in a signed block).

Request (`POST http://gaia.zone:26657/`):

```json
{
  "id": "",
  "jsonrpc": "2.0",
  "method": "broadcast_sync",
  "params": {
    "tx": "F012A4BC68..."
  }
}
```

Response:

```json
{
  "error": "",
  "result": {
    "hash": "E39AAB7A537ABAA237831742DCE1117F187C3C52",
    "log": "",
    "data": "",
    "code": 0
  },
  "id": "",
  "jsonrpc": "2.0"
}
```
