# Consensus Messages

The consensus reactor is comprised of multiple messages.
Since protobuf is the chosen encoding system of Tendermint, the message types are defined in `.proto` files.
We now specify the messages and the processing of messages in
the receive method of Consensus reactor for each message type. In the following
message handler, `rs` and `prs` denote `RoundState` and `PeerRoundState`,
respectively.

## NewRoundStep Message

`NewRoundStep` Message is sent for every step transition during the core consensus algorithm execution.
It is used in the gossip part of the Tendermint protocol to inform peers about a current
height/round/step a process is in.

```protobuf
message NewRoundStep {
  int64  height                   = 1;
  int32  round                    = 2;
  uint32 step                     = 3;
  int64  seconds_since_start_time = 4;
  int32  last_commit_round        = 5;
}
```

### NewRoundStep Message handler

```go
handleMessage(msg):
    if msg is from smaller height/round/step then return
    // Just remember these values.
    prsHeight = prs.Height
    prsRound = prs.Round
    prsCatchupCommitRound = prs.CatchupCommitRound
    prsCatchupCommit = prs.CatchupCommit

    Update prs with values from msg
    if prs.Height or prs.Round has been updated then
        reset Proposal related fields of the peer state
    if prs.Round has been updated and msg.Round == prsCatchupCommitRound then
        prs.Precommits = psCatchupCommit
    if prs.Height has been updated then
        if prsHeight+1 == msg.Height && prsRound == msg.LastCommitRound then
          prs.LastCommitRound = msg.LastCommitRound
          prs.LastCommit = prs.Precommits
        } else {
          prs.LastCommitRound = msg.LastCommitRound
          prs.LastCommit = nil
        }
        Reset prs.CatchupCommitRound and prs.CatchupCommit
```

## NewValidBlock Message

`NewValidBlock` Message is sent when a validator observes a valid block B in some round r,
i.e., there is a Proposal for block B and 2/3+ prevotes for the block B in the round r.
It contains height and round in which valid block is observed, block parts header that describes
the valid block and is used to obtain all
block parts, and a bit array of the block parts a process currently has, so its peers can know what
parts it is missing so they can send them.
In case the block is also committed, then IsCommit flag is set to true.

```protobuf
message NewValidBlock {
  int64                          height                = 1;
  int32                          round                 = 2;
  tendermint.types.PartSetHeader block_part_set_header = 3;
  tendermint.libs.bits.BitArray  block_parts           = 4;
  bool                           is_commit             = 5;
}
```

### NewValidBlock Message handler

```go
handleMessage(msg):
    if prs.Height != msg.Height then return

    if prs.Round != msg.Round && !msg.IsCommit then return

    prs.ProposalBlockPartsHeader = msg.BlockPartsHeader
    prs.ProposalBlockParts = msg.BlockParts
```

The number of block parts is limited to 1601 (`types.MaxBlockPartsCount`) to
protect the node against DOS attacks.

## Proposal Message

`Proposal` Message is sent when a new block is proposed. It is a suggestion of what the
next block in the blockchain should be.

```protobuf
message Proposal {
  tendermint.types.Proposal proposal = 1;
}
```

### Proposal

Proposal contains height and round for which this proposal is made, BlockID as a unique identifier
of proposed block, timestamp, and POLRound (a so-called Proof-of-Lock (POL) round) that is needed for termination of the consensus. If POLRound >= 0, then BlockID corresponds to the block that
is locked in POLRound. The message is signed by the validator private key.

```protobuf
message Proposal {
  SignedMsgType             type      = 1;
  int64                     height    = 2;
  int32                     round     = 3;
  int32                     pol_round = 4;
  BlockID                   block_id  = 5;
  google.protobuf.Timestamp timestamp = 6;
  bytes signature                     = 7;
}
```

### Proposal Message handler

```go
handleMessage(msg):
    if prs.Height != msg.Height || prs.Round != msg.Round || prs.Proposal then return
    prs.Proposal = true
    if prs.ProposalBlockParts == empty set then // otherwise it is set in NewValidBlockMessage handler
      prs.ProposalBlockPartsHeader = msg.BlockPartsHeader
    prs.ProposalPOLRound = msg.POLRound
    prs.ProposalPOL = nil
    Send msg through internal peerMsgQueue to ConsensusState service
```

## ProposalPOL Message

`ProposalPOL` Message is sent when a previous block is re-proposed.
It is used to inform peers in what round the process learned for this block (ProposalPOLRound),
and what prevotes for the re-proposed block the process has.

```protobuf
message ProposalPOL {
  int64                         height             = 1;
  int32                         proposal_pol_round = 2;
  tendermint.libs.bits.BitArray proposal_pol       = 3;
}
```

### ProposalPOL Message handler

```go
handleMessage(msg):
    if prs.Height != msg.Height or prs.ProposalPOLRound != msg.ProposalPOLRound then return
    prs.ProposalPOL = msg.ProposalPOL
```

## BlockPart Message

`BlockPart` Message is sent when gossiping a piece of the proposed block. It contains height, round
and the block part.

```protobuf
message BlockPart {
  int64                 height = 1;
  int32                 round  = 2;
  tendermint.types.Part part   = 3;
}
```

### BlockPart Message handler

```go
handleMessage(msg):
    if prs.Height != msg.Height || prs.Round != msg.Round then return
    Record in prs that peer has block part msg.Part.Index
    Send msg trough internal peerMsgQueue to ConsensusState service
```

## Vote Message

`Vote` Message is sent to vote for some block (or to inform others that a process does not vote in the current round). Vote is defined in the
[Blockchain](https://github.com/tendermint/spec/blob/master/spec/blockchain/blockchain.md#blockidd)
section and contains validator's
information (validator address and index), height and round for which the vote is sent, vote type,
blockID if process vote for some block (`nil` otherwise) and a timestamp when the vote is sent. The
message is signed by the validator private key.

```protobuf
message Vote {
  tendermint.types.Vote vote = 1;
}
```

### Vote Message handler

```go
handleMessage(msg):
    Record in prs that a peer knows vote with index msg.vote.ValidatorIndex for particular height and round
    Send msg trough internal peerMsgQueue to ConsensusState service
```

The number of votes is limited to 10000 (`types.MaxVotesCount`) to protect the
node against DOS attacks.

## HasVote Message

`HasVote` Message is sent to indicate that a particular vote has been received. It contains height,
round, vote type and the index of the validator that is the originator of the corresponding vote.

```protobuf
message HasVote {
  int64                          height = 1;
  int32                          round  = 2;
  tendermint.types.SignedMsgType type   = 3;
  int32                          index  = 4;
}
```

### HasVote Message handler

```go
handleMessage(msg):
    if prs.Height == msg.Height then
        prs.setHasVote(msg.Height, msg.Round, msg.Type, msg.Index)
```

## VoteSetMaj23 Message

`VoteSetMaj23` Message is sent to indicate that a process has seen +2/3 votes for some BlockID.
It contains height, round, vote type and the BlockID.

```protobuf
message VoteSetMaj23 {
  int64                          height   = 1;
  int32                          round    = 2;
  tendermint.types.SignedMsgType type     = 3;
  tendermint.types.BlockID       block_id = 4;
}
```

### VoteSetMaj23 Message handler

```go
handleMessage(msg):
    if prs.Height == msg.Height then
        Record in rs that a peer claim to have ⅔ majority for msg.BlockID
        Send VoteSetBitsMessage showing votes node has for that BlockId
```

## VoteSetBits Message

`VoteSetBits` Message is sent to communicate the bit-array of votes a process has seen for a given
BlockID. It contains height, round, vote type, BlockID and a bit array of
the votes a process has.

```protobuf
message VoteSetBits {
  int64                          height   = 1;
  int32                          round    = 2;
  tendermint.types.SignedMsgType type     = 3;
  tendermint.types.BlockID       block_id = 4;
  tendermint.libs.bits.BitArray  votes    = 5;
}
```

### VoteSetBits Message handler

```go
handleMessage(msg):
    Update prs for the bit-array of votes peer claims to have for the msg.BlockID
```

The number of votes is limited to 10000 (`types.MaxVotesCount`) to protect the
node against DOS attacks.
