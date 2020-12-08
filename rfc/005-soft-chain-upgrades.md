
# RFC 005: Soft Chain Upgrades

## Changelog

- 2020-11-27: Add appendix to distinguish between soft and hard upgrades
- 2020-11-23: Added chain migration proposal for comparison
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
chain. The result is that networks either forego new features for long periods
of time or have to deal with the pains of upgrading such as the coordination
effort, state migration, intra-chain security challenges and most importantly,
the loss of transaction history.

The scope of this RFC is to address the need for Tendermint to have better
flexibility in improving itself whilst offering greater ease of use to the
networks running on Tendermint. This is done by introducing a division in the
way a network can upgrade: either soft or hard. More information on the
distinction as well as general upgrade terminology can be found in Appendix A.
There may still remain the need for hard upgrades but this will be focused
[elsewhere](https://github.com/tendermint/tendermint/issues/5595)). Instead,
this RFC will describe what supporting soft upgrades would entail and explore
two different methods: **Multi Data Structure Support** or
**Chain Migrations**.

## Proposal

Tendermint supports a class of upgrades deemed as soft upgrades.

A soft upgrade, in the simplest terms, is a change to Tendermint's binary that
would not impede with the use of prior data / existing chains.

The implementation to support this would ideally need to be done prior to the
1.0 release.

### Stakeholders

Let's first set out to define the different needs that the various stakeholders
of the Tendermint software have in the context of upgrading:

- Application Developers: want to be able to get as much of the benefits of
  new features (like state sync and light client) with minimal work or loss to
  their current infrastructure. Ideally, Tendermint is also somewhat
  accommodating to application upgrades.

- Node Operators: Primarily they want safety and reliability. This means minimal
  down-time and intuitive / easy UX when it comes to upgrading.

- Wallets, Block Explorers and other clients: data retrievability which means
  ensuring that helpful/informative data is always available and that minimal
  infrastructure is needed to support serving data across the entire lifespan of
  the chain.

### Protocol Versioning

Tendermint currently has three protocol versions: Block, P2P and App.

The block protocol version would initially be the sole focus for soft upgrades.
This consists of all block related data structures i.e. `Header`,
`Vote`, `Validator`, `Commit` (a full list of the exact data structures can be
found in [data structures](https://github.com/tendermint/spec/blob/master/spec/core/data_structures.md#data-structures).
Data structures are dictated by the spec thus requiring a Tendermint software
version to indicate the block version/s it supports. When a new spec release
makes changes to any of the aforementioned data structures, this will result in
incrementing the block protocol version.

The app version can already be changed via consensus and is left to the
discretion of the application to handle. The P2P version would also be left as
it is, with major revisions requiring a hard upgrade. However, this may be
revisited in the future.

### Transitions

Networks would be expected to announce upgrades in advance allowing a window for
node operators to upgrade to a software version of Tendermint that would
comply with the announced block protocol upgrade. This can be done
asynchronously with node operators temporarily halting their node, changing to
the new binary and starting up again. Tendermint could also offer a tool to
easily swap between binaries thus reducing the amount of down-time that nodes
experience although this is outside the scope of this RFC.

The actual switch would occur in the same manner as an App Version change, using
the `EndBlockResponse{}` ABCI call to indicate to Tendermint that a different
block protocol be used. In the case that a node failed to upgrade, the node
would gracefully stop and error.

Given the delayed execution model, careful consideration would be needed to
ensure that the nodes could transition smoothly. It may be that the actual
upgrade might not take place till height: h + 2.

As we expect upgrades to always increment the block version by one, rather
than having the version number being passed in `EndBlockResponse{}`, another
option could be to have the height where we want the upgrade to occur. With this
approach validators are not reaching consensus on the version but the window of
time (as a height) that nodes will have to perform or prepare for the upgrade.

We will now cover the two main methods of executing a soft upgrade.

## Method 1: Multi Data Structure Support

This would require Tendermint to support all prior block protocol version since
the last hard fork. This would be done by somehow finding what the version of
the structure is and processing it accordingly. This mimics a similar design
model to the Cosmos SDK where all legacy code is stored in the repository and
conditionals are used to indicate how messages are processed.

One could imagine a directory structure for each module as
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
`BlockExecutor` are structs outside of the block protocol so would be
internalized to allow for changes (so long as this wouldn't change the overall
behavior).

### Current Use of Versioning

Records of versions are currently stored in `State` and in the `Header` of each
block. This already covers a broad base of scenarios. The consensus reactor can
use the version from state to ensure it reads `Vote`s and `Partsetheader`s
correctly. Similarly, fast sync, the block executor and evidence module, whom
all interact with block protocol data structures also all have access to state.
The next few sections will explore the aspects of Tendermint that will need to
be modified to prepare for multi versioning support.

### RPC

Supporting soft upgrades means that the RPC will need to be able to deliver
information across different versions. The RPC will therefore need to know which
heights corresponds to which version and then be able to communicate this to
the clients. This would most likely require clients to be versatile to handling
the different block versions unless it was possible for the data to be
transformed to an earlier version. For example, block explorers would also take
on the burden of supporting all block versions across a chain. Clients would
indicate the latest version they support in the RPC call itself e.g.
`/v3/block?height=100`. The node would know what version the block at height 100
was. If it was greater than v3 it would return a version error indicating the
version the block explorer would need to support. If it was less or equal to v3
then it would return the block (which contains version information).

### Light Clients

Similar to RPC, light clients will also need to be wary of block protocol
changes and be able to handle them accordingly. Depending on these changes,
there might be the need for special verification logic across signed headers
with different versions. If a light client bisected to a height where it didn't
have the version it would return an error.

### Implications

**Positive:**

- It requires no changes to the database therefore keeps the immutable aspect
  of the blockchain.
- Async upgrading. Nodes choose when they want to upgrade the binary and
Tendermint handles the actual transition.

**Negative:**

- Increased burden on RPC clients to be able to parse multiple versions.
- Bloating of code base and binary. We would also need to figure out methods
of maintaining good code hygiene with respect to having all these versions.
- If we separate versions i.e. ABCI and Block and P2P this could potentially
compound the problem if we need to consider the different permutations and
how they can be supported. Correctness analysis and proper testing would be
required to mitigate errors.


## Method 2: Chain Migration

Chain migration might sound counter intuitive in the context of an immutable
blockchain; any change to a block would simply break the hashes.
This would then make the signatures for each block invalid and the whole thing
would just fall apart. Chain migration, however, would mean that the network
only supports a single version at a time which would greatly simplify things.

The general strategy for a chain migration would be to get the validator set at
the height of the migration to not finalize the last block but to instead
finalize the entire migration of all blocks from a prior version to the new
version.

![Chain Migration](images/chain-migration.png)

Practically speaking, this would mean that `LastBlockID` ( The blue arrow at
height h) wouldn't be the hash of the last block but the hash of the newly
migrated block (v2 at height h - 1). This would tie in with the migrated block
before it and the block before that all the way down to
genesis (or essentially the entire migration).

To achieve this, migration would start at height 1 and form the new block.
It would then increment to the next height and take the original block plus the
hash of the migrated block at the height below (as we can see with the green
arrows).

The problem with this is that new nodes and light
clients which aren't at consensus and don't know what the original blocks were
would not be able to safely verify the derived blocks because the signatures
(the red lines) only link between the original versions (V1). This outlines
some basic imperatives with chain migration.

### Imperatives

- All state modifying data from the original block must be preserved
- Light client and fast sync verification models must be unaffected

### Simple Approach

One basic approach is that each derived version should be capable of producing
its original i.e. If the chain is at version 4 and a node is fast syncing and is
at block 100 which corresponds originally to version 2 then when it receives a
derived block (at v4) it should be able to extract out the original (v2) for
verification. However, the derived block should also reflect the structure of
the latest version.

The shortcomings of this is that we would expect the derived block stored to be
larger than normal as it needs to hold the relevant data for both. This would go
against a lot of the proposed plans on the horizon which would aim to reduce the
overall size of the block's components. Verification would take a little longer
but we wouldn't need to worry about any byzantine behavior (either the derived
block can produce the original block or it can't).

### Advanced Approach

There is a second more complicated approach in which we don't need to be able to
rebuild the original block to verify all the way up to the migration height.
Currently we have what can be seen as a core verification path. These are a set
of fields or features that are essential for Tendermint's verification process.
This allows a node to be able to trust a header. The header is then filled with
whatever other hashes that allows the node to verify the other components i.e.
data, evidence, last commit, consensus, app. This guarantees state replication.

To quickly recap how verification works we start with a trusted validator set.
From this we search for a commit and header that correlates to the height
directly above our current state. We rebuild the votes from the commit and
verify that the signatures are all for the hash of the header we received by
calling `VerifyCommit`:

```go
func (vals *ValidatorSet) VerifyCommit(chainID string, blockID BlockID,
	height int64, commit *Commit) error
```

We can then trust the header and therefore trust the rest of the block.
Then Tendermint delivers the txs to the application which will in turn update
the validator set (with an extra height delay). We use NextValidatorsHash to
verify that we have the correct trusted validator set for the next height.

If we were to migrate data to a new block, then we could copy the original
blockID across. This would mean that we could verify this BlockID but we would
not be able to trust the rest of the contents of the header / block which means
we wouldn't be able to know whether the state transition was correct or if the
new validator set could be trusted (which is critical to continue verification).

A solution to this would be as follows:

We have a block that has a set of unalterable fields. They can't change and are
essential to the core verification path.

```go
type Block {
	...
	DerivedBlockHash // derives from the original block that was signed by
									 // the validator set
	NextValidatorHash
  AppHash
	...
	LastBlockID // This refers to the migrated block header not the original
	LastCommit // or anything that houses the signatures
	...
}
```

I'm assuming the following relationship:

```go
f(DerivedBlockHash, AppHash, NextValidatorHash) = Hash of the original header
```

Part of the migration script would then be to calculate this `DerivedBlockHash`
or if it was the migration of an already migrated block then just to carry it
across.

Verification would be as follows:

1. Starting from a trusted validator set (this could be from genesis)
2. Grab the migrated block at the next height or more specifically the
signatures, next validator hash, app hash and derived block hash
3. Calculate the original header hash that the signatures should be signing with
the next validator hash, app hash and the derived block hash.
4. Check that the LastBlockID is equal to the hash of the trusted header
(no need to check this is height is 1)
5. Verify that 2/3 signed the original header hash by running `VerifyCommit`.
If no error then we can trust at least that the original block ID is correct and
thus, based on the collision probability of hashes, also assume that we can
trust the `NextValidatorHash` and the `AppHash`.
6. Apply block to current state to get the new state.
7. Check that the state's `ValidatorHash` (at height + 1 now) matches the
`NextValidatorsHash`. If so it means we can trust the new validator set. Check
that the `AppHash` matches. This means that application state is also correct.
If one of these doesn't match we drop the block and peer and continue looking
for another. (Remember light clients only have `NextValidatorHash` and have no
record of app state)
8. Go back to 1 and recur until we reach a point where the `DerivedBlockHash`
is nil. This indicates the crossover from the migrated blocks to the original
ones.
9. When validating this block we return to the normal verification process.
This means that instead of using the `DerivedBlockHash` we take the signatures
in the commit and verify it against the hash of the entire header.
This means that we not only trust the `NextValidatorHash` and `AppHash` but can
trust the entire header. This includes LastBlockID.
10. Verify that LastBlockID equates to the hash of the last migrated block. If
this is equal then we have essentially verified the entire migration history and
we can trust that the state transitions that have been applied are correct.
11. Proceed as normal until the node can switch to consensus.

Another way of viewing `DerivedBlockHash` is as the remnants of the hashes/data
in the old header that we don't want to bring across because we have changed it.

In terms of the actual upgrade, when consensus is reached on a block that causes
the block version to increment, the next block proposed should not only have the
new block structure but the LastBlockID should be that of the migrated block not
the original one. This means that before the next block of the new version can
be agreed upon everyone participating in consensus must have migrated the entire
history in order to generate the "golden hash", the cumulative hash of the
migrated history. If this is three years of blocks this migration could take a
long time before consensus can continue hence it's probably an important aspect
to attempt to make migration asynchronous so nodes already know this golden hash
before the upgrade actually happens.

This could be done by executing a migration script that works "offline" by
iterating through the block store and making copies of the new header only so
that nodes know what the migrated header hash would be and when consensus
reached the upgrade height, could smoothly transition to the newly migrated
blocks

### Implications

**Positive**

- The network only needs to concern itself with the latest block version
- Some migrations would be backwards compatible meaning we could restore the
prior block version. This would allow external clients on prior block versions
to still be able to process the blocks.
- Async upgrading. Nodes choose when they want to upgrade the binary and
Tendermint handles the actual transition.
- In the future it may be possible to support application migrations. This is
where the application can upgrade the Tx data structures. Generally, this option
might offer a broader set of changes that can be soft upgraded.

**Negative**

- Nodes may have to go through millions of blocks requiring extra memory and
computation over the transition phase
- External clients would most likely need to support both block versions over
the transition period
- Bootstrapping nodes and light clients require an extra step for verification.
- We've cornered off some untouchable fields in the block structure. If we
really wanted to change these we would need a hard upgrade.
- There is greater risk to correctness in the migration logic.

## Status

Proposed

## References

- [Upgrade tooling tracking issue](https://github.com/tendermint/tendermint/issues/5595)
- [Protocol versions](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-016-protocol-versions.md)

## Appendix A: Upgrade terminology

It's important to define upgrades and classify the distinctions so as to ensure
that everyone has the same understanding of what it means and that we can use
the same terminology to speak about the different concepts. This appendix aims
at achieving this.

An upgrade, in the loosest sense, is a change to the Tendermint codebase. For
simplicity to users, we group changes together and form releases. Every release
corresponds to a unique software version. Tendermint follows SemVer which
has strict rules about versioning and makes a distinction between different
types of releases.

From the node operators perspective, upgrades just mean, stopping the node,
changing the binary and starting the node again.

A patch release (the last number in x.x.x), is a backwards compatible bug-fix.
Nodes should be able to perform this upgrade at any time without any affect to
the network.

A minor release (the middle number in x.x.x), is also backwards compatible but
it indicates changes in existing features or new features. One can think of
performance optimizations as a good example. Nodes should also be able to
perform this upgrade at any time and nodes with different minor versions should
have no problem interacting with one another.

We call the above two releases as constituting minor upgrades.

A major release (the first number in x.x.x), is a set of incompatible changes.
This means that the public api has changed and/or the messages that nodes send
to one another and persist to disk have changed in a way that is incompatible
with prior releases. A block protocol change is always a major release.

When this happens nodes can't simply stop and restart when they want but must
coordinate a restart together. There can't be nodes with different versions on
the same network. Not only this, but upgraded nodes can't read nor verify data
structures from a prior major version. Thus, an upgrade for a major release
has so far meant having to create a new chain.

Soft and hard upgrades both refer to major releases but have very different
properties.

A soft upgrade like minor upgrades can happen asynchronously across the
network. They are initiated by the application and coordinated by Tendermint's
consensus mechanism. In one way or another they allow the chain to remain fully
accessible and verifiable to the nodes with the latest version. In the context
of this RFC, an example of a soft upgrade could be the removing of timestamps
in the commit sig.

A hard upgrade must be initiated and coordinated socially. The latest versioned
node is incapable of parsing and/or verifying the previous versioned data
structures. Once could imagine a wall between the chain of blocks. An example of
a hard upgrade in the context of this RFC could be switching from delayed
execution to immediate execution.
