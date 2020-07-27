# Consensus Messages

<!-- TODO: add description of consensus messages -->

## ProposalMessage

ProposalMessage is sent when a new block is proposed. It is a suggestion of what the
next block in the blockchain should be.

```go
type ProposalMessage struct {
    Proposal Proposal
}
```

### Proposal

Proposal contains height and round for which this proposal is made, BlockID as a unique identifier
of proposed block, timestamp, and POLRound (a so-called Proof-of-Lock (POL) round) that is needed for
termination of the consensus. If POLRound >= 0, then BlockID corresponds to the block that 
is locked in POLRound. The message is signed by the validator private key.

```go
type Proposal struct {
    Height           int64
    Round            int
    POLRound         int
    BlockID          BlockID
    Timestamp        Time
    Signature        Signature
}
```

## VoteMessage

VoteMessage is sent to vote for some block (or to inform others that a process does not vote in the
current round). Vote is defined in the 
[Blockchain](https://github.com/tendermint/spec/blob/master/spec/blockchain/blockchain.md#blockidd) 
section and contains validator's
information (validator address and index), height and round for which the vote is sent, vote type,
blockID if process vote for some block (`nil` otherwise) and a timestamp when the vote is sent. The
message is signed by the validator private key.

```go
type VoteMessage struct {
    Vote Vote
}
```

## BlockPartMessage

BlockPartMessage is sent when gossipping a piece of the proposed block. It contains height, round
and the block part.

```go
type BlockPartMessage struct {
    Height int64
    Round  int
    Part   Part
}
```

## NewRoundStepMessage

NewRoundStepMessage is sent for every step transition during the core consensus algorithm execution.
It is used in the gossip part of the Tendermint protocol to inform peers about a current
height/round/step a process is in.

```go
type NewRoundStepMessage struct {
    Height                int64
    Round                 int
    Step                  RoundStepType
    SecondsSinceStartTime int
    LastCommitRound       int
}
```

## NewValidBlockMessage

NewValidBlockMessage is sent when a validator observes a valid block B in some round r, 
i.e., there is a Proposal for block B and 2/3+ prevotes for the block B in the round r.
It contains height and round in which valid block is observed, block parts header that describes 
the valid block and is used to obtain all
block parts, and a bit array of the block parts a process currently has, so its peers can know what
parts it is missing so they can send them.
In case the block is also committed, then IsCommit flag is set to true.

```go
type NewValidBlockMessage struct {
    Height           int64
    Round            int    
    BlockPartsHeader PartSetHeader
    BlockParts       BitArray
    IsCommit         bool
}
```

## ProposalPOLMessage

ProposalPOLMessage is sent when a previous block is re-proposed.
It is used to inform peers in what round the process learned for this block (ProposalPOLRound),
and what prevotes for the re-proposed block the process has.

```go
type ProposalPOLMessage struct {
    Height           int64
    ProposalPOLRound int
    ProposalPOL      BitArray
}
```

## HasVoteMessage

HasVoteMessage is sent to indicate that a particular vote has been received. It contains height,
round, vote type and the index of the validator that is the originator of the corresponding vote.

```go
type HasVoteMessage struct {
    Height int64
    Round  int
    Type   byte
    Index  int
}
```

## VoteSetMaj23Message

VoteSetMaj23Message is sent to indicate that a process has seen +2/3 votes for some BlockID.
It contains height, round, vote type and the BlockID.

```go
type VoteSetMaj23Message struct {
    Height  int64
    Round   int
    Type    byte
    BlockID BlockID
}
```

## VoteSetBitsMessage

VoteSetBitsMessage is sent to communicate the bit-array of votes a process has seen for a given
BlockID. It contains height, round, vote type, BlockID and a bit array of
the votes a process has.

```go
type VoteSetBitsMessage struct {
    Height  int64
    Round   int
    Type    byte
    BlockID BlockID
    Votes   BitArray
}
```
