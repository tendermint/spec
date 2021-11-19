# RFC 006: Semantic Versioning

## Changelog

- 2021-11-19: Initial Draft

## Author(s)

- Callum Waters @cmwaters

## Context

We use versioning as an instrument to hold a set of promises to users and signal when such a set changes and how. In the conventional sense of a Go library, major versions signal that the public Go API’s have changed in a breaking way and thus require the users of such libraries to change their usage accordingly. Tendermint is a bit different in that there are multiple users: application developers (both in-process and out-of-process), node operators, and external clients. More importantly, both how these users interact with Tendermint and what's important to these users differs from how users interact and what they find important in a more conventional library.

This document attempts to encapsulate the discussions around versioning in Tendermint and draws upon them to propose a guide to how Tendermint uses versioning to make promises to its users.

It's worth to further acknowledge that the strictness of our versioning guarantees may mean nothing if we don't also address the frequency that the team intends on making version changes. We could make the strictest guarantees in the world yet simply break them with every release.

Finally I would like to remark that this RFC only addresses the what, as in what are the rules for versioning. The how, or how does Tendermint plan to follow the versioning logic, will be addressed in a later RFC on Soft Upgrades.

## Discussion

We first begin with a round up of the various users and a set of assumptions on what these users expect from Tendermint in regards to versioning:

1. Application Developers, those that use the ABCI to build applications on top of Tendermint, are chiefly concerned with that API. Breaking changes will force developers to modify large portions of their codebase to accommodate for the changes. Some ABCI changes such as introducing priority for the mempool don't require any effort and can be lazily adopted whilst changes like ABCI++ may force applications to redesign their entire execution system.
2. Node Operators, those running node infrastructure, are predominantly concerned with downtime, complexity and frequency of upgrading and loss of data. They may be also concerned about changes that may break the scripts and tooling they use to supervise their nodes.
3. External clients, for example, wallets and block explorers are those that perform any of the following:
     - consume the RPC endpoints of nodes like `/block`
     - subscribe to events that are streamed via websockets
     - make queries to the indexer
  
    This set are concerned with chain upgrades which will impact their ability to query state and block data as well as broadcast transactions.
  
4. There is also a fourth emerging user: IBC module and relayers (although in many ways relayers can also be considered as external clients). The developers of IBC and consumers of their software are concerned about changes that may affect a chains ability to send arbitrary messages to another chain. Specifically, this can happen with a breaking change to the light client verification algorithm.  

In a more broader sense, these four users are inextricably linked and their concerns reflect that of the end user of the applications. The major conclusion that this RFC makes is that **the ability for chains to provide continual service is more important than the actual upgrade burden put on the developers of these chains**. What that means is that although it may be burdensome for application developers to upgrade Tendermint versions, this is far outweighed by the pain node operators experience in upgrading, by the pain that external clients have in accommodating changes and ultimately the pain of end users who are benefiting from the application. Developers have all the time in world to make these changes whilst for other user groups, upgrading can be considered part of this real-time critical path.  

## Proposal

Tendermint will follow a same formatting structure of [SemVer](https://semver.org/) with a major, minor and patch version but with slight adjustments to what they encompass:

A major version in Tendermint guarantees that for the entire cycle of that major version:

- All blocks and state data in a blockchain can be queried. All headers can be verified even across minor version changes. Nodes can both block sync and state sync from genesis to the head of the chain.
- Nodes in a network are able to communicate and perform BFT state machine replication so long as the agreed network version is the lowest of all nodes in a network. For example, nodes using version 1.5.x and 1.2.x can operate together so long as the network version is 1.2 or lower (but still within the 1.x range). This rule essentially captures the concept of network backwards compatibility.
- An external client should not need to modify their code to interact with a node's RPC endpoints. New endpoints can be added but existing ones can not be altered or removed.
- Migrations should be automatic. Upgrading of one node can happen asynchronously with respect to other nodes (although agreement of a network-wide upgrade will happen synchronously via consensus).

A minor version in Tendermint guarantees that for the entire cycle of that minor version:

- All publicly available Go API's, for example in `node` or `abci` packages will not change in a breaking way that would require any consumer (not just application developers) to modify their code.
- No breaking changes to the block protocol. This means that all block related data structures should not change in a way that breaks any of the hashes, the consensus engine or light client verification.
- Upgrades should not result in any down-time (i.e. no migrations), nor should changes to the config files be required to continue with the existing behavior. Upgrading should simply be stopping the existing process, swapping the binary, and beginning the new process.

These guarantees come into effect post 1.0.

## Status

Proposed

## Consequences

### Positive

- Clearer communication of what versioning means to us and the effect they have on our users.

### Negative

- Can potentially incur greater engineering effort to uphold and follow these guarantees.

### Neutral

## References

- [SemVer](https://semver.org/)
- [Tendermint Tracking Issue](https://github.com/tendermint/tendermint/issues/5680)
