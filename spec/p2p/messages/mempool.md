---
order: 4
---
# Mempool 

## Channel

| Name            | Number |
|-----------------|--------|
| MempoolChannel | 48     |

## Message Types

There is currently only one message that Mempool broadcasts and receives over
the p2p gossip network (via the reactor): `TxsMessage`

### Txs 

| Name | Type           | Description          | Field Number |
|------|----------------|----------------------|--------------|
| txs  | repeated bytes | List of transactions | 1            |


### Message

Message is a [`oneof` protobuf type](https://developers.google.com/protocol-buffers/docs/proto#oneof). The one of consists of one message [`Txs`](#txs).

| Name | Type        | Description           | Field Number |
|------|-------------|-----------------------|--------------|
| txs  | [Txs](#txs) | Array of transactions | 1            |
