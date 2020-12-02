# RFC 006: Backfill blocks

## Changelog

- 2020-11-25: Initial draft.

## Author(s)

- Callum Waters (@cmwaters)

## Context

Two new features: [Block pruning](https://github.com/tendermint/tendermint/issues/3652)
and [State sync](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-042-state-sync.md)
meant nodes no longer needed a complete history of the blockchain. This
introduced some challenges of its own which were covered and subsequently
tackled with [RFC-001](https://github.com/tendermint/spec/blob/master/rfc/001-block-retention.md).
The RFC allowed applications to set a block retention height; an upper bound on
what blocks would be pruned. However nodes who state sync past this upper bound
(which is necessary as snapshots must be saved within the trusting period for
the assisting light client to verify) have no means of backfilling the blocks
to meet the retention limit. This could be a problem as nodes who state sync and
then eventually switch to consensus may not have the block and validator
history to verify evidence causing them to panic if they see 2/3 commit on what
the node believes to be an invalid block.

Having the capability to backfill prior blocks also allows nodes with
truncated history to become archive nodes which may be beneficial for the
network.                                            

## Proposal

A backfill mechanism can simply be defined as an algorithm for fetching,
verifying and storing, blocks and other state data (`ValidatorSet`'s
`ConsensusParams`'s and `ABCIResponses`'s) of a height prior to the current
base of the blockchain. Verification and design will be addressed
later in the RFC. First we cover where the mechanism would be deployed.

There are two places where a backfill mechanism would be required:
1. Upon startup via state sync where nodes must meet the prerequisite history
before participating in consensus
2. Where application specifies that the `retain_height` needs to be lower than
the current blockchain base.

### Backfill on State Sync

A node, seeking to state sync, will find an adequate snapshot and offer it to
the application with the following format:

```proto
message RequestOfferSnapshot {
  Snapshot snapshot = 1;  // snapshot offered by peers
  bytes    app_hash = 2;  // light client-verified app hash for snapshot height
}
```

where `Snapshot` contains the new field `backfill_height` :

```proto
message Snapshot {
  uint64 height          = 1;  // The height at which the snapshot was taken
  uint32 format          = 2;  // The application-specific snapshot format
  uint32 chunks          = 3;  // Number of chunks in the snapshot
  bytes  hash            = 4;  // Arbitrary snapshot hash, equal only if identical
  bytes  metadata        = 5;  // Arbitrary application metadata
  int64  backfill_height = 6;  // Height to backfill blocks from before starting application (inclusive)
}
```

If all chunks are accepted and state sync is successful then the node will
retrieve and verify blocks up to (and including) the specified backfill height
**before** participating in consensus.

### Backfill on application request

The application has control of block retention via `retain_height`, called here:

message ResponseCommit {
  // reserve 1
  bytes data          = 2;
  int64 retain_height = 3;
}

Beforehand, a retain height that was less than the nodes current base was
ignored. With the same backfill mechanism, the application should now be able to
lower the retention height below the current base height (whether to accommodate
changing consensus parameters, app specific needs, or a local config).
This accommodates the use case of a truncated node that wishes to become an
archive node. Note this could be done simultaneously alongside consensus.

### Verification

Nodes will need to verify these prior blocks. This can be achieved by first
retrieving the header at the base height from the block store. The node then
checks that the `LastBlockID` corresponds with the hash calculated from the
header in the new block directly below:

```go
header[height].LastBlockID == hash(header[height-1])
```

The node can therefore trust the new header. This then can be followed with
using the hashes in the trusted header to validate the other block and state
info. This is recursively done till the backfill height.  

### Design

The backfill mechanism would reside in the blockchain reactor. One may view it
similarly to fast syncs position within the reactor as a service that can be
started and stopped. Backfill, however, would not be an optional configuration.

Two new messages would be added to allow for the passing of state data:

```proto
message StateDataRequest {
  int64 height = 1;
}
```

```proto
message StateDataResponse {
  int64 height = 1;
  ValidatorSet validator_set = 2;
  ConsensusParams consensus_params = 3;
  ABCIResponses abci_responses = 4;
}
```

This would be sent across the existing blockchain channel. The advantage with
this setup is that all backfill data is within the same domain, making it
easier to coordinate both verification of block and state data.

## Alternative Solutions

If we do not want to extend the blockchain's functionality, it is possible to
use the embedded light client within state sync instead.

This approach would separate the two forms of data. The state sync reactor would
be responsible for verifying state data and persisting it whilst the blockchain
reactor would process only the blocks. Operating asynchronously could cause
inconsistencies in which data was available (if blockchain reactor is faster
we have blocks with no validator set; if state sync reactor is faster then we
have validator sets with no blocks). This would also require duplication in
headers sent (one for the light client and one within the block sent to the
blockchain reactor).

Currently the light client uses the RPC connection, however, consideration could
be made to support P2P. The advantage of this, is that we could sync a lot of
the needed functionality of state sync / backfill and the light client into a
single reactor (serving `ValidatorSet`, `ConsensusParams` & `SignedHeader`).

Taking one further step back, some of the problems listed in the introduction
could be resolved by other means. Full nodes (and even validators to a certain
extent) could simply bypass validation if they didn't have the necessary
history. Node operators running nodes with truncated history could start up a
separate full node if they wanted complete history.

## Status

Proposed

## Consequences

### Positive

- Greater flexibility over the data that a node has. This makes it easier to
become a node with full history.
- Ensures a minimum block history invariant.

### Negative

- Applications need to be careful about adjusting the retain height too
frequently as this will put extra load on the network.
- Statesync will be slower as more processing is required.

### Neutral

- By having validator sets served through p2p, this would make it easier to
extend p2p support to light clients.
- `Backfill_height` can be relative to the latest height of the providing node,
not just an absolute height. This means that an older snapshot might not require
as much backfilling as a newer one.

## References

- [RFC-001: Block retention]((https://github.com/tendermint/spec/blob/master/rfc/001-block-retention.md)
- [Original issue](https://github.com/tendermint/tendermint/issues/4629)
