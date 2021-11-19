# RFC 006: Semantic Versioning

## Changelog

- 2021-11-2: Initial Draft

## Author(s)

- Callum @cmwaters

## Context

We use versioning as an instrument to hold a set of promises to users and signal when such a set changes and how. In the traditional sense of a Go library, major versions signal that the public Go API’s have changed in a breaking way and require the users of such libraries to change the way they use the libraries accordingly. Tendermint is a bit different in that there are multiple users: application developers (both in-process and out-of-process), node operators, and external clients and what's important to these users differs from what's important to traditional library consumers.

It's worth to further acknowledge that the strictness of our versioning guarantees may indicate to users our tendency either towards stability or speed yet holding the team by any set of guarantees means nothing if we don't also address the frequency that the team intends on making version changes.

This document attempts to encapsulate the discussions around versioning in Tendermint and draws upon them to propose a guide to how Tendermint uses versioning to make promises to its users.

## Discussion

We first begin with a round up of the various users and a set of assumptions on how

## Proposal

> It should contain a detailed breakdown of how the problem should be resolved including diagrams and other supporting materials needed to present the case and implementation roadmap for the proposed changes. The reader should be able to fully understand the proposal. This section should be broken up using ## subsections as needed.

## Status

Proposed

## Consequences

> This section describes the consequences, after applying the decision. All consequences should be summarized here, not just the "positive" ones.

### Positive

### Negative

### Neutral

## References

> Are there any relevant PR comments, issues that led up to this, or articles referenced for why we made the given design choice? If so link them here!

- {reference link}
