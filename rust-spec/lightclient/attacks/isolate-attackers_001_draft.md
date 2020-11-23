*** This is the beginning of an unfinished draft. Don't continue reading! ***

# Isolating Lightclient Attackers 

In the case of an [attack][node-based-attack-characterization], the lightclient [attack detection mechanism][detection] computes data, so called evidence [[LC-DATA-EVIDENCE.1]][LC-DATA-EVIDENCE-link], that can be use to (a) proof that there has been attack [[TMBC-LC-EVIDENCE-DATA.1]][TMBC-LC-EVIDENCE-DATA-link] and (b) used as basis to find the actual nodes that deviated from the Tendermint protocol. As Tendermint consensus is safe under the assumption of more than 2/3 of correct validators per block [[TMBC-FM-2THIRDS]][TMBC-FM-2THIRDS-link], this implies that [[TMBC-FM-2THIRDS]][TMBC-FM-2THIRDS-link] was violated, that is, there is a block such that more than 1/3 of the validators deviated from the protocol.


This specification considers how a full node in a Tendermint blockchain can isolate a set of attackers that launched the attack. The set should satisfy
- the set does not contain a correct validator
- the set contains validators that represent more than 1/3 of the voting power of a block that is still within the unbonding period









# Outline

# Part I - Tendermint Blockchain

# Part II - Sequential Definition of the  Problem


##  Informal Problem statement

> for the general audience, that is, engineers who want to get an overview over what the component is doing
from a bird's eye view. 


## Sequential Problem statement

> should be English and precise. will be accompanied with a TLA spec.

# Part IV - Protocol

> Overview


## Definitions

### Data Types

### Inputs


### Configuration Parameters

### Variables

### Assumptions

### Invariants

### Used Remote Functions / Exchanged Messages

## <<Core Protocol>>

### Outline

> Describe solution (in English), decomposition into functions, where communication to other components happens.


### Details of the Functions

> Function signatures followed by pseudocode (optional) and a list of features (required):
> - Implementation remarks (optional)
>   - e.g. (local/remote) function called in the body of this function
> - Expected precondition
> - Expected postcondition
> - Error condition


### Solving the distributed specification

> Proof sketches of why we believe the solution satisfies the problem statement.
Possibly giving inductive invariants that can be used to prove the specifications
of the problem statement 

> In case the specification describes an existing protocol with known issues,
e.g., liveness bugs, etc. "Correctness Arguments" should be replace by
a section called "Analysis"



## Liveness Scenarios



# Part V - Additional Discussions









# References

[[supervisor]] The specification of the light client supervisor.

[[detection]] The specification of the light client attack detection mechanism.

[supervisor]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/supervisor/supervisor_001_draft.md

[detection]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md

[LC-DATA-EVIDENCE-link]: 
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#lc-data-evidence1

[TMBC-LC-EVIDENCE-DATA-link]:
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#tmbc-lc-evidence-data1

[node-based-attack-characterization]:
https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/detection/detection_003_reviewed.md#node-based-characterization-of-attacks

[TMBC-FM-2THIRDS-link]: https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_002_draft.md#tmbc-fm-2thirds1
