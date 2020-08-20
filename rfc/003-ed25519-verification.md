# RFC 003: Ed25519 Verification

## Changelog

- {date}: initialized

## Author(s)

- Marko (@marbar3778)

## Context

Tendermint uses ed25519 in consensus critical ways. As more clients begin appearing which implement the Tendermint spec (tendermint-rs) an agreement on ed25519 signature verification is needed.

[RFC 8032](https://www.rfc-editor.org/rfc/rfc8032.html) leaves space for interpretation for signature validity. This becomes a problem when a different implementation is trying to verify a signature then the one that was used to generate it.

## Proposal

The [Zcash](https://z.cash/) team has identified this as a problem for their client and have written libraries in various languages to help address this. [Zcash improvement proposal 215](https://zips.z.cash/zip-0215) outlines the specification of the approach for signature validity. ZIP 215 explicitly defines the criteria for signature validation.

- Tendermint-go would adopt [hdevalence/ed25519consensus](https://github.com/hdevalence/ed25519consensus).
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

### Neutral

## References

> Are there any relevant PR comments, issues that led up to this, or articles referenced for why we made the given design choice? If so link them here!
