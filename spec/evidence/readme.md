# Evidence

Evidence is broadcasted throughout an entire network on its own channel. The reason for evidence having its own channel is so when a validator misbehaves the information can be included in a block as fast as possible. To see what sort of evidences are supported by Tendermint, please see the [data structures section](../blockchain/blockchain.md#evidence).

## Channel

Tendermint implements a multiplexed connection, you can read more about this [here](../p2p/connection.md#mconnection), meaning that communication between nodes for specific protocols happens on separate channels. The channel that Evidence uses is `56` or `0x38`.

```go
EvidenceChannel = byte(0x38)
```

## Messages

Evidence has one message type `List`. 

`List` is an array of various types of evidence.

```go
type List struct {
  Evidence []types.Evidence
}
```
