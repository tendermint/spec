------------------------- MODULE counterexample -------------------------

EXTENDS MC_n4_f1_case2

(* Initial state *)

State1 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"

(* Transition 0 to State2 *)

State2 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "Init"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = {}
/\ lockedRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0 :> {}
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0 :> {}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PROPOSE" @@ "C" :> "PROPOSE" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "InsertProposal", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPropose",
  "UponProposalInPrevoteOrCommitAndPrevote", "UponQuorumOfPrevotesAny", "UponQuorumOfPrevotesAny",
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny",
  "InsertProposal", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"

(* Transition 0 to State3 *)

State3 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "InsertProposal"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = {}
/\ lockedRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0 :> {}
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PROPOSE" @@ "C" :> "PROPOSE" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponQuorumOfPrevotesAny", "UponQuorumOfPrevotesAny", "UponQuorumOfPrecommitsAny",
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose",
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"

(* Transition 0 to State4 *)

State4 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = {[proposal |-> "v0",
  round |-> 0,
  src |-> "D",
  type |-> "PROPOSAL",
  validRound |-> -1]}
/\ lockedRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0 :> {[id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"]}
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PROPOSE" @@ "C" :> "PROPOSE" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponQuorumOfPrevotesAny", "UponQuorumOfPrevotesAny", "UponQuorumOfPrecommitsAny",
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose",
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"

(* Transition 0 to State5 *)

State5 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = {[proposal |-> "v0",
  round |-> 0,
  src |-> "D",
  type |-> "PROPOSAL",
  validRound |-> -1]}
/\ lockedRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PROPOSE" @@ "C" :> "PREVOTE" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponQuorumOfPrevotesAny",
  "UponQuorumOfPrevotesAny", "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny",
  "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose", "UponProposalInPropose",
  "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"

(* Transition 0 to State6 *)

State6 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = {[proposal |-> "v0",
  round |-> 0,
  src |-> "D",
  type |-> "PROPOSAL",
  validRound |-> -1]}
/\ lockedRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PREVOTE" @@ "C" :> "PREVOTE" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponProposalInPrevoteOrCommitAndPrevote", "UponQuorumOfPrevotesAny", "UponQuorumOfPrevotesAny",
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny",
  "InsertProposal", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> -1 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"

(* Transition 0 to State7 *)

State7 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPrevoteOrCommitAndPrevote"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PREVOTE" @@ "C" :> "PRECOMMIT" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponQuorumOfPrevotesAny", "UponQuorumOfPrevotesAny", "UponQuorumOfPrecommitsAny",
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose",
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State8 *)

State8 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponQuorumOfPrevotesAny"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PRECOMMIT" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponQuorumOfPrevotesAny", "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny",
  "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose", "UponProposalInPropose",
  "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State9 *)

State9 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponQuorumOfPrevotesAny"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 0
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PRECOMMIT" @@ "D" :> "PRECOMMIT"
/\ toReplay = <<
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny",
  "InsertProposal", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State10 *)

State10 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponQuorumOfPrecommitsAny"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 0 @@ "C" :> 0 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PRECOMMIT" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "UponQuorumOfPrecommitsAny", "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose",
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State11 *)

State11 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponQuorumOfPrecommitsAny"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 0 @@ "D" :> 1
/\ step = "B" :> "PROPOSE" @@ "C" :> "PRECOMMIT" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "UponQuorumOfPrecommitsAny", "InsertProposal", "UponProposalInPropose", "UponProposalInPropose",
  "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State12 *)

State12 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponQuorumOfPrecommitsAny"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> {[proposal |-> "v2",
      round |-> 1,
      src |-> "A",
      type |-> "PROPOSAL",
      validRound |-> 1]}
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PROPOSE" @@ "C" :> "PROPOSE" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "InsertProposal", "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State13 *)

State13 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "InsertProposal"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PROPOSE" @@ "C" :> "PROPOSE" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "UponProposalInPropose", "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote",
  "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State14 *)

State14 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PREVOTE" @@ "C" :> "PROPOSE" @@ "D" :> "PROPOSE"
/\ toReplay = <<
  "UponProposalInPropose", "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State15 *)

State15 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PREVOTE" @@ "C" :> "PROPOSE" @@ "D" :> "PREVOTE"
/\ toReplay = <<
  "UponProposalInPrevoteOrCommitAndPrevote", "UponProposalInPrevoteOrCommitAndPrevote"
>>
/\ validRound = "B" :> -1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "None" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State16 *)

State16 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPrevoteOrCommitAndPrevote"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> -1
/\ lockedValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "None"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1 :> {[id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"]}
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PROPOSE" @@ "D" :> "PREVOTE"
/\ toReplay = <<"UponProposalInPrevoteOrCommitAndPrevote">>
/\ validRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> -1
/\ validValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "None"

(* Transition 0 to State17 *)

State17 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPrevoteOrCommitAndPrevote"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> 1
/\ lockedValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "v1"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1
    :> { [id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PRECOMMIT"] }
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PROPOSE" @@ "D" :> "PRECOMMIT"
/\ toReplay = <<>>
/\ validRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> 1
/\ validValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "v1"

(* Transition 1 to State18 *)

State18 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "OnTimeoutPropose"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> 1
/\ lockedValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "v1"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1
    :> { [id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PRECOMMIT"] }
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "None", round |-> 1, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PREVOTE" @@ "D" :> "PRECOMMIT"
/\ toReplay = <<>>
/\ validRound = "B" :> 1 @@ "C" :> 0 @@ "D" :> 1
/\ validValue = "B" :> "v1" @@ "C" :> "v0" @@ "D" :> "v1"

(* Transition 5 to State19 *)

State19 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPrevoteOrCommitAndPrevote"
/\ decision = "B" :> "None" @@ "C" :> "None" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ lockedValue = "B" :> "v1" @@ "C" :> "v1" @@ "D" :> "v1"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1
    :> { [id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PRECOMMIT"] }
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "None", round |-> 1, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "PRECOMMIT" @@ "D" :> "PRECOMMIT"
/\ toReplay = <<>>
/\ validRound = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ validValue = "B" :> "v1" @@ "C" :> "v1" @@ "D" :> "v1"

(* Transition 21 to State20 *)

State20 ==
/\ Proposer = 0 :> "D" @@ 1 :> "B" @@ 2 :> "D"
/\ action = "UponProposalInPrecommitNoDecision"
/\ decision = "B" :> "None" @@ "C" :> "v1" @@ "D" :> "None"
/\ evidence = { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
  [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"],
  [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
  [id |-> "v1", round |-> 1, src |-> "C", type |-> "PRECOMMIT"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PRECOMMIT"],
  [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
  [proposal |-> "v0",
    round |-> 0,
    src |-> "D",
    type |-> "PROPOSAL",
    validRound |-> -1],
  [proposal |-> "v1",
    round |-> 1,
    src |-> "B",
    type |-> "PROPOSAL",
    validRound |-> -1] }
/\ lockedRound = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ lockedValue = "B" :> "v1" @@ "C" :> "v1" @@ "D" :> "v1"
/\ msgsPrecommit = 0
    :> { [id |-> "None", round |-> 0, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "None", round |-> 0, src |-> "D", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 0, src |-> "A", type |-> "PRECOMMIT"] }
  @@ 1
    :> { [id |-> "v1", round |-> 1, src |-> "B", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "C", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PRECOMMIT"] }
  @@ 2
    :> { [id |-> "v0", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v1", round |-> 2, src |-> "A", type |-> "PRECOMMIT"],
      [id |-> "v2", round |-> 2, src |-> "A", type |-> "PRECOMMIT"] }
/\ msgsPrevote = 0
    :> { [id |-> "v0", round |-> 0, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 0, src |-> "D", type |-> "PREVOTE"] }
  @@ 1
    :> { [id |-> "None", round |-> 1, src |-> "C", type |-> "PREVOTE"],
      [id |-> "v0", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "A", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "B", type |-> "PREVOTE"],
      [id |-> "v1", round |-> 1, src |-> "D", type |-> "PREVOTE"],
      [id |-> "v2", round |-> 1, src |-> "A", type |-> "PREVOTE"] }
  @@ 2 :> {}
/\ msgsPropose = 0
    :> {[proposal |-> "v0",
      round |-> 0,
      src |-> "D",
      type |-> "PROPOSAL",
      validRound |-> -1]}
  @@ 1
    :> { [proposal |-> "v1",
        round |-> 1,
        src |-> "B",
        type |-> "PROPOSAL",
        validRound |-> -1],
      [proposal |-> "v2",
        round |-> 1,
        src |-> "A",
        type |-> "PROPOSAL",
        validRound |-> 1] }
  @@ 2 :> {}
/\ round = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ step = "B" :> "PRECOMMIT" @@ "C" :> "DECIDED" @@ "D" :> "PRECOMMIT"
/\ toReplay = <<>>
/\ validRound = "B" :> 1 @@ "C" :> 1 @@ "D" :> 1
/\ validValue = "B" :> "v1" @@ "C" :> "v1" @@ "D" :> "v1"

(* The following formula holds true in the last state and violates the invariant *)

InvariantViolation ==
  LET Decision$2 ==
    ~(decision["C"] = "None")
      /\ LET CALL_AsMsg_t_4$2 ==
        [type |-> "PRECOMMIT", src |-> "C", round |-> 0, id |-> "v0"]
          <: [type |-> STRING,
            src |-> STRING,
            round |-> Int,
            proposal |-> STRING,
            validRound |-> Int,
            id |-> STRING]
      IN
      CALL_AsMsg_t_4$2
        \in msgsPrecommit[0]
      /\ LET CALL_AsMsg_t_5$2 ==
        [type |-> "PRECOMMIT", src |-> "B", round |-> 1, id |-> "v1"]
          <: [type |-> STRING,
            src |-> STRING,
            round |-> Int,
            proposal |-> STRING,
            validRound |-> Int,
            id |-> STRING]
      IN
      CALL_AsMsg_t_5$2
        \in msgsPrecommit[1]
      /\ LET CALL_AsMsg_t_6$2 ==
        [type |-> "PRECOMMIT", src |-> "D", round |-> 1, id |-> "v1"]
          <: [type |-> STRING,
            src |-> STRING,
            round |-> Int,
            proposal |-> STRING,
            validRound |-> Int,
            id |-> STRING]
      IN
      CALL_AsMsg_t_6$2
        \in msgsPrecommit[1]
      /\ (\A m$23 \in msgsPrecommit[1]: ~(m$23["src"] = "A"))
  IN
  Decision$2

================================================================================
\* Created by Apalache on Tue Jan 05 15:18:40 CET 2021
\* https://github.com/informalsystems/apalache
