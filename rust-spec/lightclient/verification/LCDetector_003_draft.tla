-------------------------- MODULE LCDetector_003_draft -----------------------------
EXTENDS Integers

\* the parameters of Light Client
CONSTANTS
  AllNodes,
    (* a set of all nodes that can act as validators (correct and faulty) *)
  TRUSTED_HEIGHT,
    (* an index of the block header that the light client trusts by social consensus *)
  TARGET_HEIGHT,
    (* an index of the block header that the light client tries to verify *)
  TRUSTING_PERIOD,
    (* the period within which the validators are trusted *)
  FAULTY_RATIO,
    (* a pair <<a, b>> that limits that ratio of faulty validator in the blockchain
       from above (exclusive). Tendermint security model prescribes 1 / 3. *)
  IS_PRIMARY_CORRECT,
  IS_SECONDARY_CORRECT

VARIABLES
  blockchain,           (* the reference blockchain *)
  now,                  (* current time *)
  Faulty,               (* the set of faulty validators *)
  state,                (* the state of the light client detector *)
  fetchedLightBlocks1,  (* a function from heights to LightBlocks *)
  lightBlockStatus1,    (* a function from heights to block statuses *)
  fetchedLightBlocks2,  (* a function from heights to LightBlocks *)
  lightBlockStatus2,    (* a function from heights to block statuses *)
  fetchedLightBlocks1b,  (* a function from heights to LightBlocks *)
  lightBlockStatus1b,    (* a function from heights to block statuses *)
  commonHeight,         (* the height that is trusted in CreateEvidenceForPeer *)
  nextHeightToTry,      (* the index in CreateEvidenceForPeer *)
  evidences             (* a set of evidences *)

vars == <<state, blockchain, now, Faulty,
          fetchedLightBlocks1, lightBlockStatus1,
          fetchedLightBlocks2, lightBlockStatus2,
          fetchedLightBlocks1b, lightBlockStatus1b,
          commonHeight, nextHeightToTry, evidences >>

\* (old) type annotations in Apalache
a <: b == a


ULTIMATE_HEIGHT == TARGET_HEIGHT + 1 
 
BC == INSTANCE Blockchain_003_draft
    WITH ULTIMATE_HEIGHT <- (TARGET_HEIGHT + 1)

LC == INSTANCE LCVerificationApi_003_draft

\* evidence type
ET == [peer |-> STRING, header |-> BC!LBT, commonHeight |-> Int]

InitLightBlocks(lb, Heights) ==
    \* BC!LightBlocks is an infinite set, as time is not restricted.
    \* Hence, we initialize the light blocks by picking the sets inside.
    \E vs, nextVS, lastCommit, commit \in [Heights -> SUBSET AllNodes]:
      \* although [Heights -> Int] is an infinite set,
      \* Apalache needs just one instance of this set, so it does not complain.
      \E timestamp \in [Heights -> Int]:
        LET hdr(h) ==
             [height |-> h,
              time |-> timestamp[h],
              VS |-> vs[h],
              NextVS |-> nextVS[h],
              lastCommit |-> lastCommit[h]]
        IN
        LET lightHdr(h) ==
            [header |-> hdr(h), Commits |-> commit[h]]
        IN
        lb = [ h \in Heights |-> lightHdr(h) ]

Init ==
    \* initialize the blockchain to TARGET_HEIGHT + 1
    /\ BC!InitToHeight(FAULTY_RATIO)
    /\ state = <<"Init", "SECONDARY">> /\ commonHeight = 0 /\ nextHeightToTry = 0
    /\ evidences = {} <: {ET}
    \* precompute a possible result of light client verification for the primary
    /\ \E Heights1 \in SUBSET(TRUSTED_HEIGHT..TARGET_HEIGHT):
        /\ TRUSTED_HEIGHT \in Heights1
        /\ TARGET_HEIGHT \in Heights1
        /\ InitLightBlocks(fetchedLightBlocks1, Heights1)
        \* As we have a non-deterministic scheduler, for every trace that has
        \* an unverified block, there is a filtered trace that only has verified
        \* blocks. This is a deep observation.
        /\ lightBlockStatus1 \in [Heights1 -> {"StateVerified"}]
        /\ LC!VerifyToTargetPost(blockchain, IS_PRIMARY_CORRECT,
                                 fetchedLightBlocks1, lightBlockStatus1,
                                 TRUSTED_HEIGHT, TARGET_HEIGHT, "finishedSuccess")
    \* initialize the data structures of the secondary
    /\ LET trustedBlock == blockchain[TRUSTED_HEIGHT]
           trustedLightBlock == [header |-> trustedBlock, Commits |-> AllNodes]
       IN
       /\ fetchedLightBlocks2 =  [h \in {TRUSTED_HEIGHT} |-> trustedLightBlock]
       /\ fetchedLightBlocks1b = [h \in {TRUSTED_HEIGHT} |-> trustedLightBlock]
       /\ lightBlockStatus2 =    [h \in {TRUSTED_HEIGHT} |-> "StateVerified"]
       /\ lightBlockStatus1b =   [h \in {TRUSTED_HEIGHT} |-> "StateVerified"]

\* block should contain a copy of the block from the reference chain, with a matching commit
\* XXX: copied from Lightclient_003_draft, extract to another module?
CopyLightBlockFromChain(block, height) ==
    LET ref == blockchain[height]
        lastCommit ==
          IF height < ULTIMATE_HEIGHT
          THEN blockchain[height + 1].lastCommit
            \* for the ultimate block, which we never use, as ULTIMATE_HEIGHT = TARGET_HEIGHT + 1
          ELSE blockchain[height].VS 
    IN
    block = [header |-> ref, Commits |-> lastCommit]      

\* Either the primary is correct and the block comes from the reference chain,
\* or the block is produced by a faulty primary.
\*
\* XXX: copied from Lightclient_003_draft, extract to another module?
\*
\* [LCV-FUNC-FETCH.1::TLA.1]
FetchLightBlockInto(isPeerCorrect, block, height) ==
    IF isPeerCorrect
    THEN CopyLightBlockFromChain(block, height)
    ELSE BC!IsLightBlockAllowedByDigitalSignatures(height, block)


(**
 * Pick the next height, for which there is a block.
 *)
PickNextHeight(fetchedBlocks, height) ==
    LET largerHeights == { h \in DOMAIN fetchedBlocks: h > height } IN
    IF largerHeights = ({} <: {Int})
    THEN -1
    ELSE CHOOSE h \in largerHeights:
            \A h2 \in largerHeights: h <= h2


(**
 Check, whether the target header matches at the secondary and primary.
 *)
CompareLast ==
    /\ state = <<"Init", "SECONDARY">>
    \* fetch a block from the secondary:
    \* non-deterministically pick a block that matches the constraints
    /\ \E latest \in BC!LightBlocks:
        \* for the moment, we ignore the possibility of a timeout when fetching a block
        /\ FetchLightBlockInto(IS_SECONDARY_CORRECT, latest, TARGET_HEIGHT)
        /\  IF latest.header = fetchedLightBlocks1[TARGET_HEIGHT].header
            THEN /\ state' = <<"FinishedNoEvidence", "SECONDARY">>
                 \* save the retrieved block for further analysis
                 /\ fetchedLightBlocks2' =
                        [h \in (DOMAIN fetchedLightBlocks2) \union {TARGET_HEIGHT} |->
                            IF h = TARGET_HEIGHT THEN latest ELSE fetchedLightBlocks2[h]]
                 /\ UNCHANGED <<commonHeight, nextHeightToTry>>
            ELSE /\ commonHeight' = TRUSTED_HEIGHT
                 /\ nextHeightToTry' = PickNextHeight(fetchedLightBlocks1, TRUSTED_HEIGHT)
                 /\ state' = IF nextHeightToTry' >= 0
                             THEN <<"CreateEvidence", "SECONDARY">>
                             ELSE <<"FaultyPeer", "SECONDARY">>
                 /\ UNCHANGED fetchedLightBlocks2

    /\ UNCHANGED <<blockchain, Faulty,
                   fetchedLightBlocks1, lightBlockStatus1,
                   fetchedLightBlocks1b, lightBlockStatus1b,
                   lightBlockStatus2, evidences>>


\* the actual loop in CreateEvidence
\* TODO: Josef adds a tag
CreateEvidence(peer, isPeerCorrect, refBlocks, refStatus, targetBlocks, targetStatus) ==
    /\ state = <<"CreateEvidence", peer>>
    \* precompute a possible result of light client verification for the secondary
    \* we have to introduce HeightRange, because Apalache can only handle a..b
    \* for constant a and b
    /\ LET HeightRange == { h \in TRUSTED_HEIGHT..TARGET_HEIGHT:
                                commonHeight <= h /\ h <= nextHeightToTry } IN
      \E HeightsRange \in SUBSET(HeightRange):
        /\ commonHeight \in HeightsRange /\ nextHeightToTry \in HeightsRange
        /\ InitLightBlocks(targetBlocks, HeightsRange)
        \* As we have a non-deterministic scheduler, for every trace that has
        \* an unverified block, there is a filtered trace that only has verified
        \* blocks. This is a deep observation.
        /\ targetStatus \in
            [HeightsRange -> {"StateVerified", "StateUnverified", "StateFailed"}]
        /\ \E result \in {"finishedSuccess", "finishedFailure"}:
            /\ LC!VerifyToTargetPost(blockchain, isPeerCorrect,
                                     targetBlocks, targetStatus,
                                     commonHeight, nextHeightToTry, result)
            /\ \/ /\ result /= "finishedSuccess"
                  /\ state' = <<"FaultyPeer", peer>>
                  /\ UNCHANGED <<commonHeight, nextHeightToTry, evidences>>
               \/ /\ result = "finishedSuccess"
                  /\ LET block1 == refBlocks[nextHeightToTry] IN
                     LET block2 == targetBlocks[nextHeightToTry] IN
                     IF block1.header /= block2.header
                     THEN
                       /\ state' = <<"FoundEvidence", peer>>
                       /\ evidences' = evidences \union
                            {[peer |-> peer,
                              header |-> block1,
                              commonHeight |-> commonHeight]}
                       /\ UNCHANGED <<commonHeight, nextHeightToTry>>
                     ELSE
                       /\ nextHeightToTry' = PickNextHeight(refBlocks, nextHeightToTry)
                       /\ commonHeight' = nextHeightToTry
                       /\ state' = IF nextHeightToTry' >= 0
                                   THEN state
                                   ELSE <<"NoEvidence", peer>>
                       /\ UNCHANGED evidences  

SwitchToPrimary ==
    /\ state = <<"FoundEvidence", "SECONDARY">>
    /\ nextHeightToTry' = PickNextHeight(fetchedLightBlocks2, commonHeight)
    /\ state' = <<"CreateEvidence", "PRIMARY">>
    /\ UNCHANGED <<blockchain, now, Faulty,
                   fetchedLightBlocks1, lightBlockStatus1,
                   fetchedLightBlocks2, lightBlockStatus2,
                   fetchedLightBlocks1b, lightBlockStatus1b,
                   commonHeight, evidences >>


CreateEvidenceForSecondary ==
  /\ CreateEvidence("SECONDARY", IS_SECONDARY_CORRECT,
                    fetchedLightBlocks1, lightBlockStatus1,
                    fetchedLightBlocks2', lightBlockStatus2')
  /\ UNCHANGED <<blockchain, Faulty,
        fetchedLightBlocks1, lightBlockStatus1,
        fetchedLightBlocks1b, lightBlockStatus1b>>

CreateEvidenceForPrimary ==
  /\ CreateEvidence("PRIMARY", IS_PRIMARY_CORRECT,
                    fetchedLightBlocks2, lightBlockStatus2,
                    fetchedLightBlocks1b', lightBlockStatus1b')
  /\ UNCHANGED <<blockchain, Faulty,
        fetchedLightBlocks1, lightBlockStatus1,
        fetchedLightBlocks2, lightBlockStatus2>>
   
(**
 Execute AttackDetector for one secondary.

 [LCD-FUNC-DETECTOR.2::LOOP.1]
 *)
Next ==
    \* the global clock is advanced by zero or more time units
    /\ \E tm \in Int: tm >= now /\ now' = tm
    /\ \/ CompareLast
       \/ CreateEvidenceForSecondary
       \/ SwitchToPrimary 
       \/ CreateEvidenceForPrimary


\* simple invariants to try
NeverFinishedNoEvidence == state /= "FinishedNoEvidence"
NeverNoEvidence == state /= "NoEvidence"
NeverFoundEvidence == state /= "FoundEvidence"
NeverFaultyPeer == state /= "FaultyPeer"
NeverCreateEvidence == state /= "CreateEvidence"

NeverReachTargetHeight == nextHeightToTry < TARGET_HEIGHT

PrecisionInv1 ==
  ((now < blockchain[TARGET_HEIGHT].time + TRUSTING_PERIOD)
    /\ state = <<"FinishedNoEvidence", "SECONDARY">>
    \*/\ (IS_PRIMARY_CORRECT \/ IS_SECONDARY_CORRECT)
    )
        =>
    (fetchedLightBlocks1[TARGET_HEIGHT].header = blockchain[TARGET_HEIGHT]
      /\ fetchedLightBlocks2[TARGET_HEIGHT].header = blockchain[TARGET_HEIGHT])


PrecisionInv2 ==
  ((now < blockchain[TARGET_HEIGHT].time + TRUSTING_PERIOD)
    /\ state = <<"NoEvidence", "SECONDARY">>
    \*/\ (IS_PRIMARY_CORRECT \/ IS_SECONDARY_CORRECT)
    )
        =>
    (fetchedLightBlocks1[TARGET_HEIGHT].header = blockchain[TARGET_HEIGHT]
      /\ fetchedLightBlocks2[TARGET_HEIGHT].header = blockchain[TARGET_HEIGHT])

====================================================================================
