# RFC 006: Backfill blocks

## Changelog

- 2020-11-25: Initial draft.

## Author(s)

- Callum Waters (@cmwaters)

## Context

> This section contains all the context one needs to understand the current state, and why there is a problem. It should be as succinct as possible and introduce the high level idea behind the solution.

Two new features: [Block pruning](https://github.com/tendermint/tendermint/issues/3652)
and [State sync](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-042-state-sync.md)
meant nodes no longer needed a complete history of the blockchain. This
introduced some challenges of its own which were covered and subsequently
tackled with [RFC-001](https://github.com/tendermint/spec/blob/master/rfc/001-block-retention.md).
The RFC allowed applications to set a block retention height; an upper bound on
what blocks would be pruned. However nodes whom state sync past this upper bound
(which is necessary as snapshots must be saved within the trusting period for
the assisting light client to verify) have no means of backfilling the blocks
to meet the retention limit. This could be a problem as nodes would be unable to


## Proposal

> It should contain a detailed breakdown of how the problem should be resolved including diagrams and other supporting materials needed to present the case and implementation roadmap for the proposed changes. The reader should be able to fully understand the proposal. This section should be broken up using ## subsections as needed.

## Status

> A decision may be "proposed" if it hasn't been agreed upon yet, or "accepted" once it is agreed upon. If a later RFC changes or reverses a decision, it may be marked as "deprecated" or "superseded" with a reference to its replacement.

Proposed

## Consequences

> This section describes the consequences, after applying the decision. All consequences should be summarized here, not just the "positive" ones.

### Positive

### Negative

### Neutral

## References

> Are there any relevant PR comments, issues that led up to this, or articles referenced for why we made the given design choice? If so link them here!

- {reference link}
