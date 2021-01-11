# Mempool Messages

There is currently only one message that Mempool broadcasts and receives over
the p2p gossip network (via the reactor): `TxsMessage`

```go
// TxsMessage is a MempoolMessage containing a list of transactions.
type TxsMessage struct {
    Txs []types.Tx
}
```
