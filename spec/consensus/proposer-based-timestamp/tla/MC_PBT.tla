----------------------------- MODULE MC_PBT -------------------------------
CONSTANT 
  \* @type: ROUND -> PROCESS;
  Proposer

VARIABLES
  \* @type: PROCESS -> ROUND;
  round,    \* a process round number
  \* @type: PROCESS -> STEP;
  step,     \* a process step
  \* @type: PROCESS -> DECISION;
  decision, \* process decision
  \* @type: PROCESS -> VALUE;
  lockedValue,  \* a locked value
  \* @type: PROCESS -> ROUND;
  lockedRound,  \* a locked round
  \* @type: PROCESS -> VALUE;
  validValue,   \* a valid value
  \* @type: PROCESS -> ROUND;
  validRound    \* a valid round

\* time-related variables
VARIABLES  
  \* @type: PROCESS -> TIME;
  localClock, \* a process local clock: Corr -> Ticks
  \* @type: TIME;
  realTime   \* a reference Newtonian real time

\* book-keeping variables
VARIABLES
  \* @type: ROUND -> Set(PROPMESSAGE);
  msgsPropose,   \* PROPOSE messages broadcast in the system, Rounds -> Messages
  \* @type: ROUND -> Set(PREMESSAGE);
  msgsPrevote,   \* PREVOTE messages broadcast in the system, Rounds -> Messages
  \* @type: ROUND -> Set(PREMESSAGE);
  msgsPrecommit, \* PRECOMMIT messages broadcast in the system, Rounds -> Messages
  \* @type: Set(MESSAGE);
  evidence, \* the messages that were used by the correct processes to make transitions
  \* @type: ACTION;
  action,       \* we use this variable to see which action was taken
  \* @type: PROCESS -> Set(PROPMESSAGE);
  receivedTimelyProposal, \* used to keep track when a process receives a timely PROPOSAL message
  \* @type: ROUND -> Set(PROCESS);
  inspectedProposal \* used to keep track when a process tries to receive a message
  
\* Invariant support
VARIABLES
  \* @type: TIME;
  beginConsensus, \* the minimum of the local clocks in the initial state
  \* @type: PROCESS -> TIME;
  endConsensus, \* the local time when a decision is made
  \* @type: TIME;
  lastBeginConsensus, \* the maximum of the local clocks in the initial state
  \* @type: ROUND -> TIME;
  proposalTime, \* the real time when a proposer proposes in a round
  \* @type: ROUND -> TIME;
  proposalReceivedTime \* the real time when a correct process first receives a proposal message in a round


INSTANCE TendermintPBT_002_draft WITH
  Corr <- {"c1", "c2"},
  Faulty <- {"f3", "f4"},
  N <- 4,
  T <- 1,
  ValidValues <- { "v0", "v1" },
  InvalidValues <- {"v2"},
  MaxRound <- 2,
  MaxTimestamp <- 100,
  Delay <- 2,        
  Precision <- 2,
  ClockDrift <- FALSE

\* run Apalache with --cinit=CInit
CInit == \* the proposer is arbitrary -- works for safety
  Proposer \in [Rounds -> AllProcs]

=============================================================================    
