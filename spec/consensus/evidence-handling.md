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
    	Height         int64
    	Round          int
    	BlockID        BlockID
    	Signatures     []CommitSig
    }

    type BlockID struct {
        Hash           []byte
        PartsHeader    PartSetHeader
    }

    type Validator struct {
        Address        Address
        PubKey         crypto.PubKey
        VotingPower    int64
    }

```

The following invariants hold for every `valid` fork:

```go

func isValidFork(fork Fork) bool {
    leftHeader := fork.Left.Header
    rightHeader := fork.Right.Header

    return leftHeader.Height == rightHeader.Height AND
           leftHeader != rightHeader AND
           isValid(fork.Left) AND isValid(fork.Right)
}

func isValid(shWithValset SignedHeaderWithValidatorSet) bool {
    header := shWithValset.Header
    commit := shWithValset.Commit
    validators := shWithValset.Validators
    vp := validators.TotalVotingPower

    return hash(header) == commit.BlockID.Hash AND
           header.ValidatorsHash == hash(validators) AND
           votingPower(signers(commit, validators), validators) > 2/3 * vp
}

```


For the purpose of this specification we assume the following auxiliary functions:
```go
// returns true if vote contains valid signature (assume signature verification); otherwise false
func isValid(vote Vote, validator Validator) bool

// returns Vote by validator that is part of the Commit; otherwise returns nil
func getVote(commit Commit, validator Address) Vote

// returns validator for a given address if exists; otherwise returns nil
func getValidator(valset ValidatorSet, validator Address) Validator

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

Given a fork `F`, we define equivocation evidence as an existence of valid signatures in the left and right commits
for the same height and round, but for a different value. The function `createEquivocationEvidence` captures
necessary checks in order to extract equivocation evidence for a given fork and a validator. This evidence corresponds
to an invalid protocol transition as according to the Tendermint consensus specification a process should create
(and sign) at most one vote for a given height, round and vote type.

```go
    type EquivocationEvidence struct {
      LeftPrecommit          Vote
      RightPrecommit         Vote
      Validator              Validator
    }

func createEquivocationEvidence(fork Fork, valAddress Address) EquivocationEvidence {
    leftCommit = fork.Left.Commit
    rightCommit = fork.Right.Commit

    validator = getValidator(fork.Left.Validators, valAddress)
    if validator == nil {
        validator = getValidator(fork.Right.Validators, valAddress)
    }
    if validator == nil { panic("Validator does not exist") }

    leftVote = getVote(leftCommit, valAddress)
    rightVote = getVote(rightCommit, valAddress)

    if leftVote != nil AND rightVote != nil AND
       leftVote.Height == rightVote.Height AND
       leftVote.Round == rightVote.Round AND
       leftVote.BlockID != rightVote.BlockID AND
       isValid(leftVote, validator) AND
       isValid(rightVote, validator) {

          return EquivocationEvidence(leftVote, rightVote, valAddress)
    }
    return nil
}
```

### Phantom validator evidence

Given a fork `F` and assuming that left branch corresponds to the canonical chain, we define phantom validator
evidence as follows: if exists a validator `v` such that `v` is not part of `F.Left.Validators` and `v`
signed `F.Right.Commit`. The phantom validator evidence consists of `Precommit` message and a validator address of the
validator that signed it; this is sufficient for every correct full node to check that a validator wasn't
part of the validator set for the given height and that vote is indeed signed by this process. The function
`createPhantomValidatorEvidence` captures necessary checks in order to extract phantom validator evidence
for a given fork and a validator.

```go
    type PhantomValidatorEvidence struct {
      Precommit          Vote
      Validator          Validator
    }

func createPhantomValidatorEvidence(fork Fork, valAddress Address) PhantomValidatorEvidence {
    canonicalValset = fork.Left.Validators
    rightCommit = fork.Right.Commit

    validator = getValidator(fork.Right.Validators, valAddress)
    if validator == nil { panic("Validator does not exist") }

    vote = getVote(rightCommit, valAddress)

    if getValidator(fork.Left.Validators, valAddress) == nil AND
       vote != nil AND isValid(vote, validator) {
          return PhantomValidatorEvidence(vote, valAddress)
    }
    return nil
}
```

### Lunatic validator evidence

Given a block `B` at height `H` at the canonical chain, which corresponds to the application state `S`
(execution of transactions from the block `B` leads to the application state `S`), lunatic validator evidence
is a case in which a validator `v` signed vote for a block `B' != B` such that
`B.Header.AppHash != B'.Header.AppHash` or `B.Header.Validators != B'.Header.Validators` or
`B.Header.NextValidators != B'.Header.NextValidators` or `B.Header.ConsensusParams != B'.Header.ConsensusParams`.

Lunatic validator evidence consists of `Precommit` message and the validator that has signed it. The function
`createLunaticValidatorEvidence` captures necessary checks in order to extract lunatic validator evidence
for a given fork and a validator.

```go
    type LunaticValidatorEvidence struct {
      Precommit          Vote
      Validator          Validator
      Header             Header
    }

func createLunaticValidatorEvidence(fork Fork, valAddress Address) LunaticValidatorEvidence {
    canonicalHeader = fork.Left.Header
    otherHeader = fork.Right.Header

    if canonicalHeader.AppHash == otherHeader.AppHash AND
       canonicalHeader.Validators == otherHeader.Validators AND
       canonicalHeader.NextValidators == otherHeader.NextValidators AND
       canonicalHeader.ConsensusParams == otherHeader.ConsensusParams {

            return nil
    }

    validator = getValidator(fork.Right.Validators, valAddress)
    if validator == nil { panic("Validator does not exist") }

    vote = getVote(rightCommit, valAddress)

    if vote != nil AND isValid(vote, validator) {
        return LunaticValidatorEvidence(vote, validator, otherHeader)
    }
    return nil
}
```

Processing of these three types of misbehavior does not require access to the global system state: every correct full node
can confirm that this is misbehavior just by looking at the content of the evidence and its local state.

## Global evidence

By global evidence we refer to a misbehaviour that cannot be confirmed just by looking at the local full node state.

Given a fork F and assuming that left branch corresponds to the canonical chain, we define global evidence as follows:
if exists a validator v such that v is part of F.Left.Validators and F.Right.Validators, and v signed F.Right.Header,
then either v signed F.Left.Header and F.Left.Header.Round != F.Right.Header.Round or v hasn't signed F.Left.Header.

Note that in this case votes signed by v are not proof of misbehaviour as they can also correspond to a valid
execution. Therefore, we need a whole commit as part of global evidence so we can justify triggering global
fork accountability procedure.

```go
    type GlobalEvidence struct {
      Commit          Commit
    }
```







