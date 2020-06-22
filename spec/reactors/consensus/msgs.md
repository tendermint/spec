# Consensus Messages

The consensus reactor is comprised of multiple messages.
Since protobuf is the chosen encoding system of Tendermint, the message types are defined in `.proto` files.
We now specify the messages and the processing of messages in
the receive method of Consensus reactor for each message type. In the following
message handler, `rs` and `prs` denote `RoundState` and `PeerRoundState`,
respectively.

## NewRoundStep Message

`NewRoundState` is sent for every step taken in the ConsensusState.

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

`NewValidBlock` is sent when a validator observes a valid block B in some round r,
i.e., there is a Proposal for block B and 2/3+ prevotes for the block B in the round r.
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

`ProposalMessage` is sent when a new block is proposed.

```protobuf
message Proposal {
  tendermint.types.Proposal proposal = 1;
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

`ProposalPOLMessage` is sent when a previous proposal is re-proposed.

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

`BlockPart` is sent when gossiping a piece of the proposed block.

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

`Vote` is sent when voting for a proposal (or lack thereof).

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

`HasVote` is sent to indicate that a particular vote has been received.

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

`VoteSetMaj23` is sent to indicate that a given BlockID has seen +2/3 votes.

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

`VoteSetBits` is sent to communicate the bit-array of votes seen for the BlockID.

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
