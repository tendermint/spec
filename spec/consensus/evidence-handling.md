# Evidence handling

## Fork

We define a fork as a case in which an honest process (validator, full node or lite client)
observed two commits for different blocks at the same height of the blockchain.

```go
    type SignedHeaderWithValidatorSet struct {
      Header        Header
      Commit        Commit
      Validators    ValidatorSet
    }

    type Fork {
      Left           SignedHeaderWithValidatorSet
      Right          SignedHeaderWithValidatorSet
    }
```

## Slashable fork

From the crypto economics perspective, the only interesting forks are those that involve bonded validators.
Note that previous (informal) definition would be satisfied by two blocks that are correctly signed
by random processes that have never participated as validators in Tendermint blockchain.
These kinds of “forks” are of no interest for the fork accountability protocol we are discussing here.

Therefore we define a notion of *slashable fork* which is informally defined as a fork in which bonded
validators misbehaved. To define this notion more precisely, we assume that there exists a main chain C (sequence of blocks),
and assume that there is a set of bonded validators *BD(t)* that consists of all bonded (slashable) processes
(current and old validators) at time t.

Then a slashable fork at some time t corresponds to the existence of a
commit for some block B at height h (```B.Header.Time <= t```) that is different from a block at height h of the chain C.
Furthermore, a commit for the block B contains at least a single valid signature from a process that is part of the set *BD(t)*.

```go
  func isSlashable(h, t) bool {
    bd = BD(t) // bonded validators at time t
    if signers(h.Commit) contains at least single process from bd
        return true
    return false
  }
```

Note that detecting if a fork is slashable requires knowledge of the set of bonded validators on the main chain at a given point in time.
This information is known only by correct full node(s). Therefore classifying if fork is slashable can be done
at the correct full node or at the lite client in case this information is provided by full nodes over RPC.
As part of fork processing protocol, a full node will need to check if a fork is slashable but having this done also
at the lite client can reduce amount of processing at the full node by dropping forks that are not slashable.

TODO: Understand if it would be possible determining what is BD(t) at the lite client based on local
information (set of trusted headers)? In case of skipping header verification, it seems that this is not possible.

## Main chain forks vs lite client detected forks

We define a fork on the main chain as the fork that is observed by a full
node as part of normal Tendermint consensus and fast sync protocol execution.
In this case a node panics and resorts to social-consensus driven fork accountability protocol.
In case a (correct) full node detects a fork as part of interaction with the lite client (an “external” process in this context),
a node does not panic, but instead executes on-chain fork accountability protocol (described below).
In this case a fork is handled by evidence reactor and it is therefore not propagated as part of normal consensus protocol.

TODO: Check (at the code level) what are parts of the protocol(s) where we check for forks in real time.

## Individual evidence

For all types of individual evidences we can also talk about slashable evidence in case misbehaving process is part
of BD at given time t (time of evidence detection).

- EquivocationEvidence:

Given a fork F and assuming that left branch corresponds to the canonical chain, we define equivocation evidence as follows:
- if exists a validator v such that v is part of F.Left.Validators and F.Right.Validators, and v signed F.Left.Header and F.Right.Header,
where F.Left.Header != F.Right.Header, then equivocation evidence consists of Precommit messages signed by v.

```go
    type EquivocationEvidence struct {
      LeftPrecommit          Vote
      RightPrecommit         Vote
    }
```

- PhantomValidatorEvidence:

Given a fork F and assuming that left branch corresponds to the canonical chain, we define equivocation evidence as follows:
- if exists a validator v such that v is part of F.Right.Validators but not part of F.Left.Validators, and v signed F.Right.Header,
then phantom validator evidence consists of Precommit message signed by v.

```go
    type PhantomValidatorEvidence struct {
      Precommit          Vote
    }
```

- LunaticValidatorEvidence:

Given a block B at height H which corresponds to application state S (execution of transactions from block B leads to application state S),
lunatic validator evidence is a case when exists a validator v such that v is part of F.Left.Validators and F.Right.Validators, and v signed F.Right.Header,
such that and F.Right.Header.AppHash != F.Left.Header.AppHash or F.Right.Header.Validators != F.Left.Header.Validators or
F.Right.Header.NextValidators != F.Left.Header.NextValidators or F.Right.Header.ConsensusParams != F.Left.Header.ConsensusParams.

Lunatic validator evidence consists of Precommit message signed by v.

```go
    type LunaticValidatorEvidence struct {
      Precommit          Vote
    }
```

Processing of these three types of misbehavior does not require access to global system state: every correct full node can confirm that this is misbehavior just by
looking at content of the evidence and its local state.

## Global evidence

By global evidence we refer to a misbehaviour that cannot be confirmed just by looking at the local full node state.

Given a fork F and assuming that left branch corresponds to the canonical chain, we define global evidence as follows:
- if exists a validator v such that v is part of F.Left.Validators and F.Right.Validators, and v signed F.Right.Header,
then either v signed F.Left.Header and F.Left.Header.Round != F.Right.Header.Round or v hasn't signed F.Left.Header.

Note that in this case votes signed by v are not proof of misbehaviour as they can also correspond to a valid
execution. Therefore, we need a whole commit as part of global evidence so we can justify triggering global
fork accountability procedure.

```go
    type GlobalEvidence struct {
      Commit          Commit
    }
```


## Gossiping of evidences




