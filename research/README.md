# Research

This folder holds ongoing research and topics of interest. The [Interchain Foundation](https://interchain.io) has research topics that they are willing fund the research for, to find out more you can go to there [funding repo](https://github.com/interchainio/funding/blob/master/research.md). You can apply for a research grant [here](https://docs.google.com/forms/d/e/1FAIpQLSclH4R5G7WgNpKPvXxPPFRA7rAoyX8nNvsJAQJpZNZwWWjFmA/viewform)

## Areas of Interest

Below you will find some areas of interest which we have.

### Tendermint Consensus

- Formal verification of Tendermint consensus [[complete]](https://arxiv.org/abs/1807.04938)
- BFT Time [[in progress]](https://github.com/tendermint/tendermint/blob/master/docs/spec/consensus/bft-time.md)
- Pipelined Tendermint - Tendermint currently uses two round trips of "voting" (pre-votes and pre-commits) in order to achieve byzantine fault tolerance. Can we **optimistically** "pipeline" two tendermint blocks by using the pre-vote for the next block as the pre-commit for the previous block.
- Novel proposal mechanisms for Tendermint consensus (alternatives to round robin proposer)
  - [Tx Pre-Sequencing](https://github.com/tendermint/tendermint/issues/1168)
  - Nakamoto consensus chain as proposal mechanism
    - PoW Nakamoto chain (Casper FFG)
    - PoS Nakamoto Chain (Snow White, Ouroboros Praos, etc)
  - P2P Communication DAG (hashgraph-like?) as proposal mechanism into Tendermint for in-block ordering
- Performance testing at scale of Tendermint consensus engines
- Cryptographic Sortition
  - Instead of requiring the entire validator set to validate every single block, can we randomly select a subset of the validators (for example randomly select 100 out of total set of 10000) to validate a specific block.
  - Would need a secure randomness beacon that is deterministic but unpredictable.
- Alternatives to Stake for determining validator weight for public systems
  - Proof of Useful Work / Storage?
- Model Tendermint in reference to other more abstract consensus algorithms
  - Modeling Tendermint as parameterization of Casper CBC

### ABCI

- Building other ABCI consensus engines
  - Currently Tendermint Core is the only consensus engine that matches the ABCI interface spec. Can we create implementations of other consensus protocols such as Casper CBC and HoneyBadger BFT to also fit the ABCI interface, so blockchain developers can choose which consensus engine to use for their application.
- Creating ABCI interface for p2p layer
  - How the ABCI creates an abstraction between the blockchain application and the consensus layer, can we create a similar abstraction between the consensus and peer to peer layers. This will allow blockchains to choose their preferred gossip protocol or networking stack.
  - Look into [libp2p](https://github.com/libp2p)

### Merkle Trees

- Sparse Merkle Trees w/ arbitrary key lengths (a "generalization" of SMT)
