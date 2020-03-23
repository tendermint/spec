# RFC 001: Coordination of Block Retention Configuration

## Changelog

- 2020-03-23: Initial draft (@erikgrinaker)

## Author(s)

- Erik Grinaker (@erikgrinaker)

## Context

Currently, all Tendermint nodes contain the complete sequence of blocks from genesis up to some height (typically the latest chain height). This will no longer be true when the following features are released:

* [Block pruning](https://github.com/tendermint/tendermint/issues/3652): removes historical blocks and associated data (e.g. validator sets) up to some height.

* [State sync](https://github.com/tendermint/tendermint/issues/828): bootstraps a new node by syncing the state machine at a given height, but not historical blocks and associated data.

To maintain the integrity of the chain, the use of these features must be coordinated such that necessary historical blocks will not be made unavailable or lost forever. In particular:

* Some nodes should have complete block histories, for auditability and querying.

* The majority of nodes should retain blocks longer than the Cosmos SDK unbonding period, for light client verification.

* Some nodes must take and serve state sync snapshots with snapshot intervals less than the block retention periods, to allow new nodes to state sync and then replay blocks to catch up.

* Only a small minority of nodes can be state synced within the unbonding period, for light client verification and to serve block histories for catch-up.

However, it is unclear if and how we should enforce this. It may not be possible to technically enforce all of these without knowing the state of the entire network, but it may also be unrealistic to expect this to be enforced entirely through social consensus. This is especially unfortunate since the consequences of misconfiguration can be permanent chain-wide data loss.

The main configuration options involved are:

* Unbonding time (SDK): the duration in which validators can be economically punished for misbehavior.

* Block time (Tendermint): the minimum duration between consecutive blocks.

* Block retention (Tendermint): the number of blocks (heights) to retain below the most recently applied block.

* Snapshot interval (SDK): the interval (in heights) between taking state sync snapshots.

* Snapshot retention (SDK): the number of recent state sync snapshots to retain.

## Proposal

* Unbonding time (SDK): already implemented as a genesis parameter `app_state.staking.params.unbonding_time`.

* Block time (Tendermint): already implemented as a genesis parameter `consensus_params.block.time_iota_ms`.

* Block retention (Tendermint): implement as a new genesis parameter `consensus_params.block.retention` (default 0, i.e. all), and add a local configuration option `consensus.prune_blocks` (default off) that allows node operators to either enable or disable block pruning on a per-node basis but not control the number of blocks to retain. Should be at least 2, since the current and previous blocks are required for progress.

* Snapshot interval (SDK): implement as a new genesis parameter `app_state.snapshots.interval` (default 0, i.e. disabled). This should be lower than the block retention, to allow state synced nodes to catch up via block replay.

* Snapshot retention (SDK): add a local configuration option `snapshot-retention` (default 0, i.e. disabled) that specifies the number of snapshots to keep. Should be at least 3, to allow in-flight state syncs to complete while new snapshots are produced, but higher numbers can be useful e.g. during mixed-version upgrades where old snapshots can be used by nodes on old versions.

## Status

Proposed

## Consequences

### Positive

* Genesis parameters for block retention, block time, and unbonding time allows governance consensus to ensure availability and correctness of light client verification and short-term auditability of slashing.

* Genesis parameters for snapshot interval ensures high availability of snapshots at a given height, allowing parallel downloads and faster state syncing.

* Node operators can independently decide whether they want to provide full block histories and snapshots.

### Negative

* Misconfiguration of block retention (i.e. setting it less than the unbonding time) is possible despite governance consensus, unless we add explicit checks for this in the Cosmos SDK.

* Misconfiguration of snapshot interval (i.e. setting it lower than the block retention) is possible despite governance consensus, unless we add explicit checks for this in the Cosmos SDK.

* Social coordination is required to run archival nodes, failure to do so will lead to permanent loss of historical blocks.

* Social coordination is required to run snapshot nodes, failure to do so will lead to inability to run state sync, and inability to bootstrap new nodes at all if no archival nodes are online.

* Chain-wide block retention sets a lower bound on disk space requirements for all nodes.

### Neutral

* Block pruning and state sync snapshotting requires governance proposals to be accepted before they can be used.

## References

- State sync ADR: https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-053-state-sync-prototype.md

- State sync issue: https://github.com/tendermint/tendermint/issues/828

- Block pruning issue: https://github.com/tendermint/tendermint/issues/3652
