# Evidence handling

## Fork

We define a fork as a case in which an honest process (validator, full node or lite client)
observed two (valid) commits for different blocks at the same height of the blockchain.

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

    type Commit struct {
    	Height     int64
    	Round      int
    	BlockID    BlockID
    	Signatures []CommitSig
    }
```

For the purpose of this specification we assume the following auxiliary functions:
```go
// returns true if vote contains valid signature (assume signature verification); otherwise false
func isValid(vote Vote, blockId BlockID) bool

// returns Vote by validator that is part of the Commit; otherwise returns nil
func getVote(commit Commit, validator Address) Vote

```


## Slashable fork

From the crypto economics perspective, the (only) interesting forks are those that involve bonded validators.
By bonded validator we assume a validator (in the current validator set or that was validator in some of the
previous validator sets) whose stake is still bonded in the system. Note that the definition of fork (above)
is satisfied also in case there are two headers that are correctly signed by processes that have never participated
as validators in Tendermint blockchain, and therefore don't have any stake in the system.
These kinds of “forks” are of no interest for the fork accountability protocol we are discussing here.

Therefore we define a notion of `slashable fork` which is informally defined as a fork in which bonded
validators potentially misbehaved. To define this notion more precisely, we assume that there exists a main chain `C` (sequence of blocks),
and assume that at any point in time `t`, where `t` corresponds to the [BFT time](bft-time.md), there is a set of bonded
validators `BD(t)` that consists of all bonded (slashable) processes (current and old validators) at time `t`.

Then a slashable fork at time `t` corresponds to the existence of a
commit for some block `B` at height `h` (`B.Header.Time <= t`) that is different from a block at height `h` of the chain `C`.
Furthermore, a commit for the block `B` contains at least a single valid signature for the block `B` at height `h` from a process
that is part of the set `BD(t)`. Note that slashable fork does not necessarily mean that a bonded validator executed invalid transition;
on the other side if a fork is not slashable then the fork does not contain elements that indicate invalid transitions of
bonded validators, so there is no justification for further processing.

The function `isSlashable` illustrates how the check if a fork is slashable (or not) can be computed.

TODO: Should this check be done as part of evidence creation?

```go
// we assume that fork.Left is canonical header and fork.Right is suspected
func isSlashable(fork Fork, bd []Validator) bool {
    canonicalCommit = fork.Left.Commit
    suspectedCommit = fork.Right.Commit

    for every v in bd {
        vote = getVote(suspectedCommit, v.Address)
        if vote != nil AND
           vote.BlockID != nil AND
           vote.BlockID != canonicalCommit.BlockID AND
           isValid(vote) {

            return true
        }
    }
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
In this case a node panics and resorts to social-consensus driven [fork accountability](fork-accountability.md) protocol.
In case a (correct) full node detects a fork as part of interaction with the lite client (an “external” process in this context),
a node does not panic, but instead executes on-chain fork accountability protocol (described below).
In this case a fork is handled by evidence reactor and it is therefore not propagated as part of normal consensus protocol.

TODO: Check (at the code level) what are parts of the protocol(s) where we check for forks in real time.

## Individual vs global evidence types

Existence of slashable fork at some height `h` implies that some validators from the validator set at the height `h` misbehaved,
i.e., diverged from the correct Tendermint protocol transitions. Depending on the nature of invalid transitions we
differentiate between `individual` and `global` evidences. In case of `individual` evidence the corresponding invalid transition
can be captured (and verified) based solely on a (faulty) process observable actions. On the other side, in case of
`global` evidence proving invalid transitions requires access to the observable actions for the corresponding height of the
complete validator set.

## Individual evidence types

There are three individual evidence types in Tendermint: equivocation evidence, phantom validator evidence and
lunatic validator evidence. For all types of individual evidences we can also talk about slashable evidence
in case misbehaving process is part of `BD(t)` at the given time `t` (time of evidence detection).
TODO: Be more precise regarding timing assumptions.

We now define each of those evidence types.

### Equivocation evidence

Given a fork `F` and assuming that left branch corresponds to the canonical chain, we define equivocation evidence as
existence of valid signatures in the left and right commits for the same height and round but for a different block id.
The function `createEquivocationEvidence` captures necessary checks in order to extract equivocation evidence for a given
fork and a validator. This evidence corresponds to invalid protocol transition as according to the
Tendermint consensus specification a process should create (and sign) at most one vote for a given height, round and vote type.

```go
    type EquivocationEvidence struct {
      LeftPrecommit          Vote
      RightPrecommit         Vote
    }

func createEquivocationEvidence(fork Fork, validator Address) EquivocationEvidence {
    canonicalCommit = fork.Left.Commit
    suspectedCommit = fork.Right.Commit

    canonicalVote = getVote(canonicalCommit, validator)
    suspectedVote = getVote(suspectedCommit, validator)

    if canonicalVote != nil AND suspectedVote != nil AND
       canonicalVote.Type == suspectedVote.Type AND
       canonicalVote.Height == suspectedVote.Height AND
       canonicalVote.Round == suspectedVote.Round AND
       canonicalVote.BlockID != suspectedVote.BlockID AND
       isValid(canonicalVote) AND
       isValid(suspectedVote) {

            return EquivocationEvidence(canonicalVote, suspectedVote)
    }
    return nil
}
```

### Phantom validator evidence

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




