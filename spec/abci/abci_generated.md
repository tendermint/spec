# API Reference



# ABCIApplication


 <!-- end services -->

# Messages


## Event 
Event allows application developers to attach additional information to
ResponseBeginBlock, ResponseEndBlock, ResponseCheckTx and ResponseDeliverTx.
Later, transactions may be queried using these events.


| Field | Type | Description |
| ----- | ---- | ----------- |
| type | [ string](#string) | none |
| attributes | [repeated EventAttribute](#eventattribute) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## EventAttribute 
EventAttribute is a single key-value pair, associated with an event.


| Field | Type | Description |
| ----- | ---- | ----------- |
| key | [ string](#string) | none |
| value | [ string](#string) | none |
| index | [ bool](#bool) | nondeterministic |
 <!-- end Fields -->
 <!-- end HasFields -->


## Evidence 



| Field | Type | Description |
| ----- | ---- | ----------- |
| type | [ EvidenceType](#evidencetype) | none |
| validator | [ Validator](#validator) | The offending validator |
| height | [ int64](#int64) | The height when the offense occurred |
| time | [ google.protobuf.Timestamp](#googleprotobuftimestamp) | The corresponding time where the offense occurred |
| total_voting_power | [ int64](#int64) | Total voting power of the validator set in case the ABCI application does not store historical validators. https://github.com/tendermint/tendermint/issues/4581 |
 <!-- end Fields -->
 <!-- end HasFields -->


## LastCommitInfo 



| Field | Type | Description |
| ----- | ---- | ----------- |
| round | [ int32](#int32) | none |
| votes | [repeated VoteInfo](#voteinfo) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## Request 



| Field | Type | Description |
| ----- | ---- | ----------- |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.echo | [ RequestEcho](#requestecho) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.flush | [ RequestFlush](#requestflush) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.info | [ RequestInfo](#requestinfo) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.init_chain | [ RequestInitChain](#requestinitchain) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.query | [ RequestQuery](#requestquery) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.begin_block | [ RequestBeginBlock](#requestbeginblock) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.check_tx | [ RequestCheckTx](#requestchecktx) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.deliver_tx | [ RequestDeliverTx](#requestdelivertx) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.end_block | [ RequestEndBlock](#requestendblock) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.commit | [ RequestCommit](#requestcommit) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.list_snapshots | [ RequestListSnapshots](#requestlistsnapshots) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.offer_snapshot | [ RequestOfferSnapshot](#requestoffersnapshot) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.load_snapshot_chunk | [ RequestLoadSnapshotChunk](#requestloadsnapshotchunk) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.apply_snapshot_chunk | [ RequestApplySnapshotChunk](#requestapplysnapshotchunk) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestApplySnapshotChunk 
Applies a snapshot chunk


| Field | Type | Description |
| ----- | ---- | ----------- |
| index | [ uint32](#uint32) | none |
| chunk | [ bytes](#bytes) | none |
| sender | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestBeginBlock 



| Field | Type | Description |
| ----- | ---- | ----------- |
| hash | [ bytes](#bytes) | none |
| header | [ tendermint.types.Header](#tenderminttypesheader) | none |
| last_commit_info | [ LastCommitInfo](#lastcommitinfo) | none |
| byzantine_validators | [repeated Evidence](#evidence) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestCheckTx 



| Field | Type | Description |
| ----- | ---- | ----------- |
| tx | [ bytes](#bytes) | none |
| type | [ CheckTxType](#checktxtype) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestCommit 


 <!-- end HasFields -->


## RequestDeliverTx 



| Field | Type | Description |
| ----- | ---- | ----------- |
| tx | [ bytes](#bytes) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestEcho 



| Field | Type | Description |
| ----- | ---- | ----------- |
| message | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestEndBlock 



| Field | Type | Description |
| ----- | ---- | ----------- |
| height | [ int64](#int64) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestFlush 


 <!-- end HasFields -->


## RequestInfo 



| Field | Type | Description |
| ----- | ---- | ----------- |
| version | [ string](#string) | none |
| block_version | [ uint64](#uint64) | none |
| p2p_version | [ uint64](#uint64) | none |
| abci_version | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestInitChain 



| Field | Type | Description |
| ----- | ---- | ----------- |
| time | [ google.protobuf.Timestamp](#googleprotobuftimestamp) | none |
| chain_id | [ string](#string) | none |
| consensus_params | [ tendermint.types.ConsensusParams](#tenderminttypesconsensusparams) | none |
| validators | [repeated ValidatorUpdate](#validatorupdate) | none |
| app_state_bytes | [ bytes](#bytes) | none |
| initial_height | [ int64](#int64) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestListSnapshots 
lists available snapshots

 <!-- end HasFields -->


## RequestLoadSnapshotChunk 
loads a snapshot chunk


| Field | Type | Description |
| ----- | ---- | ----------- |
| height | [ uint64](#uint64) | none |
| format | [ uint32](#uint32) | none |
| chunk | [ uint32](#uint32) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestOfferSnapshot 
offers a snapshot to the application


| Field | Type | Description |
| ----- | ---- | ----------- |
| snapshot | [ Snapshot](#snapshot) | snapshot offered by peers |
| app_hash | [ bytes](#bytes) | light client-verified app hash for snapshot height |
 <!-- end Fields -->
 <!-- end HasFields -->


## RequestQuery 



| Field | Type | Description |
| ----- | ---- | ----------- |
| data | [ bytes](#bytes) | none |
| path | [ string](#string) | none |
| height | [ int64](#int64) | none |
| prove | [ bool](#bool) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## Response 



| Field | Type | Description |
| ----- | ---- | ----------- |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.exception | [ ResponseException](#responseexception) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.echo | [ ResponseEcho](#responseecho) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.flush | [ ResponseFlush](#responseflush) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.info | [ ResponseInfo](#responseinfo) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.init_chain | [ ResponseInitChain](#responseinitchain) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.query | [ ResponseQuery](#responsequery) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.begin_block | [ ResponseBeginBlock](#responsebeginblock) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.check_tx | [ ResponseCheckTx](#responsechecktx) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.deliver_tx | [ ResponseDeliverTx](#responsedelivertx) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.end_block | [ ResponseEndBlock](#responseendblock) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.commit | [ ResponseCommit](#responsecommit) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.list_snapshots | [ ResponseListSnapshots](#responselistsnapshots) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.offer_snapshot | [ ResponseOfferSnapshot](#responseoffersnapshot) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.load_snapshot_chunk | [ ResponseLoadSnapshotChunk](#responseloadsnapshotchunk) | none |
| [**oneof**](https://developers.google.com/protocol-buffers/docs/proto3#oneof) value.apply_snapshot_chunk | [ ResponseApplySnapshotChunk](#responseapplysnapshotchunk) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseApplySnapshotChunk 



| Field | Type | Description |
| ----- | ---- | ----------- |
| result | [ ResponseApplySnapshotChunk.Result](#responseapplysnapshotchunkresult) | none |
| refetch_chunks | [repeated uint32](#uint32) | Chunks to refetch and reapply |
| reject_senders | [repeated string](#string) | Chunk senders to reject and ban |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseBeginBlock 



| Field | Type | Description |
| ----- | ---- | ----------- |
| events | [repeated Event](#event) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseCheckTx 



| Field | Type | Description |
| ----- | ---- | ----------- |
| code | [ uint32](#uint32) | none |
| data | [ bytes](#bytes) | none |
| log | [ string](#string) | nondeterministic |
| info | [ string](#string) | nondeterministic |
| gas_wanted | [ int64](#int64) | none |
| gas_used | [ int64](#int64) | none |
| events | [repeated Event](#event) | none |
| codespace | [ string](#string) | none |
| sender | [ string](#string) | none |
| priority | [ int64](#int64) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseCommit 



| Field | Type | Description |
| ----- | ---- | ----------- |
| data | [ bytes](#bytes) | reserve 1 |
| retain_height | [ int64](#int64) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseDeliverTx 



| Field | Type | Description |
| ----- | ---- | ----------- |
| code | [ uint32](#uint32) | none |
| data | [ bytes](#bytes) | none |
| log | [ string](#string) | nondeterministic |
| info | [ string](#string) | nondeterministic |
| gas_wanted | [ int64](#int64) | none |
| gas_used | [ int64](#int64) | none |
| events | [repeated Event](#event) | nondeterministic |
| codespace | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseEcho 



| Field | Type | Description |
| ----- | ---- | ----------- |
| message | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseEndBlock 



| Field | Type | Description |
| ----- | ---- | ----------- |
| validator_updates | [repeated ValidatorUpdate](#validatorupdate) | none |
| consensus_param_updates | [ tendermint.types.ConsensusParams](#tenderminttypesconsensusparams) | none |
| events | [repeated Event](#event) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseException 
nondeterministic


| Field | Type | Description |
| ----- | ---- | ----------- |
| error | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseFlush 


 <!-- end HasFields -->


## ResponseInfo 



| Field | Type | Description |
| ----- | ---- | ----------- |
| data | [ string](#string) | none |
| version | [ string](#string) | this is the software version of the application. TODO: remove? |
| app_version | [ uint64](#uint64) | none |
| last_block_height | [ int64](#int64) | none |
| last_block_app_hash | [ bytes](#bytes) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseInitChain 



| Field | Type | Description |
| ----- | ---- | ----------- |
| consensus_params | [ tendermint.types.ConsensusParams](#tenderminttypesconsensusparams) | none |
| validators | [repeated ValidatorUpdate](#validatorupdate) | none |
| app_hash | [ bytes](#bytes) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseListSnapshots 



| Field | Type | Description |
| ----- | ---- | ----------- |
| snapshots | [repeated Snapshot](#snapshot) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseLoadSnapshotChunk 



| Field | Type | Description |
| ----- | ---- | ----------- |
| chunk | [ bytes](#bytes) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseOfferSnapshot 



| Field | Type | Description |
| ----- | ---- | ----------- |
| result | [ ResponseOfferSnapshot.Result](#responseoffersnapshotresult) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## ResponseQuery 



| Field | Type | Description |
| ----- | ---- | ----------- |
| code | [ uint32](#uint32) | none |
| log | [ string](#string) | bytes data = 2; // use "value" instead.

nondeterministic |
| info | [ string](#string) | nondeterministic |
| index | [ int64](#int64) | none |
| key | [ bytes](#bytes) | none |
| value | [ bytes](#bytes) | none |
| proof_ops | [ tendermint.crypto.ProofOps](#tendermintcryptoproofops) | none |
| height | [ int64](#int64) | none |
| codespace | [ string](#string) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## Snapshot 



| Field | Type | Description |
| ----- | ---- | ----------- |
| height | [ uint64](#uint64) | The height at which the snapshot was taken |
| format | [ uint32](#uint32) | The application-specific snapshot format |
| chunks | [ uint32](#uint32) | Number of chunks in the snapshot |
| hash | [ bytes](#bytes) | Arbitrary snapshot hash, equal only if identical |
| metadata | [ bytes](#bytes) | Arbitrary application metadata |
 <!-- end Fields -->
 <!-- end HasFields -->


## TxResult 
TxResult contains results of executing the transaction.

One usage is indexing transaction results.


| Field | Type | Description |
| ----- | ---- | ----------- |
| height | [ int64](#int64) | none |
| index | [ uint32](#uint32) | none |
| tx | [ bytes](#bytes) | none |
| result | [ ResponseDeliverTx](#responsedelivertx) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## Validator 
Validator


| Field | Type | Description |
| ----- | ---- | ----------- |
| address | [ bytes](#bytes) | The first 20 bytes of SHA256(public key) |
| power | [ int64](#int64) | PubKey pub_key = 2 [(gogoproto.nullable)=false];

The voting power |
 <!-- end Fields -->
 <!-- end HasFields -->


## ValidatorUpdate 
ValidatorUpdate


| Field | Type | Description |
| ----- | ---- | ----------- |
| pub_key | [ tendermint.crypto.PublicKey](#tendermintcryptopublickey) | none |
| power | [ int64](#int64) | none |
 <!-- end Fields -->
 <!-- end HasFields -->


## VoteInfo 
VoteInfo


| Field | Type | Description |
| ----- | ---- | ----------- |
| validator | [ Validator](#validator) | none |
| signed_last_block | [ bool](#bool) | none |
 <!-- end Fields -->
 <!-- end HasFields -->
 <!-- end messages -->

# Enums


## CheckTxType 


| Name | Number | Description |
| ---- | ------ | ----------- |
| NEW | 0 | none |
| RECHECK | 1 | none |




## EvidenceType 


| Name | Number | Description |
| ---- | ------ | ----------- |
| UNKNOWN | 0 | none |
| DUPLICATE_VOTE | 1 | none |
| LIGHT_CLIENT_ATTACK | 2 | none |




## ResponseApplySnapshotChunk.Result 


| Name | Number | Description |
| ---- | ------ | ----------- |
| UNKNOWN | 0 | Unknown result, abort all snapshot restoration |
| ACCEPT | 1 | Chunk successfully accepted |
| ABORT | 2 | Abort all snapshot restoration |
| RETRY | 3 | Retry chunk (combine with refetch and reject) |
| RETRY_SNAPSHOT | 4 | Retry snapshot (combine with refetch and reject) |
| REJECT_SNAPSHOT | 5 | Reject this snapshot, try others |




## ResponseOfferSnapshot.Result 


| Name | Number | Description |
| ---- | ------ | ----------- |
| UNKNOWN | 0 | Unknown result, abort all snapshot restoration |
| ACCEPT | 1 | Snapshot accepted, apply chunks |
| ABORT | 2 | Abort all snapshot restoration |
| REJECT | 3 | Reject this specific snapshot, try others |
| REJECT_FORMAT | 4 | Reject all snapshots of this format, try others |
| REJECT_SENDER | 5 | Reject all snapshots from the sender(s), try others |


 <!-- end Enums -->
 <!-- end Files -->
