---------------------- MODULE MC_n4_f1_case2 -------------------------------
(*
 This model demonstrates how Tendermint unlocks a previously locked value,
 as asked in:

 https://github.com/tendermint/tendermint/issues/5834

 Igor Konnov, Informal Systems, 2021
 *)
EXTENDS Sequences

CONSTANT Proposer \* the proposer function from 0..NRounds to 1..N

\* the variables declared in TendermintAcc3
VARIABLES
  round, step, decision, lockedValue, lockedRound, validValue, validRound,
  msgsPropose, msgsPrevote, msgsPrecommit, evidence, action

\* the variable declared in TendermintAccTrace3
VARIABLE
  toReplay

\* old apalache annotations, fix with the new release
a <: b == a  

INSTANCE TendermintAccTrace_004_draft WITH
  Corr <- {"B", "C", "D"},
  Faulty <- {"A"},
  N <- 4,
  T <- 1,
  ValidValues <- { "v0", "v1" },
  InvalidValues <- {"v2"},
  MaxRound <- 2,
  Trace <- <<
    \* as A is Byzantine, we need no actions to inject its messages
    "InsertProposal",                   \* a proposer proposes X
    "UponProposalInPropose",            \* B prevotes
    "UponProposalInPropose",            \* C prevotes
    "UponProposalInPropose",            \* D prevotes
    "UponProposalInPrevoteOrCommitAndPrevote",  \* C locks on X
    "UponQuorumOfPrevotesAny",          \* B timeouts on prevote (needs help of A!)
    "UponQuorumOfPrevotesAny",          \* D timeouts on prevote (needs help of A!)
    "UponQuorumOfPrecommitsAny",        \* B timeouts on precommit
    "UponQuorumOfPrecommitsAny",        \* C timeouts on precommit
    "UponQuorumOfPrecommitsAny",        \* D timeouts on precommit
    "InsertProposal",                   \* a proposer proposes Y
    "UponProposalInPropose",            \* B prevotes on Y
    "UponProposalInPropose",            \* D prevotes on Y
    "UponProposalInPrevoteOrCommitAndPrevote",  \* B locks on Y
    "UponProposalInPrevoteOrCommitAndPrevote"   \* D locks on Y
    \* when this trace is over, the protocol may fire any action
  >> <: Seq(STRING)

\* run Apalache with --cinit=ConstInit
ConstInit == \* the proposer is arbitrary -- works for safety
  Proposer \in [Rounds -> AllProcs]

\* Check this false invariant to see an example of an execution the reaches
\* a global state where C is locked on v0, while B and D are locked on v1.
NoOpposingLocks ==
    \/ TraceIncompleteInv
    \/ lockedValue["C"] /= "v0"
    \/ lockedValue["B"] /= "v1"
    \/ lockedValue["D"] /= "v1"

\* Check this to see how Tendermint can decide after executing the trace.
NoDecision ==
  LET Decision ==
    /\ decision["C"] /= NilValue
    \* restrict the message history, to produce an interesting trace,
    \* in which C locked on v0 in round 0, while B and D locked on v1 in round 1
    /\ AsMsg([type |-> "PRECOMMIT", src |-> "C", round |-> 0, id |-> "v0"])
        \in msgsPrecommit[0]
    /\ AsMsg([type |-> "PRECOMMIT", src |-> "B", round |-> 1, id |-> "v1"])
        \in msgsPrecommit[1]
    /\ AsMsg([type |-> "PRECOMMIT", src |-> "D", round |-> 1, id |-> "v1"])
        \in msgsPrecommit[1]
    \* Moreover, the Byzantine process A does not precommit.
    \* Note that A has to prevote, in order to make B and D lock on a value.
    /\ \A m \in msgsPrecommit[1]:
       m.src /= "A"
  IN
  ~Decision

=============================================================================    
