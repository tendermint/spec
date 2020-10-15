------------------------- MODULE LCD_MC5_5_faulty ---------------------------

AllNodes == {"n1", "n2", "n3", "n4", "n5"}
TRUSTED_HEIGHT == 1
TARGET_HEIGHT == 5
TRUSTING_PERIOD == 1400     \* two weeks, one day is 100 time units :-)
IS_PRIMARY_CORRECT == FALSE
IS_SECONDARY_CORRECT == TRUE
FAULTY_RATIO == <<2, 3>>    \* < 1 / 3 faulty validators

VARIABLES
  blockchain,           (* the reference blockchain *)
  now,                  (* current time *)
  Faulty,               (* the set of faulty validators *)
  state,                (* the state of the light client detector *)
  fetchedLightBlocks1,  (* a function from heights to LightBlocks *)
  lightBlockStatus1,    (* a function from heights to block statuses *)
  fetchedLightBlocks2,  (* a function from heights to LightBlocks *)
  lightBlockStatus2,    (* a function from heights to block statuses *)
  commonHeight,         (* the height that is trusted in CreateEvidenceForPeer *)
  nextHeightToTry             (* the index in CreateEvidenceForPeer *)

INSTANCE LCDetector_003_draft
============================================================================
