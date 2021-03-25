# RPC spec

This file defines the JSON-RPC spec of Tendermint. This is meant to be implemented by all clients.

## Support

  |              | Tendermint-Go | Tendermint-Rs |
  |--------------|:-------------:|:-------------:|
  | JSON-RPC 2.0 |       ✅       |       ✅       |
  | HTTP         |       ✅       |       ✅       |
  | HTTPS        |       ✅       |       ❌       |
  | WS           |       ✅       |       ✅       |
  
  | Routes                                    | Tendermint-Go | Tendermint-Rs |
  |-------------------------------------------|:-------------:|:-------------:|
  | [Subscribe](#subscribe)                   |       ✅       |       ✅       |
  | [Unsubscribe](#unsubscribe)               |       ✅       |       ✅       |
  | [UnsubscribeAll](#unsubscribeall)         |       ✅       |       ❌       |
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

## Info Routes

### Health

```sh
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

```sh
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

```sh
curl http://127.0.0.1:26657/net_info
```

```json
    Example Value
    Schema

{
  "id": 0,
  "jsonrpc": "2.0",
  "result": {
    "listening": true,
    "listeners": [
      "Listener(@)"
    ],
    "n_peers": "1",
    "peers": [
      {
        "node_info": {
          "protocol_version": {
            "p2p": "7",
            "block": "10",
            "app": "0"
          },
          "id": "5576458aef205977e18fd50b274e9b5d9014525a",
          "listen_addr": "tcp://0.0.0.0:26656",
          "network": "cosmoshub-2",
          "version": "0.32.1",
          "channels": "4020212223303800",
          "moniker": "moniker-node",
          "other": {
            "tx_index": "on",
            "rpc_address": "tcp://0.0.0.0:26657"
          }
        },
        "is_outbound": true,
        "connection_status": {
          "Duration": "168901057956119",
          "SendMonitor": {
            "Active": true,
            "Start": "2019-07-31T14:31:28.66Z",
            "Duration": "168901060000000",
            "Idle": "168901040000000",
            "Bytes": "5",
            "Samples": "1",
            "InstRate": "0",
            "CurRate": "0",
            "AvgRate": "0",
            "PeakRate": "0",
            "BytesRem": "0",
            "TimeRem": "0",
            "Progress": 0
          },
          "RecvMonitor": {
            "Active": true,
            "Start": "2019-07-31T14:31:28.66Z",
            "Duration": "168901060000000",
            "Idle": "168901040000000",
            "Bytes": "5",
            "Samples": "1",
            "InstRate": "0",
            "CurRate": "0",
            "AvgRate": "0",
            "PeakRate": "0",
            "BytesRem": "0",
            "TimeRem": "0",
            "Progress": 0
          },
          "Channels": [
            {
              "ID": 48,
              "SendQueueCapacity": "1",
              "SendQueueSize": "0",
              "Priority": "5",
              "RecentlySent": "0"
            }
          ]
        },
        "remote_ip": "95.179.155.35"
      }
    ]
  }
}
```

### Blockchain

```sh
curl http://127.0.0.1:26657/blockchain
```

#### Parameters

- Minimum height `integer`
- Maximum height `integer`

example:

```sh
curl http://127.0.0.1:26657/blockchain?minHeight=1&maxHeight=2
```

```json
{
  "id": 0,
  "jsonrpc": "2.0",
  "result": {
    "last_height": "1276718",
    "block_metas": [
      {
        "block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "block_size": 1000000,
        "header": {
          "version": {
            "block": "10",
            "app": "0"
          },
          "chain_id": "cosmoshub-2",
          "height": "12",
          "time": "2019-04-22T17:01:51.701356223Z",
          "last_block_id": {
            "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
            "parts": {
              "total": 1,
              "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
            }
          },
          "last_commit_hash": "21B9BC845AD2CB2C4193CDD17BFC506F1EBE5A7402E84AD96E64171287A34812",
          "data_hash": "970886F99E77ED0D60DA8FCE0447C2676E59F2F77302B0C4AA10E1D02F18EF73",
          "validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
          "next_validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
          "consensus_hash": "0F2908883A105C793B74495EB7D6DF2EEA479ED7FC9349206A65CB0F9987A0B8",
          "app_hash": "223BF64D4A01074DC523A80E76B9BBC786C791FB0A1893AC5B14866356FCFD6C",
          "last_results_hash": "",
          "evidence_hash": "",
          "proposer_address": "D540AB022088612AC74B287D076DBFBC4A377A2E"
        },
        "num_txs": "54"
      }
    ]
  }
}
```

### Block

```sh
curl http://127.0.0.1:26657/block
```

#### Parameters

- Height `integer`

example:

```sh
curl http://127.0.0.1:26657/block?height=1
```

```json
{
  "id": 0,
  "jsonrpc": "2.0",
  "result": {
    "block_id": {
      "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
      "parts": {
        "total": 1,
        "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
      }
    },
    "block": {
      "header": {
        "version": {
          "block": "10",
          "app": "0"
        },
        "chain_id": "cosmoshub-2",
        "height": "12",
        "time": "2019-04-22T17:01:51.701356223Z",
        "last_block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "last_commit_hash": "21B9BC845AD2CB2C4193CDD17BFC506F1EBE5A7402E84AD96E64171287A34812",
        "data_hash": "970886F99E77ED0D60DA8FCE0447C2676E59F2F77302B0C4AA10E1D02F18EF73",
        "validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "next_validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "consensus_hash": "0F2908883A105C793B74495EB7D6DF2EEA479ED7FC9349206A65CB0F9987A0B8",
        "app_hash": "223BF64D4A01074DC523A80E76B9BBC786C791FB0A1893AC5B14866356FCFD6C",
        "last_results_hash": "",
        "evidence_hash": "",
        "proposer_address": "D540AB022088612AC74B287D076DBFBC4A377A2E"
      },
      "data": [
        "yQHwYl3uCkKoo2GaChRnd+THLQ2RM87nEZrE19910Z28ABIUWW/t8AtIMwcyU0sT32RcMDI9GF0aEAoFdWF0b20SBzEwMDAwMDASEwoNCgV1YXRvbRIEMzEwMRCd8gEaagom61rphyEDoJPxlcjRoNDtZ9xMdvs+lRzFaHe2dl2P5R2yVCWrsHISQKkqX5H1zXAIJuC57yw0Yb03Fwy75VRip0ZBtLiYsUqkOsPUoQZAhDNP+6LY+RUwz/nVzedkF0S29NZ32QXdGv0="
      ],
      "evidence": [
        {
          "type": "string",
          "height": 0,
          "time": 0,
          "total_voting_power": 0,
          "validator": {
            "pub_key": {
              "type": "tendermint/PubKeyEd25519",
              "value": "A6DoBUypNtUAyEHWtQ9bFjfNg8Bo9CrnkUGl6k6OHN4="
            },
            "voting_power": 0,
            "address": "string"
          }
        }
      ],
      "last_commit": {
        "height": 0,
        "round": 0,
        "block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "signatures": [
          {
            "type": 2,
            "height": "1262085",
            "round": 0,
            "block_id": {
              "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
              "parts": {
                "total": 1,
                "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
              }
            },
            "timestamp": "2019-08-01T11:39:38.867269833Z",
            "validator_address": "000001E443FD237E4B616E2FA69DF4EE3D49A94F",
            "validator_index": 0,
            "signature": "DBchvucTzAUEJnGYpNvMdqLhBAHG4Px8BsOBB3J3mAFCLGeuG7uJqy+nVngKzZdPhPi8RhmE/xcw/M9DOJjEDg=="
          }
        ]
      }
    }
  }
}
```

### BlockByHash

```sh
curl http://127.0.0.1:26657/block_by_hash
```

#### Parameters

- Block hash `string`

example:

```sh
curl http://127.0.0.1:26657/block_by_hash?hash=0xD70952032620CC4E2737EB8AC379806359D8E0B17B0488F627997A0B043ABDED
```

```json
{
  "id": 0,
  "jsonrpc": "2.0",
  "result": {
    "block_id": {
      "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
      "parts": {
        "total": 1,
        "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
      }
    },
    "block": {
      "header": {
        "version": {
          "block": "10",
          "app": "0"
        },
        "chain_id": "cosmoshub-2",
        "height": "12",
        "time": "2019-04-22T17:01:51.701356223Z",
        "last_block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "last_commit_hash": "21B9BC845AD2CB2C4193CDD17BFC506F1EBE5A7402E84AD96E64171287A34812",
        "data_hash": "970886F99E77ED0D60DA8FCE0447C2676E59F2F77302B0C4AA10E1D02F18EF73",
        "validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "next_validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "consensus_hash": "0F2908883A105C793B74495EB7D6DF2EEA479ED7FC9349206A65CB0F9987A0B8",
        "app_hash": "223BF64D4A01074DC523A80E76B9BBC786C791FB0A1893AC5B14866356FCFD6C",
        "last_results_hash": "",
        "evidence_hash": "",
        "proposer_address": "D540AB022088612AC74B287D076DBFBC4A377A2E"
      },
      "data": [
        "yQHwYl3uCkKoo2GaChRnd+THLQ2RM87nEZrE19910Z28ABIUWW/t8AtIMwcyU0sT32RcMDI9GF0aEAoFdWF0b20SBzEwMDAwMDASEwoNCgV1YXRvbRIEMzEwMRCd8gEaagom61rphyEDoJPxlcjRoNDtZ9xMdvs+lRzFaHe2dl2P5R2yVCWrsHISQKkqX5H1zXAIJuC57yw0Yb03Fwy75VRip0ZBtLiYsUqkOsPUoQZAhDNP+6LY+RUwz/nVzedkF0S29NZ32QXdGv0="
      ],
      "evidence": [
        {
          "type": "string",
          "height": 0,
          "time": 0,
          "total_voting_power": 0,
          "validator": {
            "pub_key": {
              "type": "tendermint/PubKeyEd25519",
              "value": "A6DoBUypNtUAyEHWtQ9bFjfNg8Bo9CrnkUGl6k6OHN4="
            },
            "voting_power": 0,
            "address": "string"
          }
        }
      ],
      "last_commit": {
        "height": 0,
        "round": 0,
        "block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "signatures": [
          {
            "type": 2,
            "height": "1262085",
            "round": 0,
            "block_id": {
              "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
              "parts": {
                "total": 1,
                "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
              }
            },
            "timestamp": "2019-08-01T11:39:38.867269833Z",
            "validator_address": "000001E443FD237E4B616E2FA69DF4EE3D49A94F",
            "validator_index": 0,
            "signature": "DBchvucTzAUEJnGYpNvMdqLhBAHG4Px8BsOBB3J3mAFCLGeuG7uJqy+nVngKzZdPhPi8RhmE/xcw/M9DOJjEDg=="
          }
        ]
      }
    }
  }
}
```

### BlockResults

```sh
curl  http://127.0.0.1:26657/block_results
```

### Parameters

- Block height `integer`

```sh
curl  http://127.0.0.1:26657/block_results?height=1
```

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "height": "12",
    "txs_results": [
      {
        "code": "0",
        "data": "",
        "log": "not enough gas",
        "info": "",
        "gas_wanted": "100",
        "gas_used": "100",
        "events": [
          {
            "type": "app",
            "attributes": [
              {
                "key": "YWN0aW9u",
                "value": "c2VuZA==",
                "index": false
              }
            ]
          }
        ],
        "codespace": "ibc"
      }
    ],
    "begin_block_events": [
      {
        "type": "app",
        "attributes": [
          {
            "key": "YWN0aW9u",
            "value": "c2VuZA==",
            "index": false
          }
        ]
      }
    ],
    "end_block": [
      {
        "type": "app",
        "attributes": [
          {
            "key": "YWN0aW9u",
            "value": "c2VuZA==",
            "index": false
          }
        ]
      }
    ],
    "validator_updates": [
      {
        "pub_key": {
          "type": "tendermint/PubKeyEd25519",
          "value": "9tK9IT+FPdf2qm+5c2qaxi10sWP+3erWTKgftn2PaQM="
        },
        "power": "300"
      }
    ],
    "consensus_params_updates": {
      "block": {
        "max_bytes": "22020096",
        "max_gas": "1000",
        "time_iota_ms": "1000"
      },
      "evidence": {
        "max_age": "100000"
      },
      "validator": {
        "pub_key_types": [
          "ed25519"
        ]
      }
    }
  }
}
```

### Commit

```sh
curl  http://127.0.0.1:26657/commit
```

#### Parameters

- Block height `integer`
    - If no height is set the latest commit will be returned.

```sh
curl  http://127.0.0.1:26657/commit?height=1
```

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "signed_header": {
      "header": {
        "version": {
          "block": "10",
          "app": "0"
        },
        "chain_id": "cosmoshub-2",
        "height": "12",
        "time": "2019-04-22T17:01:51.701356223Z",
        "last_block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "last_commit_hash": "21B9BC845AD2CB2C4193CDD17BFC506F1EBE5A7402E84AD96E64171287A34812",
        "data_hash": "970886F99E77ED0D60DA8FCE0447C2676E59F2F77302B0C4AA10E1D02F18EF73",
        "validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "next_validators_hash": "D658BFD100CA8025CFD3BECFE86194322731D387286FBD26E059115FD5F2BCA0",
        "consensus_hash": "0F2908883A105C793B74495EB7D6DF2EEA479ED7FC9349206A65CB0F9987A0B8",
        "app_hash": "223BF64D4A01074DC523A80E76B9BBC786C791FB0A1893AC5B14866356FCFD6C",
        "last_results_hash": "",
        "evidence_hash": "",
        "proposer_address": "D540AB022088612AC74B287D076DBFBC4A377A2E"
      },
      "commit": {
        "height": "1311801",
        "round": 0,
        "block_id": {
          "hash": "112BC173FD838FB68EB43476816CD7B4C6661B6884A9E357B417EE957E1CF8F7",
          "parts": {
            "total": 1,
            "hash": "38D4B26B5B725C4F13571EFE022C030390E4C33C8CF6F88EDD142EA769642DBD"
          }
        },
        "signatures": [
          {
            "block_id_flag": 2,
            "validator_address": "000001E443FD237E4B616E2FA69DF4EE3D49A94F",
            "timestamp": "2019-04-22T17:01:58.376629719Z",
            "signature": "14jaTQXYRt8kbLKEhdHq7AXycrFImiLuZx50uOjs2+Zv+2i7RTG/jnObD07Jo2ubZ8xd7bNBJMqkgtkd0oQHAw=="
          }
        ]
      }
    },
    "canonical": true
  }
}
```

### Validators

```sh
curl  http://127.0.0.1:26657/validators
```

#### Parameters

- `height`: Block height `integer`
    - If no height is set the latest commit will be returned.
- `page`
- `per_page`

```sh
curl  http://127.0.0.1:26657/commit?height=1
```

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "block_height": "55",
    "validators": [
      {
        "address": "000001E443FD237E4B616E2FA69DF4EE3D49A94F",
        "pub_key": {
          "type": "tendermint/PubKeyEd25519",
          "value": "9tK9IT+FPdf2qm+5c2qaxi10sWP+3erWTKgftn2PaQM="
        },
        "voting_power": "239727",
        "proposer_priority": "-11896414"
      }
    ],
    "count": "1",
    "total": "25"
  }
}
```

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
