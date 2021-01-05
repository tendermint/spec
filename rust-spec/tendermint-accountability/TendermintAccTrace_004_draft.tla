------------------ MODULE TendermintAccTrace_004_draft -------------------------
(*
  When Apalache is running too slow and we have an idea of a counterexample,
  we use this module to restrict the behaviors only to certain actions.
  Once the whole trace is replayed, the system continues unrestricted.
 
  Version 2.

  Igor Konnov, Informal Systems, 2020-2021.
 *)

EXTENDS Sequences, Apalache, TendermintAcc_004_draft

\* a sequence of action names that should appear in the given order,
\* excluding "Init"
CONSTANT Trace

VARIABLE toReplay

TraceInit ==
    /\ toReplay := Trace
    /\ action := "Init"
    /\ Init

TraceNext ==
    /\ IF Len(toReplay) > 0
       THEN
         \* Here is the trick. We restrict the action to the expected one,
         \* so the other actions will be pruned.
         /\ toReplay' := Tail(toReplay)
         /\ action' := Head(toReplay)
       ELSE  
         \* However, when toReplay is empty, the spec is unrestricted.
         /\ UNCHANGED toReplay
         /\ \E a \in Actions:
            action' := a
    /\ Next

\* check this invariant to produce a complete trace that replays your scenario
TraceIncompleteInv ==
    Len(toReplay) > 0

================================================================================
