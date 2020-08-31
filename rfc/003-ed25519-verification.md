# RFC 003: Ed25519 Verification

## Changelog

- August 21, 2020: initialized

## Author(s)

- Marko (@marbar3778)

## Context

Ed25519 keys are the only supported key types for Tendermint validators currently. Tendermint-Go wraps the ed25519 key implementation from the go standard library. As more clients are implemented to communicate with the canonical Tendermint implementation (Tendermint-Go) different implementations of ed25519 will be used. Due to [RFC 8032](https://www.rfc-editor.org/rfc/rfc8032.html) not guaranteeing implementation compatibility, Tendermint clients must to come to an agreement of how to guarantee implementation compatibility. [Zcash](https://z.cash/) has multiple implementations of their client and have identified this as a problem as well. The team at Zcash has made a proposal to address this issue, [Zcash improvement proposal 215](https://zips.z.cash/zip-0215).

## Proposal

- Tendermint-Go would adopt [hdevalence/ed25519consensus](https://github.com/hdevalence/ed25519consensus).
    - This library is implemented as an extension of the go standard library one.
- Tendermint-rs would adopt [ed25519-zebra](https://github.com/ZcashFoundation/ed25519-zebra)
    - related [issue](https://github.com/informalsystems/tendermint-rs/issues/355)

As signature verification is one of the major bottlenecks of Tendermint-go, if ZIP 215 is adopted batch verification of signatures will be safe in consensus critical areas.

## Status

Proposed

## Consequences

### Positive

- Batch verification
- Signature verification across implementations

### Negative

#### Tendermint-Go

- Additional dependency
- Fragmentation of the ed25519 key for the go implementation, verification is done using a third party library while the rest
  uses the go standard library

### Neutral

## References

> Are there any relevant PR comments, issues that led up to this, or articles referenced for why we made the given design choice? If so link them here!
