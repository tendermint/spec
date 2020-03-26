# RFC 001: Coordination and Configuration of Block Retention and State Sync

## Changelog

- 2020-03-23: Initial draft (@erikgrinaker)
- 2020-03-25: Use local config for snapshot interval (@erikgrinaker)

## Author(s)

- Erik Grinaker (@erikgrinaker)

## Context

Currently, all Tendermint nodes contain the complete sequence of blocks from genesis up to some height (typically the latest chain height). This will no longer be true when the following features are released:

* [Block pruning](https://github.com/tendermint/tendermint/issues/3652): removes historical blocks and associated data (e.g. validator sets) up to some height, keeping only the most recent blocks.

* [State sync](https://github.com/tendermint/tendermint/issues/828): bootstraps a new node by syncing state machine snapshots (note: not IAVL pruning snapshots) at a given height, but not historical blocks and associated data.

To maintain the integrity of the chain, the use of these features must be coordinated such that necessary historical blocks will not become unavailable or lost forever. In particular:

* Some nodes should have complete block histories, for auditability, querying, and bootstrapping.

* The majority of nodes should retain blocks longer than the Cosmos SDK unbonding period, for light client verification.

* Some nodes must take and serve state sync snapshots with snapshot intervals less than the block retention periods, to allow new nodes to state sync and then replay blocks to catch up.

* Only a minority of nodes can be state synced within the unbonding period, for light client verification and to serve block histories for catch-up.

However, it is unclear if and how we should enforce this. It may not be possible to technically enforce all of these without knowing the state of the entire network, but it may also be unrealistic to expect this to be enforced entirely through social coordination. This is especially unfortunate since the consequences of misconfiguration can be permanent chain-wide data loss.

The main configuration options involved are:

* Block retention (Tendermint): the number of recent blocks (heights) to retain.

* Block time (Tendermint): the minimum duration between consecutive blocks.

* Unbonding time (SDK): the duration in which validators can be economically punished for misbehavior.

* Snapshot interval (SDK): the interval (in heights) between taking state sync snapshots.

* Snapshot retention (SDK): the number of recent state sync snapshots to retain.

## Proposal

* Block retention (Tendermint): implement as a new consensus parameter `block.retention` (default 0, i.e. retain all), and add a local config option `consensus.prune_blocks` (default off) that allows operators to enable or disable block pruning on a per-node basis. Must be at minimum 2, since the current and previous blocks are required for progress.

* Block time (Tendermint): already implemented as a consensus parameter `block.time_iota_ms`.

* Unbonding time (SDK): already implemented as a genesis parameter `app_state.staking.params.unbonding_time`. Must now satisfy `unbonding_time < 2 * block.retention * block.time_iota_ms` otherwise errors (factor of 2 since `block.time_iota_ms` does not take into account block execution time).

* Snapshot interval (SDK): add a local config option `snapshot-interval` (default 0, i.e. disabled). Must satisfy `snapshot-interval < 2 * block.retention` otherwise errors, to allow state synced nodes to catch up via block replay (factor of 2 to account for time spent taking a snapshot).

* Snapshot retention (SDK): add a local config option `snapshot-retention` (default 2) that specifies the number of snapshots to keep. Must be at least 2 to allow in-flight state syncs to complete as new snapshots are produced, but higher retention can be useful e.g. during mixed-version upgrades where old snapshots can be used by old-version nodes, or for state machine archives.

## Status

Proposed

## Consequences

### Positive

* Consensus and genesis parameters for block retention, block time, and unbonding time allows governance to control whether pruning should be allowed, and to ensure sufficient availability of recent blocks for light client verification and short-term auditability, with enforced sanity checks.

* Node operators can independently decide whether they want to provide complete block histories and snapshots, if allowed by consensus parameter `block.retention`.

### Negative

* Social coordination is required to run archival nodes, failure to do so may lead to permanent loss of historical blocks.

* Social coordination is required to run snapshot nodes, failure to do so may lead to inability to run state sync, and inability to bootstrap new nodes at all if no archival nodes are online.

* Snapshot nodes can take snapshots at different intervals, leading to a lower availability of peers for a given snapshot than if it was a genesis parameter.

* Consensus parameter can't currently be changed in the SDK, requiring either implementing this or creating a new chain to enable block pruning.

* Chain-wide block retention sets a lower bound on disk space requirements for all nodes.

## References

- State sync ADR: https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-053-state-sync-prototype.md

- State sync issue: https://github.com/tendermint/tendermint/issues/828

- Block pruning issue: https://github.com/tendermint/tendermint/issues/3652
