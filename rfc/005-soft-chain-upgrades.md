
# RFC 005: Soft Chain Upgrades

## Changelog

- 2020-11-16: Initial draft.

## Author(s)

- Callum Waters (@cmwaters)

## Context

The current method for upgrading a network across block protocol breaking
changes is to hard fork the chain. All nodes must coordinate a halt height/
time, where application state can be exported across and an entirely new chain
(as far as Tendermint is concerned) is created (see [cosmoshub-3
upgrade](https://blog.cosmos.network/cosmos-hub-3-upgrade-announcement-39c9da941aee)).
This means that each block protocol version maps to the entire life of a single
chain. The result of this is that either Tendermint is hindered with the
flexibility and quantity of changes it can make or that networks have to deal
with pain of frequently upgrading.

Furthermore, although work from [RFC002: Non-Zero Genesis](https://github.com/tendermint/spec/blob/master/rfc/002-nonzero-genesis.md)
has enabled unique heights throughout the history of a "logical" chain, data
retrievability across heights remains difficult as blockchains that choose to
upgrade not only have to coordinate upgrades but they essentially lose all their
history.

The scope of this RFC is to address the need for Tendermint to have flexibility
in improving itself whilst offering greater ease of use to the networks running
on Tendermint. This is done by introducing a division in the types of ways a
network can be upgraded. There will still remain the need for hard upgrades (the
starting of a new chain) but this will not be focused on in this
RFC(discussions on improving this can be found [here](https://github.com/tendermint/tendermint/issues/5595)).
Instead, this RFC will only explore what supporting soft upgrades would entail.

## Proposal

Tendermint supports a class of upgrades deemed as soft upgrades.

Soft and hard upgrades would directly align with semver. For example, a release
from 1.2 → 1.3 would be considered a soft upgrade and could be executed on a
live chain (more on how that would be executed further down). A major release
from 1.5 → 2.0 would be a hard upgrade and require a network to halt and migrate.

### Protocol Versioning

Tendermint currently has three protocol versions: Block, P2P and App.

The block version consists of all block related data structures i.e. Header,
Vote, Validator, Commit. This would be the sole focus for soft upgrades (a full
list of the exact data structures can be found in
[data structures](https://github.com/tendermint/spec/blob/master/spec/core/data_structures.md#data-structures).
A block version could be incremented between minor releases. However, for
backwards compatibility, all prior versions in a given major release would also
need to be supported thus TM 1.3 could support block version 9 and 10 and TM 1.4
could introduce block version 11 but would still need to support 9 and 10. In a
major release the support of prior versions could be dropped. Continuing with
the same example this could mean that TM 2.0 could support block version 11
without supporting versions 9 or 10.

The other two, P2P and App would be left as is. Any changes to the network
protocol would require a hard upgrade and therefore would only be allowed in
major releases. Any changes to the app version would be able to be conducted
live and at the discretion of the app.

Depending on the implementation it may be more beneficial to divide block
protocol versions into more specific abstractions i.e. Block, State and
Consensus to isolate changes from spilling over multiple modules (normally a
change to say `commit` would cause us to replicate all the data structures).
However, increasing the granularity of abstractions would compound the
permutations between versions which could lead to untamable code, hence, given
that these changes should be grouped together and occur seldomly it should
suffice to have a single block protocol version.

### Transitions

Networks would be expected to announce upgrades in advance allowing a window for
individual nodes to upgrade to a software version of Tendermint that would
comply with the announced block protocol upgrade. Node runners would temporarily
halt their node, change to the latest binary and start up again. Tendermint
could also offer a tool to easily swap between binaries thus reducing the amount
of down-time that nodes experience although this is outside the scope of this
RFC.

The actual switch would occur in the same manner as an App Version change, using
the `EndBlockResponse{}` ABCI call to indicate to Tendermint that a different
block protocol be used. In the case that a node failed to upgrade, the node
would gracefully stop and error.

Given the delayed execution model, careful consideration would be needed to
ensure that the nodes could transition smoothly. It may be that the actual
upgrade might not take place till height: h + 2.

### Current Use of Versioning

Records of versions are currently stored in `State` and in the `Header` of each
block. This already covers a broad base of scenarios. The consensus reactor can
use the version from state to ensure it reads `Vote`s and `Partsetheader`s
correctly. Similarly, fast sync, the block executor and evidence module, whom
all interact with block protocol data structures also all have access to state.
The next few sections will explore the aspects of Tendermint that will need to
be modified to prepare for versioning.

#### RPC

Supporting soft upgrades means that the RPC will need to be able to deliver
information across different versions thus the RPC should be versatile to
requests over all prior heights and must return the data structure alongside a
version number so that the receiver knows how to interpret the information.

#### Light Clients

Similar to RPC, light clients will also need to be wary of block protocol
changes and be able to handle them accordingly. Light clients should have the
same version as the latest block protocol that they support. They will also
require a similar method for verifying across block versions.

#### Evidence

Evidence is always a reference to a past action. It could be possible that the
past action whether it be sending duplicate votes or attempting to fool a light
client with an alternative block was of a different block version. To be able to
process this correctly, evidence might need to include the version of it's
contents or have a method of working out what version the contents should be in
order to process them accordingly (upgrade heights could be stored in state).

#### Spec

In the future, we expect a versioned spec, where each spec release will list the
software versions and protocol versions that correlate to that release. This
will reside in `spec/version.md`. A clear guide of the rules behind breaking
changes should also be there for easy reference.

### Implementation Approach

If this proposal is accepted, the implementation will need to be further fleshed
out in an ADR, however, it is helpful to illustrate here the approach that
Tendermint would most likely take to support soft upgrades.

This would mostly likely mimic a similar design to what has been done in the
Cosmos SDK with keeping legacy code and using conditionals to handle transitions
between the versions. One would expect a directory structure for each module as
such:

```go
consensus // module
|---- state.go
|---- state_test.go
|       ...
|---- votes.go // current version (v10)
|       ...
|---- legacy
   |---- v8 // prior supported versions
      |---- votes.go
      |      ...    // other data structures ( and pure functions )
   |---- v9
      |---- votes.go
      |      ...
```

The module, depending on the types, may statically cast each of the different
versions or define an interface that it expects all versions to follow. For
example:

```go
func (blockExec *BlockExecutor) CreateProposalBlock(state State) (BlockI, error)
{
 switch state.Version.Block {
 case 9:
  return v9.CreateProposalBlock(state, blockExec.Mempool, blockExec.Evpool)
 case 10:
  return v10.CreateProposalBlock(state, blockExec.Mempool, blockExec.Evpool)
 default:
  return fmt.Errorf("block version %d not recognised", state.Version.Block)
 }
}
```

In this case, Block which falls under a data structure of the block protocol
could have many versions and is represented here as an interface. `State` and
`BlockExecutor` are structs outside of the block protocol. Breaking changes to
them could only occur in major releases.

### Alternative Approach: Migration Scripts

Although using migration scripts would have been most likely a simpler solution,
unfortunately in most cases this would result in breaking the hashes and is
therefore not a viable approach.

### Concluding Remarks

This option provides greater flexibility for the developers and potentially
reduces the amount of coordination and work required for validators and the
frequency with which hard forks need to occur. However, it is nevertheless
recommended that block protocol breaking changes still be grouped together and
remain as seldom as possible.

The implementation to support this would ideally need to be done prior to the
1.0 release.

## Status

Proposed

## Consequences

### Positive

- Chains get the benefits of upgrades without having to sacrifice their block
history

### Negative

- There is a large degree of complexity required in ensuring the flexibility of
data structures. This could lead to the bloating of the code-base and/or
decreasing how easy it is to follow.

### Neutral

- There will still need to be hard chain upgrades (albeit fewer).

## References

- [Upgrade tooling tracking issue](https://github.com/tendermint/tendermint/issues/5595)
- [Protocol versions](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-016-protocol-versions.md)
