*** This is the beginning of an unfinished draft. Don't continue reading! ***

# Lightclient Attackers Isolation

In the case of an [attack][node-based-attack-characterization], the lightclient [attack detection mechanism][detection] computes data, so called evidence [[LC-DATA-EVIDENCE.1]][LC-DATA-EVIDENCE-link], that can be used 
- to proof that there has been attack [[TMBC-LC-EVIDENCE-DATA.1]][TMBC-LC-EVIDENCE-DATA-link] and 
-  as basis to find the actual nodes that deviated from the Tendermint protocol. 

As Tendermint consensus is safe under the assumption of more than 2/3 of correct voting power per block [[TMBC-FM-2THIRDS]][TMBC-FM-2THIRDS-link], this implies that if there was an attack then [[TMBC-FM-2THIRDS]][TMBC-FM-2THIRDS-link] was violated, that is, there is a block such that 
- validators deviated from the protocol, and 
- these validators represent more than 1/3 of the voting power in that block.


This specification considers how a full node in a Tendermint blockchain can isolate a set of attackers that launched the attack. The set should satisfy
- the set does not contain a correct validator
- the set contains validators that represent more than 1/3 of the voting power of a block that is still within the unbonding period


# Outline

TODO

# Part I - Tendermint Blockchain

TODO
- lightblocks
- tendermint properties

# Part II - Definition of the  Problem

The specification of the [detection mechanism][detection] specifies 
- what is a light client attack,
- conditions under which the detector will detect a light client attack,
- and the format of the output data, called evidence, in the case an attack is detected. The format is defined in
[[LC-DATA-EVIDENCE.1]][LC-DATA-EVIDENCE-link] and looks as follows

```go
type LightClientAttackEvidence struct {
    ConflictingBlock   LightBlock
    CommonHeight       int64
}
```

The isolator is a function that gets as input evidence `ev`
and a prefix of the blockchain `bc` at least up to height `ev.ConflictingBlock.Header.Height + 1`. The output is a set of *peerIDs* of validators.

**TODO:** should we capture that the blockchain hasn't reached `ev.ConflictingBlock.Header.Height + 1` yet?

#### **[FN-INV-Output.1]**
When an output is generated it satisfies the following properties: 
- If
    - `bc[CommonHeight].bfttime` is within the unbonding period, 
    - `ev.ConflictingBlock.Header != bc[ev.ConflictingBlock.Header.Height]`
    - Validators in `bc[CommonHeight].NextValidators` represent more than 1/3 of the voting power in `ev.ConflictingBlock.Commit`
- Then: A set of validators in `bc[CommonHeight].NextValidators` that
    - represent more than 1/3 of the voting power in `bc[CommonHeight].NextValidators`
    - signed Tendermint consensus messages for height `ev.ConflictingBlock.Header.Height` by violating the Tendermint consensus protocol.
    - the stake according to their voting power at height `ev.CommonHeight` is still bonded
- Else: the empty set.


# Part IV - Protocol

> Overview

**TODO:** discuss what happens in this spec, and that we discuss soundness in Part V

## Isolation

### Outline

> Describe solution (in English), decomposition into functions, where communication to other components happens.

```go
func detectMisbehavingProcesses(ev LightClientAttackEvidence, bc Blockchain) []ValidatorAddress {
    
    reference := bc[ev.conflictingBlock.Header.Height].Header
    ev_header := ev.conflictingBlock.Header

    ref_commit := bc[ev.conflictingBlock.Header.Height + 1].Header.LastCommit // + 1 !!
    ev_commit := ev.conflictingBlock.Commit

    if violatesTMValidity(reference, ev_header) {
        // lunatic light client attack
        signatories := Signers(ev.ConflictingBlock.Commit)
        bonded_vals := Addresses(bc[ev.CommonHeight].NextValidators)
        return intersection(signatories,bonded_vals)

    } 
    else if RoundOf(ref_commit) == RoundOf(ev_commit) {
        // equivocation light client attack
        return intersection(Signers(ref_commit), Signers(ev_commit))
    } 
    else {
        // amnesia light client attack 
        HandleAmnesiaAttackEvidence(ev, bc)
    } 
}
```
- Expected precondition
    - `ValidAndVerifiedUnbonding(bc[ev.CommonHeight], ev.ConflictingBlock) == SUCCESS`
    - `ev.ConflictingBlock.Header != bc[ev.ConflictingBlock.Header.Height]`
- Expected postcondition
    - [[FN-INV-Output.1]](#FN-INV-Output1) holds
- Error condition 
    - returns `INVALID_EVIDENCE`


### Details of the Functions

```go
func ValidAndVerifiedUnbonding(trusted LightBlock, untrusted LightBlock) Result
```
- Conditions are identical to [[LCV-FUNC-VALID.2]][LCV-FUNC-VALID.link] except the precondition "*trusted.Header.Time > now - trustingPeriod*" is substituted with
    - `trusted.Header.Time > now - UnbondingPeriod`

```go
func violatesTMValidity(ref Header, ev Header) boolean
```
- Implementation remarks
    - checks whether the evidence header `ev` violates the validity property of Tendermint Consensus, by checking agains a reference header
- Expected precondition
    - `ref.Height == ev.Height`    
- Expected postcondition
    - returns evaluation of the following disjunction
    `ref.ValidatorsHash != ev.ValidatorsHash` or  
    `ref.NextValidatorsHash != ev.NextValidatorsHash` or  
    `ref.ConsensusHash != ev.ConsensusHash` or  
    `ref.AppHash != ev.AppHash` or  
    `ref.LastResultsHash != ev.LastResultsHash`

```go
func RoundOf(commit Commit) []ValidatorAddress 
```
- Expected precondition
    - `commit` is well-formed. In particular all votes are from the same round `r`.
- Expected postcondition
    - returns round `r` that is encoded in all the votes of the commit

```go
func Signers(commit Commit) []ValidatorAddress 
```
- Expected postcondition
    - returns all validator addresses in `commit`

```go
func Addresses(vals Validator[]) ValidatorAddress[]
```
- Expected postcondition
    - returns all validator addresses in `vals`



# Part V - Completeness of the Solution


**TODO:** here comes the magic






# References

[[supervisor]] The specification of the light client supervisor.

[[verification]] The specification of the light client verification protocol

[[detection]] The specification of the light client attack detection mechanism.

[supervisor]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/supervisor/supervisor_001_draft.md

[verification]: https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_002_draft.md

[detection]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md


[LC-DATA-EVIDENCE-link]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#lc-data-evidence1

[TMBC-LC-EVIDENCE-DATA-link]:
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#tmbc-lc-evidence-data1

[node-based-attack-characterization]:
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#node-based-characterization-of-attacks

[TMBC-FM-2THIRDS-link]: https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_002_draft.md#tmbc-fm-2thirds1

[LCV-FUNC-VALID.link]: https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_002_draft.md#lcv-func-valid2
