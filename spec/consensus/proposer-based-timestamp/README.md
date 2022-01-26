# Proposer-Based Timestamps

This section describes a version of the Tendermint consensus protocol
that uses proposer-based timestamps.

## Context

Tendermint provides a deterministic, Byzantine fault-tolerant, source of time,
defined by the `Time` field present in the headers of committed blocks,
representing the block's timestamp.

In the current consensus implementation, the timestamp of a block is
computed by the [BFT Time][bfttime] algorithm:

- Validators timestamps the `Precommit` messages they broadcast.
Timestamps are retrieved from the validator's local clocks,
with the only restriction that they must be monotonic:

	- The timestamp of a `Precommit` message for a block
	cannot be earlier than the `Time` field of that block.

- The timestamp of a block is deterministically computed from the timestamps of
a set of `Precommit` messages that certify the commit of the previous block.
This certificate, a set of `Precommit` messages from a round of the previous height,
is selected by the block's proposer and stored in the `Commit` field of the block.

	- The block timestamp is the *median* of the timestamps of the `Precommit` messages
	included in the `Commit` field, weighted by their voting power.
	Since timestamps of valid `Precommit` messages are monotonic, so are block timestamps:
	the timestamp of block `h+1` is larger than the timestamp of block `h`.

	- Let `f` be voting power controlled by Byzantine validators. 
	Provided that the cumulative voting power of a `Commit` set is at least `2f+1`,
	the block timestamp is retrieved from the clock of a non-faulty validator. 

## Proposal

In the proposed solution, the timestamp of a block is assigned by its
proposer, according with its local clock.
In other words, the proposer of a block also *proposes* a timestamp for the block.
Validators can accept or reject a proposed block.
A block is only accepted if its timestamp is acceptable.
A proposed timestamp is acceptable if it is *received* within a certain time window,
determined by synchronous parameters.

PBTS therefore augments the system model considered by Tendermint with *synchronous assumptions*:

- **Synchronized clocks**: simultaneous clock reads at any two correct validators
differ by at most `PRECISION`;

- **Bounded message delays**: the end-to-end delay for delivering a message to all correct validators
is bounded by `MSGDELAY`.
This assumption is restricted to `Proposal` messages, broadcast by proposers.

`PRECISION` and `MSGDELAY` are consensus parameters, shared by all validators,
that define whether the timestamp of a block is acceptable.
Let `t` be the time, read from its local clock, at which a validator
receives, for the first time, a proposal with timestamp `ts`:

- **[Time-Validity]** The proposed timestamp `ts` received at local time `t`
is accepted if it satisfies the **timely** predicate:
> `ts - PRECISION <= t <= ts + MSGDELAY + PRECISION`

The left inequality of the *timely* predicate establishes that proposed timestamps
should be in the past, when adjusted by the clocks `PRECISION`.
The right inequality of the *timely* predicate establishes that proposed timestamps
should not be too much in the past, more precisely, not more than `MSGDELAY` in the past,
when adjusted by the clocks `PRECISION`.

## Contents

- [Proposer-Based Time][main] (entry point)
- [Part I - System Model and Properties][sysmodel]
- [Part II - Protocol Specification][algorithm]
- [TLA+ Specification][proposertla]


[bfttime]: ../bft-time.md

[algorithm]: ./pbts-algorithm_002_draft.md

[sysmodel]: ./pbts-sysmodel_001_draft.md

[main]: ./pbts_001_draft.md

[proposertla]: ./tla/TendermintPBT_001_draft.tla
