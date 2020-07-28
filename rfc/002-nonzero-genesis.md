# RFC 002: Non-Zero Genesis

## Changelog

- 2020-07-26: Initial draft (@erikgrinaker)
- 2020-07-28: Use weak chain linking, i.e. `predecessor` field (@erikgrinaker)

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
file would at least provide monotonically increasing heights. Information about the previous chain
(ID and last block header) is also included, for informational purposes.

External tooling would be required to map historical heights onto e.g. archive nodes that contain 
blocks from previous chain version. Tendermint will not include any such functionality.

## Proposal

Tendermint will allow chains to start from an arbitrary initial height, with the minimum amount of
changes to existing code and protocols:

* A new field `initial_height` is added to the genesis file, defaulting to `1`. It can be set to any
non-negative integer, and `0` is considered equivalent to `1`.

* A new field `InitialHeight` is added to the ABCI `RequestInitChain` message, with the same value 
and semantics as the genesis field.

Additionally, the genesis file will be extended with a new `predecessor` field containing 
information about the previous chain, specifically the final block header:

```json
{
    "predecessor": {
        "version": {"block": "10", "app": "0"},
        "chain_id": "chain-1",
        "height": 1000000,
        "time": "2020-07-28T15:42:48.000Z",
        "last_block_id": {
            "hash": "2D7F34765B312A46BC551F9B3E0535D91CBA9513AAFDBB3458D17D7FD89FBEF0",
            "parts": {"total": "1", "hash": "4D347E9C22E4C7EA15DB0B5AFF6799BC0A85B854443C3BA6E3B81A7BB7163931"},
        },
        "app_hash": "123AC50B458A998EB481D7E17A423C8C0ED238813518B55FAF57510F73F76DFC",
        ...
    }
}
```

This field will be ignored by Tendermint, but may be helpful to integrators and users.

If possible, no further changes will be made to any data structures. In particular, the initial
height will not be added to the node state, and will instead be passed explicitly to any logic that 
relies on it.

ABCI applications may have to be updated to handle arbitrary initial heights, otherwise the initial
block may fail.

## Status

Proposed

## Consequences

### Positive

* Heights will be unique throughout the history of a "logical" chain, across hard fork upgrades.

### Negative

* Upgrades still cause loss of block history.

* Integrators will have to map height ranges to specific archive nodes/networks to query history.

### Neutral

* The predecessor block header is not verified by Tendermint at all, and must be verified by
  network governors.

## References

- [#2543: Allow genesis file to start from non-zero height w/ prev block header](https://github.com/tendermint/tendermint/issues/2543)