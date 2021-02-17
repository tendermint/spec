# RFC 004: ReverseSync - fetching historical data

## Changelog

- 2021-02-17: Add notes on asynchronicity of processes.
- 2020-12-10: Rename backfill blocks to reverse sync.
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

Furthermore, having the capability to backfill prior blocks also allows nodes with
truncated history to become archive nodes which may be beneficial for the
network.                                            

## Proposal

A backfill mechanism can simply be defined as an algorithm for fetching,
verifying and storing, blocks and other state data (`ValidatorSet`'s
`ConsensusParams`'s and `ABCIResponses`'s) of a height prior to the current
base of the node's blockchain. In matching the terminology used for other
data retrieving protocols (i.e. fast sync and state sync), we 
call this method **ReverseSync**. Verification and design will be 
addressed later in the RFC. First we cover where the mechanism would be deployed.

There are two places where a backfill mechanism would be required:
1. Upon startup via state sync where nodes must meet the prerequisite history
before participating in consensus
2. Where application specifies that the `retain_height` needs to be lower than
the current blockchain base.

### ReverseSync after State Sync

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

### ReverseSync on application request

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
archive node.

#### Choosing between Strong or Weak Gaurantees about Data

It can be said previously, that block pruning, with respect to the application, 
offered strong gaurantees about data i.e. if the application pruned to height 100, 
the operation was synchronous and thus the application knew it would prune to 100 
before the next height. This meant that the application always knew the height and 
base of the blockchain at every step. The opposite, weak gaurantees, implies that 
the application can't gaurantee that what it asked from Tendermint, with respect 
to data, has happened.

The downside of strong gaurantees is that it is blocking. If a validator decided 
to prune a million blocks at once, the validator could potentially fall behind. 
There's an argument then that pruning (and for that matter reverse sync) shouldn't 
lie on the consensus critical path but rather be an asynchronous background process 
of the node.

Further to this argument, nodes will not be able to prune past the evidence age 
regardless of the retain height that the application requests. Finally, applications 
may ask to fetch blocks back to a height that none of the nodes peers have. 
The mechanism must ensure termination even if it doesn't reach the height requested 
by the app.

Taking all these points into consideration, ReverseSync and pruning should be
operations that run asynchronously in the background. Application can be informed
of the current base via `RequestEndBlock`:

```proto 
message RequestEndBlock {
	Height uint64
  Base uint64
}
```

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

This section will provide a high level picture of the design with the specifics being
addressed in a following ADR. The reverse mechanism requires the gossiping of two new
messages to allow the passsing of state data:

```proto
message StateDataRequest {
  uint64 height = 1;
}
```

```proto
message StateDataResponse {
  uint64 height = 1;
  ValidatorSet validator_set = 2;
  ConsensusParams consensus_params = 3;
  ABCIResponses abci_responses = 4;
}
```

This would be sent across a new channel most likely within the blockchain reactor 
(one can view ReverseSync as a similar process to FastSync and thus should most
likey be in the same domain).

## Alternative Solutions

If we do not want to extend the blockchain's functionality, it is possible to
use the embedded light client within state sync instead to verify backwards outside
of the unbondind period and request a snapshot at that height instead. 

Taking one step further back, some of the problems listed in the introduction
could be resolved by other means. Full nodes (and even validators to a certain
extent) could simply bypass validation if they didn't have the necessary
history trusting purely in consensus. Node operators running nodes with truncated 
history could start up a separate full node if they wanted complete history.

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
- Implementation needs to be aware of multiple concurrent processes affecting
both the blockchain base and height

### Neutral

- By having validator sets served through p2p, this would make it easier to
extend p2p support to light clients.
- `Backfill_height` can be relative to the latest height of the providing node,
not just an absolute height. This means that an older snapshot might not require
as much backfilling as a newer one.

## References

- [RFC-001: Block retention](https://github.com/tendermint/spec/blob/master/rfc/001-block-retention.md)
- [Original issue](https://github.com/tendermint/tendermint/issues/4629)

## Notes

- In the future, if a decision is made to bring the light client into the p2p framework, then this state 
data will likely be split up as the light client requires only the validator set for verification.