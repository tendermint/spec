# RFC 002: Non-Zero Genesis

## Changelog

- 2020-07-26: Initial draft (@erikgrinaker)

## Author(s)

- Erik Grinaker (@erikgrinaker)

## Context

The recommended upgrade path for block protocol-breaking upgrades is currently to hard fork the
chain (see e.g. [`cosmoshub-3` upgrade](https://blog.cosmos.network/cosmos-hub-3-upgrade-announcement-39c9da941aee)).
This is done by halting all validators at a predetermined height, exporting the application
state via application-specific tooling, and creating an entirely new chain using the exported
application state.

As far as Tendermint is concerned, the upgraded chain is a completely separate chain, with e.g.
a new chain ID and genesis file. Notably, the new chain starts at height 1, and has none of the
old chain's block history. This causes problems for integrators, e.g. coin exchanges and
wallets, that assume a monotonically increasing height for a given blockchain. Users also find
it confusing that a given height can now refer to distinct states depending on the chain
version.

An ideal solution would be to always retain block backwards compatibility in such a way that chain 
history is never lost on upgrades. However, this may require a significant amount of engineering
work that is not viable for the planned Stargate release (Tendermint 0.34), and may prove too
restrictive for future development.

As a first step, allowing the new chain to start from an initial height specified in the genesis
file would at least provide monotonically increasing heights. It may also be useful to include the 
latest block header from the previous chain, to link them.

External tooling would be required to map historical heights onto e.g. archive nodes that contain 
blocks from previous chain version. Tendermint will not include any such functionality.

## Proposal

There are two main approaches that can be taken:

* **Initial height:** the genesis file specifies an arbitrary initial height that the chain starts 
from.

* **Chain linking:** the genesis file includes e.g. the last block header and chain ID from the
previous chain, and possibly uses this as the basis for the initial block.

ABCI applications will have to be updated to handle arbitrary initial heights.

### Initial Height

This approach allows a chain to start from an arbitrary height, with the least amount of changes
to existing code and protocols. Social consensus is necessary to link it to the previous chain.

* A new field `initial_height` is added to the genesis file, defaulting to `1`. It can be set to any
non-negative integer, and `0` is considered equivalent to `1`.

* A new field `InitialHeight` is added to the ABCI `RequestInitChain` message, with the same value 
and semantics as the genesis field.

If possible, no further changes will be made to any data structures. In particular, the initial
height will not be added to the node state, and will instead be passed explicitly to any logic that 
relies on it.

### Chain Linking

This approach includes an explicit link to the previous chain in the genesis file. This can take 
several forms, e.g.:

* Weak: an advisory chain ID and last block header or hash. This will not be used by Tendermint at 
all, and is only there to guide users and integrators to the previous chain and block.

* Strong: the chain ID, last block header, and last commit. This will be verified by Tendermint 
(requiring support for the previous chain's data structures and hashing algorithms) when processing 
the initial height on the new chain, which e.g. ensures that the same validator set is used.

In these cases, the initial height can either be derived from the last block header, or combined
with a separate `initial_height` field.

Strong linking will require additional spec and engineering work that may delay Stargate, but gives
stronger guarantees of chain continuity, which may be particularly important to IBC and light
clients (where validator set continuity is essential to punish misbehavior on the old chain).

## Status

Proposed

## Consequences

### Positive

* Heights will be unique throughout the history of a "logical" chain, across hard fork upgrades.

### Negative

* Upgrades still cause loss of block history.

* Integrators will have to map height ranges to specific archive nodes/networks to query history.

### Neutral

## References

- [#2543: Allow genesis file to start from non-zero height w/ prev block header](https://github.com/tendermint/tendermint/issues/2543)