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

1. **Application Developers**, those that use the ABCI to build applications on top of Tendermint, are chiefly concerned with that API. Breaking changes will force developers to modify large portions of their codebase to accommodate for the changes. Some ABCI changes such as introducing priority for the mempool don't require any effort and can be lazily adopted whilst changes like ABCI++ may force applications to redesign their entire execution system.
2. **Node Operators**, those running node infrastructure, are predominantly concerned with downtime, complexity and frequency of upgrading and loss of data. They may be also concerned about changes that may break the scripts and tooling they use to supervise their nodes.
3. **External Clients**, for example, wallets and block explorers are those that perform any of the following:
     - consume the RPC endpoints of nodes like `/block`
     - subscribe to events that are streamed via websockets
     - make queries to the indexer

    This set are concerned with chain upgrades which will impact their ability to query state and block data as well as broadcast transactions.

4. There is also a fourth emerging user: **IBC module and relayers** (although in many ways relayers can also be considered sub components to external clients). The developers of IBC and consumers of their software are concerned about changes that may affect a chains ability to send arbitrary messages to another chain. Specifically, this can happen with a breaking change to the light client verification algorithm.  

In a more broader sense, these four users are inextricably linked and their concerns reflect that of the end user of the applications. The major conclusion that this RFC makes is that **the ability for chains to provide continual service is more important than the actual upgrade burden put on the developers of these chains**. What that means is that although it may be burdensome for application developers to upgrade Tendermint versions and this may cause longer release cycles, the other three groups experience upgrades as downtime which ultimately affects end users of the application.

### Modes of Interprocess Communication

Tendermint has two primary mediums with which it can communicate to other processes: RPC and P2P. The division marks the boundary between the internal and external components of the network. The P2P layer is used in all cases that nodes (validator, full, seed or light) need to communicate with one another whereas the RPC is for any outside process that wants to communicate with a node. The assumption made here is that all communication via the RPC is to a trusted source and thus the ability to interpret information is more important than being able to verify the information. P2P is therefore primary medium for verification. As an example, an in-browser light client would consist of verifying headers (and perhaps application state) via the p2p layer and passing the information on to the client via the RPC layer (or potentially directly via an API).

The exception to this is the IBC module and relayers which are external but require verifiable data. Breaking changes to the light client verification path mean that all neighbouring chains that are connected will no longer be able to verify state transitions and thus pass messages back and forward.

## Proposal

Tendermint version labels will follow the syntax of [Semantic Versions 2.0.0](https://semver.org/) with a major, minor and patch version. The version components will be interpreted according to these rules:

For the entire cycle of a **major version** in Tendermint:

- All blocks and state data in a blockchain can be queried. All headers can be verified even across minor version changes. Nodes can both block sync and state sync from genesis to the head of the chain.
- Nodes in a network are able to communicate and perform BFT state machine replication so long as the agreed network version is the lowest of all nodes in a network. For example, nodes using version 1.5.x and 1.2.x can operate together so long as the network version is 1.2 or lower (but still within the 1.x range). This rule essentially captures the concept of network backwards compatibility.
- Node RPC endpoints will remain compatible with existing external clients:
    - New endpoints may be added, but old endpoints may not be removed.
    - Old endpoints may be extended to add new request and response fields, but requests not using those fields must function as before the change.
- Migrations should be automatic. Upgrading of one node can happen asynchronously with respect to other nodes (although agreement of a network-wide upgrade must still occur synchronously via consensus).

For the entire cycle of a **minor version** in Tendermint:

- Public Go API's, for example in `node` or `abci` packages will not change in a way that requires any consumer (not just application developers) to modify their code.
- No breaking changes to the block protocol. This means that all block related data structures should not change in a way that breaks any of the hashes, the consensus engine or light client verification.
- Upgrades between minor versions may not result in any downtime (i.e., no migrations are required), nor require any changes to the config files to continue with the existing behavior. A minor version upgrade will require only stopping the existing process, swapping the binary, and starting the new process.

These guarantees will come into effect at release 1.0.

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
