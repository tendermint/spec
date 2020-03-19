# Failure Detection

If there are more than 1/3 (or more) faulty validators, safety may be violated.
This document describes how the light client can detect such violations (after
the fact) and the next steps.

## 1. Detection

The bare minimum requirement is to be connected to at least one honest full
node. This is sufficient so long as there's no fork on the main chain.

If there is a fork on the main chain, it means that two full nodes have decided
on two different headers for the same height. Then the requirement would at
least require that the lite client is connected to one honest full node on
each branch of the fork.

_Remark_: +1/3 of malicious validators can create an unlimited number of forks.

In practice, this means connecting to 1 or more geographically distributed full
nodes (called **witnesses**), which belong to different companies. Note this
number does not include the primary full node (called primary), which is used
for obtaining new headers.

_Remark_: we can't guarantee all witnesses won't follow the same branch of a
fork. to guarantee that, we'll need the light client to be connected to +1/3 of
nodes, which is impossible (_the structure of the network where validators are
hidden behind sentries makes this impossible_).

Full nodes are much more connected. And, if we assume a correct full node is
going to halt in case of a fork on the main chain, then **we only need to
notice that fact**.

After the light client verifies a new header (`H`) it received from primary, it
should cross-check `H` with the headers from all witnesses. Cross-checking
means comparing hashes of the headers. If any two hashes (or more) diverge,
there's a fork (on the main chain OR phantom fork targeting this light client).

The light client will then need to validate the header it got from a witness
(`H1`) and verify the signers account for +1/3 of the voting power.

- if verification fails, this is a faulty full node (2.1).
- if verification succeeds, we have a successful +1/3 attack (2.2).

## 2. Error modes

1. Faulty full node: mark them as bad and stop talking to them, but otherwise
   continue.
2. Successful +1/3 attack: submit evidence and halt, wait for human
   intervention.

### 2.1 Faulty full node

A faulty full node might send the light client a conflicting header (`H2`) that
does not fully verify but does contain say a double sign from a validator.
Technically there is a faulty validator in here, but they would just go
unpunished (NOTE: subject to a change).

### 2.2 Successful +1/3 attack

If a conflicting header (`H2`) is signed by +1/3 of the voting power, it means
there's at least one correct validator on both branches (`H1` and `H2`).

Since there is no way for the light client to detect who's lying to it (which
full node - primary or one of the witnesses), it must form an evidence and
submit it to all connected full nodes (witnesses and primary). The evidence
will typically contain a set of diverged headers (including the commits).

After doing so, the light client must stop its operation. The operator will be
forced to reset the light client (resetting does not imply deleting the data
here) with a new trusted header.

## 3. Data Structures

```go
type ConflictingHeadersEvidence struct {
  H1 SignedHeader
  H2 SignedHeader
}
```

`ConflictingHeadersEvidence` contains two diverged headers, both signed by 1/3+
of the validator set that the full node had at height `H1.Height-1` (`H0`).

SignedHeader is a combination of the Header and the Commit that proves it.

Validity predicate:

```
H1.Hash() != H2.Hash() && H1.Height == H2.Height
      && signers(H1) > 1/3 * totalPower(valSet(H0))
      && signers(H2) > 1/3 * totalPower(valSet(H0))
```

## 4. Processing

Let's say H1 was committed from this full node's perspective (see Appendix A).
Intersect validator sets of H1 and H2.

* if there are signers(H2) that are not part of validators(H1), they misbehaved as
they are signing protocol messages in heights they are not validators =>
immediately slashable (#F4).

* if `H1.Round == H2.Round`, and some signers signed different precommit
messages in both commits, then it is an equivocation misbehavior => immediately
slashable (#F1).

* if `H1.Round != H2.Round` we need to run full detection procedure => not
immediately slashable.

* if `ValidatorsHash`, `NextValidatorsHash`, `ConsensusHash`,
`AppHash`, and `LastResultsHash` in H2 are different (incorrect application
state transition), then it is a lunatic misbehavior => immediately slashable (#F5).

If evidence is not immediately slashable, fork accountability needs to invoked
(spec needs to be written).

In parallel with processing, the evidence needs to be gossiped to other nodes.

Before we commit however, evidence needs to be broken up in pieces:

### F1. Equivocation

```go
type DuplicateVoteEvidence struct {
  VoteA  Vote
  VoteB  Vote
}
```

### F4. Phantom validators

```go
type PhantomValidatorEvidence struct {
  Header Header
  Vote Vote
}
```

It contains a header and a vote for the associated block, where this validator
is not part of the validator set.

### F5. Lunatic validator

```go
type LunaticValidatorEvidence struct {
  Header Header
  Vote Vote
}
```

It contains a header and a vote for the associated block, where the header was
not generated by Tendermint consensus (AppHash, ValidatorsHash are a result of
invalid state transition).

### F2. Amnesia

When a full node can't detect who's broken the rules, fork accountability
procedure needs to be run.

```go
type PotentialAmnesiaEvidence struct {
  Header Header
  Votes []Vote
}
```

Votes of validators with a slashable behaviour are not included.

After the evidence of the amnesia attack is received (either by observing
violation or refusal to provide the information), a new type of evidence must
be created:

```go
type AmnesiaEvidence struct {
  Round1 uint
  Prevotes []Vote
  Precommits []Vote

  Round2 uint
  Prevotes []Vote
  Precommits []Vote
}
```

## Appendix A

If there is an actual fork (full fork), a full node may follow either one or
another branch. So both H1 or H2 can be considered committed depending on which
branch the full node is following. It's supposed to halt if it notices an
actual fork, but there's a small chance it doesn't.
