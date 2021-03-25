# RPC spec

This file defines the JSON-RPC spec of Tendermint. This is meant to be implemented by all clients.

## Support

  |              | Tendermint-Go | Tendermint-Rs |
  |--------------|:-------------:|:-------------:|
  | JSON-RPC 2.0 |       ✅       |       ✅       |
  | HTTP         |       ✅       |       ✅       |
  | HTTPS         |       ✅       |       ❌       |
  | WS           |       ✅       |       ❌       |
  | WSS           |       ✅       |       ❌       |
  
  | Routes                                    | Tendermint-Go | Tendermint-Rs |
  |-------------------------------------------|:-------------:|:-------------:|
  | [Health](#health)                         |       ✅       |       ✅       |
  | [Status](#status)                         |       ✅       |       ✅       |
  | [NetInfo](#netinfo)                       |       ✅       |       ✅       |
  | [blockchain](#blockchain)                 |       ✅       |       ✅       |
  | [block](#block)                           |       ✅       |       ✅       |
  | [BlockByHash](#blockbyhash)               |       ✅       |       ❌       |
  | [BlockResults](#blockresults)             |       ✅       |       ✅       |
  | [Commit](#commit)                         |       ✅       |       ✅       |
  | [Validators](#validators)                 |       ✅       |       ✅       |
  | [Genesis](#genesis)                       |       ✅       |       ✅       |
  | [DumpConsensusState](#dumpconsensusstate) |       ✅       |       ❌       |
  | [ConsensusParams](#consensusparams)       |       ✅       |       ❌       |
  | [UnconfirmedTxs](#unconfirmedtxs)         |       ✅       |       ❌       |
  | [NumUnconfirmedTxs](#numunconfirmedtxs)   |       ✅       |       ❌       |
  | [TxSearch](#txsearch)                     |       ✅       |       ✅       |
  | [BlockSearch](#blocksearch)               |       ✅       |       ❌       |
  | [Tx](#tx)                                 |       ✅       |       ❌       |
  | [BroadCastTxSync](#broadcasttxsync)       |       ✅       |       ✅       |
  | [BroadCastTxAsync](#broadcasttxasync)     |       ✅       |       ✅       |
  | [BroadCastTxCommit](#broadcasttxcommit)   |       ✅       |       ✅       |
  | [BroadcastEvidence](#broadcastevidence)   |       ✅       |       ✅       |
  | [DialSeeds](#dialseeds)                   |       ✅       |       ❌       |
  | [DialPeers](#dialpeers)                   |       ✅       |       ❌       |

## Info Routes

### Health

```
curl http://127.0.0.1:26657/health
```

```json
{
  "jsonrpc": "2.0",
  "id": -1,
  "result": {}
}
```

### Status

```
curl http://127.0.0.1:26657/status
```

```json
{
  "jsonrpc": "2.0",
  "id": -1,
  "result": {
    "node_info": {
      "protocol_version": {
        "p2p": "8",
        "block": "11",
        "app": "0"
      },
      "id": "b93270b358a72a2db30089f3856475bb1f918d6d",
      "listen_addr": "tcp://0.0.0.0:26656",
      "network": "cosmoshub-4",
      "version": "v0.34.8",
      "channels": "40202122233038606100",
      "moniker": "aib-hub-node",
      "other": {
        "tx_index": "on",
        "rpc_address": "tcp://0.0.0.0:26657"
      }
    },
    "sync_info": {
      "latest_block_hash": "50F03C0EAACA8BCA7F9C14189ACE9C05A9A1BBB5268DB63DC6A3C848D1ECFD27",
      "latest_app_hash": "2316CFF7644219F4F15BEE456435F280E2B38955EEA6D4617CCB6D7ABF781C22",
      "latest_block_height": "5622165",
      "latest_block_time": "2021-03-25T14:00:43.356134226Z",
      "earliest_block_hash": "1455A0C15AC49BB506992EC85A3CD4D32367E53A087689815E01A524231C3ADF",
      "earliest_app_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
      "earliest_block_height": "5200791",
      "earliest_block_time": "2019-12-11T16:11:34Z",
      "catching_up": false
    },
    "validator_info": {
      "address": "38FB765D0092470989360ECA1C89CD06C2C1583C",
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": "Z+8kntVegi1sQiWLYwFSVLNWqdAUGEy7lskL78gxLZI="
      },
      "voting_power": "0"
    }
  }
}
```

### NetInfo

### Blockchain

### Block

### BlockByHash

### BlockResults

### Commit

### Validators

### Genesis

### DumpConsensusState

### ConsensusParams

### UnconfirmedTxs

### NumUnconfirmedTxs

### TxSearch

### BlockSearch

### Tx

## Transaction Routes

### BroadCastTxSync

### BroadCastTxAsync

### BroadCastTxCommit

## ABCI Routes

### ABCIInfo

### ABCIQuery

## Evidence Routes

### BroadcastEvidence

## Unsafe Routes

### DialSeeds

### DialPeers
