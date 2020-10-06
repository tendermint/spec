# Data Structures

Here we describe the data structures in the Tendermint blockchain and the rules for validating them.

The Tendermint blockchains consists of a short list of basic data types:

- [`Block`](#block)
- [`Header`](#header)
- [`Version`](#version)
- [`BlockID`](#blockid)
- [`Time`](#time)
- [`Data` (for transactions)](#data)
- [`Commit`](#commit)
- [`Vote`](#vote)
- [`EvidenceData`](#evidence_data)
- [`Evidence`](#evidence)

## Block

A block consists of a header, transactions, votes (the commit),
and a list of evidence of malfeasance (ie. signing conflicting votes).

| Name       | Type                           | Validation                     |
|------------|--------------------------------|--------------------------------|
| Header     | [Header](#header)              | [Header](#header)              |
| Data       | [Data](#data)                  | [data](#data)                  |
| Evidence   | [EvidenceData](#evidence_data) | [EvidenceData](#evidence_data) |
| LastCommit | [Commit](#commit)              | [Commit](#commit)              |

Note the `LastCommit` is the set of signatures of validators that committed the last block.

Extra validation for `LastCommit`:

The first height is an exception - it requires the `LastCommit` to be empty:

```go
if block.Header.Height == state.InitialHeight {
  len(b.LastCommit) == 0
}
```

Otherwise, we require:

```go
len(block.LastCommit) == len(state.LastValidators)

talliedVotingPower := 0
for i, commitSig := range block.LastCommit.Signatures {
  if commitSig.Absent() {
    continue
  }

  vote.BlockID == block.LastBlockID

  val := state.LastValidators[i]
  vote.Verify(block.ChainID, val.PubKey) == true

  talliedVotingPower += val.VotingPower
}

talliedVotingPower > (2/3)*TotalVotingPower(state.LastValidators)
```

Includes one vote for every current validator.
All votes must either be for the previous block, nil or absent.
All votes must have a valid signature from the corresponding validator.
The sum total of the voting power of the validators that voted
must be greater than 2/3 of the total voting power of the complete validator set.

The number of votes in a commit is limited to 10000 (see `types.MaxVotesCount`).

where `pubKey.Verify` performs the appropriate digital signature verification of the `pubKey`
against the given signature and message bytes.

## Execution

Once a block is validated, it can be executed against the state.

The state follows this recursive equation:

```go
state(initialHeight) = InitialState
state(h+1) <- Execute(state(h), ABCIApp, block(h))
```

where `InitialState` includes the initial consensus parameters and validator set,
and `ABCIApp` is an ABCI application that can return results and changes to the validator
set (TODO). Execute is defined as:

```go
func Execute(s State, app ABCIApp, block Block) State {
 // Fuction ApplyBlock executes block of transactions against the app and returns the new root hash of the app state,
 // modifications to the validator set and the changes of the consensus parameters.
 AppHash, ValidatorChanges, ConsensusParamChanges := app.ApplyBlock(block)

 nextConsensusParams := UpdateConsensusParams(state.ConsensusParams, ConsensusParamChanges)
 return State{
  ChainID:         state.ChainID,
  InitialHeight:   state.InitialHeight,
  LastResults:     abciResponses.DeliverTxResults,
  AppHash:         AppHash,
  InitialHeight:   state.InitialHeight,
  LastValidators:  state.Validators,
  Validators:      state.NextValidators,
  NextValidators:  UpdateValidators(state.NextValidators, ValidatorChanges),
  ConsensusParams: nextConsensusParams,
  Version: {
   Consensus: {
    AppVersion: nextConsensusParams.Version.AppVersion,
   },
  },
 }
}
```

## Header

A block header contains metadata about the block and about the consensus, as well as commitments to
the data in the current block, the previous block, and the results returned by the application:

| Name        | Type                | Validation                                                                                                                                                                                                             |
|-------------|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Version     | [Version](#version) | [Version](#version)                                                                                                                                                                                                    |
| ChainID     | String              | ChainID must be less than 50 bytes.                                                                                                                                                                                    |
| Height      | int64               | Must be > 0, >= initialHeight, and == previous Height+1                                                                                                                                                                |
| Time        | [Time](#time)       | Time must be >= previous header timestamp + consensus parameters TimeIotaMs. The timestamp is equal to the weighted median of honest validators. Read more on time in the [BFT-time section](../consensus/bft-time.md) |
| LastBlockID | [BlockID](#blockid) | [BlockID](#blockid)                                                                                                                                                                                                    |
| LastCommitHash | slice of bytes |  MerkleRoot of the lastCommit's signatures. The signatures represent the validators that committed to the last block. The first block has an empty slices of bytes for the hash.   |
| DataHash | slice of bytes |  MerkleRoot of the hash of transactions. **Note**: The transactions are hashed before being included in the merkle tree, the leaves of the Merkle tree are the hashes, not the transactions themselves.   |
| ValidatorHash | slice of bytes |  MerkleRoot of the current validator set. The validators are first sorted by voting power (descending), then by address (ascending) prior to computing the MerkleRoot. |
| NextValidatorHash | slice of bytes |  MerkleRoot of the next validator set. The validators are first sorted by voting power (descending), then by address (ascending) prior to computing the MerkleRoot. |
| ConsensusHash | slice of bytes |  Hash of the proto-encoding of the consensus parameters. |
|AppHash| slice of bytes | Arbitrary byte array returned by the application after executing and commiting the previous block. It serves as the basis for validating any merkle proofs that comes from the ABCI application and represents the state of the actual application rather than the state of the blockchain itself. The first block's `block.Header.AppHash` is given by `ResponseInitChain.app_hash`.|
| LastResultHash | slice of bytes |   `LastResultsHash` is the root hash of a Merkle tree built from `ResponseDeliverTx` responses (`Log`,`Info`, `Codespace` and `Events` fields are ignored).
The first block has `block.Header.ResultsHash == MerkleRoot(nil)`, i.e. the hash of an empty input, for RFC-6962 conformance. |
|EvidenceHash |slice of bytes |MerkleRoot of the evidence of Byzantine behaviour included in this block.|
|ProposerAddress| slice of bytes | Address of the original proposer of the block. Must be a current validator.|

### Validation

A Header is valid if its corresponding fields are valid.

- Time:

    ```go
    block.Header.Timestamp >= prevBlock.Header.Timestamp + state.consensusParams.Block.TimeIotaMs
    block.Header.Timestamp == MedianTime(block.LastCommit, state.LastValidators)
    ```

    The block timestamp must be monotonic.
    It must equal the weighted median of the timestamps of the valid signatures in the block.LastCommit.

    Note: the timestamp of a vote must be greater by at least one millisecond than that of the
    block being voted on.

    The timestamp of the first block must be equal to the genesis time (since
    there's no votes to compute the median).

    ```go
    if block.Header.Height == state.InitialHeight {
        block.Header.Timestamp == genesisTime
    }
    ```

    See the section on [BFT time](../consensus/bft-time.md) for more details.

- LastBlockID:

    LastBlockID is the previous block's BlockID:

    ```go
    prevBlockParts := MakeParts(prevBlock)
    block.Header.LastBlockID == BlockID {
        Hash: MerkleRoot(prevBlock.Header),
        PartsHeader{
            Hash: MerkleRoot(prevBlockParts),
            Total: len(prevBlockParts),
        },
    }
    ```

    The first block has `block.Header.LastBlockID == BlockID{}`.

## Version

| Name  | type   | Validation                                                                                                       |
|-------|--------|------------------------------------------------------------------------------------------------------------------|
| Block | uint64 | Must be equal to protocol version being used in a network `block.Version.Block == state.Version.Consensus.Block` |
| App   | uint64 | `block.Version.App == state.Version.Consensus.App`                                                               |

## BlockID

The `BlockID` contains two distinct Merkle roots of the block.
The first, used as the block's main hash, is the MerkleRoot
of all the fields in the header (ie. `MerkleRoot(header)`.
The second, used for secure gossipping of the block during consensus,
is the MerkleRoot of the complete serialized block
cut into parts (ie. `MerkleRoot(MakeParts(block))`).
The `BlockID` includes these two hashes, as well as the number of
parts (ie. `len(MakeParts(block))`)

| Name        | Type                        | Validation                  |
|-------------|-----------------------------|-----------------------------|
| Hash        | slice of bytes              | hash must be of length 32   |
| PartsHeader | [PartsHeader](#PartsHeader) | [PartsHeader](#PartsHeader) |

See [MerkleRoot](./encoding.md#MerkleRoot) for details.

## PartSetHeader

| Name  | Type           | Validation           |
|-------|----------------|----------------------|
| Total | int32          | -                    |
| Hash  | slice of bytes | Must be of length 32 |

## Time

Tendermint uses the [Google.Protobuf.WellKnownTypes.Timestamp](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/timestamp)
format, which uses two integers, one for Seconds and for Nanoseconds.

## Data

Data is just a wrapper for a list of transactions, where transactions are arbitrary byte arrays:

| Name | Type                       | Validation |
|------|----------------------------|------------|
| Txs  | Matrix of bytes ([][]byte) | -          |

## Commit

Commit is a simple wrapper for a list of signatures, with one for each validator. It also contains the relevant BlockID, height and round:

| Name       | Type                             | Validation                                                                                               |
|------------|----------------------------------|----------------------------------------------------------------------------------------------------------|
| Height     | int64                            | Must be > 0                                                                                              |
| Round      | int32                            | Must be > 0                                                                                              |
| BlockID    | [BlockID](#blockid)              | [BlockID](#blockid)                                                                                      |
| Signatures | Array of [CommitSig](#commitsig) | Length of signatures must be > 0 and adhere to the validation of each individual [Commitsig](#commitsig) |

## CommitSig

`CommitSig` represents a signature of a validator, who has voted either for nil,
a particular `BlockID` or was absent. It's a part of the `Commit` and can be used
to reconstruct the vote set given the validator set.

| Name             | Type                        | Validation                                            |
|------------------|-----------------------------|-------------------------------------------------------|
| BlockIDFlag      | [BlockIDFlag](#blockidflag) |                Must be one of the fields in the [BlockIDFlag](#blockidflag) enum                                     |
| ValidatorAddress | [Address](#address)         |                                                       |
| Timestamp        | [Time](#time)               |                                                       |
| Signature        | [Signature](#signature)     | The length of the signaute must be > 0 and < than  64 |
NOTE: `ValidatorAddress` and `Timestamp` fields may be removed in the future
(see [ADR-25](https://github.com/tendermint/tendermint/blob/master/docs/architecture/adr-025-commit.md)).

### Validation

- ValidatorAddress:

    ```go
    if BlockIDFLAG == BlockIDFlagAbsent{
        if len(cs.ValidatorAddress) != 0 {
            return errors.New("validator address is present")
        }
        if !cs.Timestamp.IsZero() {
            return errors.New("time is present")
        }
        if len(cs.Signature) != 0 {
            return errors.New("signature is present")
        }
    } else {
        if len(cs.ValidatorAddress) != crypto.AddressSize {
            return fmt.Errorf("expected ValidatorAddress size to be %d bytes, got %d bytes", crypto.AddressSize, len(cs.ValidatorAddress))
        }
    }
    ```

## BlockIDFlag

```go
type BlockIDFlag byte

const (
 // BlockIDFlagAbsent - no vote was received from a validator.
 BlockIDFlagAbsent BlockIDFlag = 0x01
 // BlockIDFlagCommit - voted for the Commit.BlockID.
 BlockIDFlagCommit = 0x02
 // BlockIDFlagNil - voted for nil.
 BlockIDFlagNil = 0x03
)
```

## Vote

A vote is a signed message from a validator for a particular block.
The vote includes information about the validator signing it. When stored in the blockchain or propagated over the network, votes are encoded in Protobuf.

| Name             | Type                            | Validation          |
|------------------|---------------------------------|---------------------|
| Type             | [SignedMsgType](#signedmsgtype) |                     |
| Height           | int64                           | Must be > 0         |
| Round            | int32                           | Must be > 0         |
| BlockID          | [BlockID](#blockid)             | [BlockID](#blockid) |
| Timestamp        | [Time](#Time)                   | [Time](#time)       |
| ValidatorAddress | slice of bytes (`[]byte`)       |          Length must be equal to 20           |
| ValidatorIndex   | int32                           |        must be > 0             |
| Signature        | slice of bytes (`[]byte`)       |    Length of signature must be > 0 and < 64                 |

There are two types of votes:
a _prevote_ has `vote.Type == 1` and
a _precommit_ has `vote.Type == 2`.

### Validation

A Vote is valid if its corresponding fields are valid.

- Type:

    ```go
    Type == PrevoteType || PrecommitType || ProposalType
    ```

For signing, votes are represented via [`CanonicalVote`](#canonicalvote) and also encoded using protobuf via
`type.SignBytes` which includes the `ChainID`, and uses a different ordering of
the fields.

We define a method `Verify` that returns `true` if the signature verifies against the pubkey for the `SignBytes`
using the given ChainID:

```go
func (vote *Vote) Verify(chainID string, pubKey crypto.PubKey) error {
 if !bytes.Equal(pubKey.Address(), vote.ValidatorAddress) {
  return ErrVoteInvalidValidatorAddress
 }

 if !pubKey.VerifyBytes(vote.SignBytes(chainID), vote.Signature) {
  return ErrVoteInvalidSignature
 }
 return nil
}
```

## CanonicalVote

```proto
message CanonicalVote {
  SignedMsgType             type      = 1;
  sfixed64                  height    = 2;
  sfixed64                  round     = 3;
  CanonicalBlockID          block_id  = 4;
  google.protobuf.Timestamp timestamp = 5;
  string                    chain_id  = 6;
}
```

## Signature

Signatures in Tendermint are raw bytes representing the underlying signature.

See the [signature spec](./encoding.md#key-types) for more.

## EvidenceData

EvidenceData is a simple wrapper for a list of evidence:

| Name     | Type                           | Description| Validation                                                      |
|----------|--------------------------------|--|---------------------------------------------------------------|
| Evidence | Array of [Evidence](#evidence) | A list of verified [evidence](#evidence)|Validation adheres to individual types of [Evidence](#evidence) |

## Evidence

Evidence in Tendermint is used to indicate breaches in the consensus by a validator.

The [Fork Accountability](../consensus/light-client/accountability.md)
document provides a good overview for the types of evidence and how they occur. For evidence to be committed onchain, it must adhere to the validation rules of each evidence and must not be expired. The expiration age, measured in both block height and time is set in `EvidenceParams`. Each evidence uses
the timestamp of the block that the evidence occurred at to indicate the age of the evidence.

### DuplicateVoteEvidence

`DuplicateVoteEvidence` represents a validator that has voted for two different blocks
in the same round of the same height. Votes are lexicographically sorted on `BlockID`.

| Name  | Type          | Description                                                     | Validation                                          |
|-------|---------------|-----------------------------------------------------------------|-----------------------------------------------------|
| VoteA | [Vote](#vote) | One of the votes submitted by a validator when they equivocated | VoteA must adhere to [Vote](#vote) validation rules |
| VoteB | [Vote](#vote) | The second vote submitted by a validator when they equivocated  | VoteB must adhere to [Vote](#vote) validation rules |

Valid Duplicate Vote Evidence must adhere to the following rules:

- Validator Address, Height, Round and Type must be the same for both votes

- BlockID must be different for both votes (BlockID can be for a nil block)

- Validator must have been in the validator set at that height

- Vote signature must be valid (using the chainID)

- Evidence must not have expired: either age in terms of height or time must be
    less than the age stated in the consensus params. Time is the block time that the
    votes were a part of.

### LightClientAttackEvidence

 LightClientAttackEvidence is a generalized evidence that captures all forms of known attacks on
a light client such that a full node can verify, propose and commit the evidence on-chain for
punishment of the malicious validators. There are three forms of attacks: Lunatic, Equivocation
and Amnesia. These attacks are exhaustive. You can find a more detailed overview of this [here](../light-client/accountability#the_misbehavior_of_faulty_validators)

| Name             | Type                      | Description | Validation |
|------------------|---------------------------|-------------|------------|
| ConflictingBlock | [LightBlock](#LightBlock) | Read Below  | Read Below |
| CommonHeight     | int64                     | Read Below  | Read Below |

Valid Light Client Attack Evidence encompasses three types of attack and must adhere to the following rules

- If the header of the light block is invalid, thus indicating a lunatic attack, the node must check that
    they can use `verifySkipping` from their header at the common height to the conflicting header

- If the header is valid, then the validator sets are the same and this is either a form of equivocation
    or amnesia. We therefore check that 2/3 of the validator set also signed the conflicting header

- The trusted header of the node at the same height as the conflicting header must have a different hash to
    the conflicting header.

- Evidence must not have expired. The height (and thus the time) is taken from the common height.

## LightBlock

| Name         | Type                          | Description                                 | Validation                    |
|--------------|-------------------------------|---------------------------------------------|-------------------------------|
| SignedHeader | [SignedHeader](#signedheader) | The header with the commit for verification | Must not be nil and adhere to the validation rules of [signedHeader](#signedheader) |
| ValidatorSet | [ValidatorSet](#validatorset) |                                             |     Must not be nil and adhere to the validation rules of [validatorset](#validatorset)                           |

## SignedHeader

The SignedhHeader is the [header](#header) accompanied by the commit to prove it.

| Name   | Type              | Description       | Validation                                                                      |
|--------|-------------------|-------------------|---------------------------------------------------------------------------------|
| Header | [Header](#Header) | [Header](#header) | Header cannot be nil & must adhere to the [Header](#Header) validation criteria |
| Commit | [Commit](#commit) | [Commit](#commit) | Commit cannot be nil & must adhere to the [Commit](#commit) criteria            |

## ValidatorSet

| Name       | Type                             | Description                                        | Validation                                                                                                        |
|------------|----------------------------------|----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| Validators | Array of [validator](#validator) | List of the active validators at a specific height | The list of validators can not be empty or nil and must adhere to the validation rules of [validator](#validator) |
| Proposer   | Array of [validator](#validator) | The block proposer for the current block           | The proposer cannot be nil and must adhere to the validation rules of  [validator](#validator)                    |

## Validator

| Name             | Type                      | Description                                                                                       | Validation                      |
|------------------|---------------------------|---------------------------------------------------------------------------------------------------|---------------------------------|
| Address          | [Address](#address)       | Validators Address                                                                                | Length must be of size 20       |
| Pubkey           | slice of bytes (`[]byte`) | Validators Public Key                                                                             | must be a length greater than 0 |
| VotingPower      | int64                     | Validators voting power                                                                           | cannot be < 0                   |
| ProposerPriority | int64                     | Validators proposer priority. This is used to gauge when a validator is up next to propose blocks |  No validation, value can be negative and positive                               |

## Address

Address is a type alias of a slice of bytes. The address is calculated by hashing the bytes using sha256 and truncating it to only use the first 20 bytes of the slice.
