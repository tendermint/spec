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

A node, seeking to state sync, will find an adequate snapshot and offer it to
the application with the following format:

```golang
type snapshot struct {
 	Height   uint64
 	Format   uint32
 	Chunks   uint32
 	Hash     []byte
 	Metadata []byte

 	trustedAppHash []byte // populated by light client
}
```

The application will then be expected to parse information in the meta data
regarding the backfill height and then return it in the response (alongside the
app's decision):

```proto
message ResponseOfferSnapshot {
  Result result = 1;
  int64 backfill_height = 2;
}
```

If all chunks are accepted and state sync is successful then the backfill height
would be returned from state sync to the node so that it can execute the
backfill process (via the blockchain reactor) to retrieve the necessary blocks.
A backfill height of 0 would mean that this step is ignored.

```golang
go func() {
		state, commit, backfill_height, err := ssR.Sync(stateProvider, config.DiscoveryTime)
		if err != nil {
			ssR.Logger.Error("State sync failed", "err", err)
			return
		}
		err = stateStore.Bootstrap(state)
		if err != nil {
			ssR.Logger.Error("Failed to bootstrap node with new state", "err", err)
			return
		}
		err = blockStore.SaveSeenCommit(state.LastBlockHeight, commit)
		if err != nil {
			ssR.Logger.Error("Failed to store last seen commit", "err", err)
			return
		}

    // proposed method for backfilling blocks
    bcR.BackfillBlocks(backfill_height)

		if fastSync {
			err = bcR.SwitchToFastSync(state)
			if err != nil {
				ssR.Logger.Error("Failed to switch to fast sync", "err", err)
				return
			}
		} else {
			conR.SwitchToConsensus(state, true)
		}
}
```

`BackfillBlocks` would be implemented similarly to fast sync itself, by
requesting blocks and validating them by matching the hash of the new header
to the LastBlockID hash in the trusted header. This would use the same block
pool and thus would be exclusive with the fast sync process (only one can run
at a time).

For completeness, the node should also retrieve the `ValidatorSet`s,
`ConsensusParam`'s and `ABCIResponse`'s for each of the heights. In alignment
with the separation between state and block, it may makes sense that the state
sync reactor rather than the blockchain reactor serve, request and verify this
data.

This could be done in one of two ways: use the light client via the
RPC connection or creating a new channel to send this data through.

However, this separation would require multiple reads to retrieve the header at
each height and would make it difficult to coordinate with the process running
on the blockchain reactor. Hence I would lean towards extending the blockchain
reactor with new channels to request this data structure, to verify it and to
persist it to the state store.

The back filling of blocks on start up would occur synchronously, completing
this action before switching to either fast sync or consensus.

Following with the notion of having the application in control of block
retention, if for whatever circumstance the application wanted to lower the
retention height below the current base height (whether to accommodate changing
consensus parameters, app specific needs, or a local config), this would boot
up the same backfill mechanism to asynchronously fetch, verify and persist
prior blocks.

## Status

Proposed

## Consequences

### Positive

- Greater flexibility over the data that a node has. This makes it easier to
become a node with full history.
- Ensures that a state synced node has the adequate block history before
being involved in consensus.

### Negative

- Applications need to be careful about adjusting the retain height too
frequently as this will put extra load on the network.
- Statesync will be slower as more processing is required.

### Neutral

- By having validator sets served through p2p, this will make it easier to
extend p2p support to light clients.

## References

- [RFC-001: Block retention]((https://github.com/tendermint/spec/blob/master/rfc/001-block-retention.md)
- [Original issue](https://github.com/tendermint/tendermint/issues/4629)
