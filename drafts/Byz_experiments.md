# Tendermint experiments with Byzantine behavior

The experiments detailed here are part of the [paper][paper]
*The design, architecture and performance of the Tendermint Blockchain Network*.

## Experimental setup

We ran 128 validator nodes evenly spread among 16 AWS regions (8 nodes per region) in all continents.

> AWS regions: Frankfurt, Ireland, London, Paris, Stockholm (Europe),
> California, Ohio, Oregon, Central Canada (N. America),
> Bahrain, Hong Kong, Mumbai, Tokyo (Asia),
> São Paulo (S. America),
> Cape Town (Africa), and Sydney (Ocenia).

In addition, we ran a non-validator node in the Milan AWS region.
This node had two roles:

- Seed node: provided lists of potential peers to the validators, to form the network
- Learner: delivered the sequence of blocks committed by Tendermint, to measure performance

Co-located with this additional node, we run a number of client processes.
Clients submitted 1KB transactions in closed loop to all validators.
In the reference workload, we used 1536 clients (threads), i.e., 12 clients per validator.

### Network Overlay

The network overlay connecting the 129 Tendermint nodes was induced by the seed node.
However, to make performance results comparable, we used the same randomly-generated overlay in all experiments.

More precisely, we first configured the 128 validator nodes to connect to the seed node.
Then we waited until all nodes established connections with the selected peers, retrieved from the seed node.
We did that by by monitoring the connections established by each node, using their RPC end point.
Once all connections were established, we saved the graph of connections.

In the subsequent experiments, nodes were not configured to contact the seed node.
Instead, all connections established in the first experiment were configured using the `persistent_peers` configuration flag.
In other words, we enforced the network overlay obtained in the first experiment,
relying on a seed node, by forcing the nodes to establish the same connections.
Again, we waited until all connections were established, by monitoring the node peers using the RCP end point, to then enable the clients to generate the workload.

### Byzantine Behavior

We introduced the [twins][twins] attack, which is a form of equivocation.
Essentially, we configure pairs of validator nodes to use the same validator (private) key.
The two nodes using the same validator key operate as usual, with no modification on running code,
and they don't know about each other.
But, since they receive distinct inputs, from the network and from clients,
they are likely to produce different outputs that will be signed using the same validator key.
So, for other nodes, they behave like a single validator (node) that occasionally equivocates.

> Example of induced Byzantine behavior:
>
> 1. Clones will act as the proposer in the same height and round of consensus. 
> Since they are unlikely to have the same content in their mempools,
> they are likely to propose conflicting blocks in the same round of consensus.
>
> 1. If clones receive distinct proposed blocks in a round of consensus,
> they will vote for different values.
> This means that the validator they implement is double-signing.
> Each clone is likely to receive first the proposal from the "closest" proposer's clone,
> and reject the conflicting proposer from the "farthest" clone.
> This may induce network partitions, with no value receiving to conclude the round.

The [twins][twins] attacks includes, in addition of having validator "clones",
a mechanism to interfere in the communication layer.
The goal here is to maximize the impact of the attack, by inducing different inputs to the two clones.
Also, it also propitiates network partition, by selectively delivering to correct nodes
messages from one of the nodes, improving the impact of the attack.
We *did not* implement this mechanism, in particular because it is not trivially implemented in a gossip network.

Instead, in order to improve the likeness of successful attacks,
we tried to place "clones" far from each other in the network overlay.
We had, from the network graph, weighted by the communication latency between AWS regions,
the "distance" between two nodes in the gossip network.
We then configured pairs of nodes with maximal "distance" from each other, as above defined,
with the same validator key in order to favour the observation of Byzantine behavior.

### Version and parameters

We used Tendermint version 0.33.8, and Go version 1.15.
Nodes essentially used configuration files generated using `tendermint testnet` tool.
This means that relevant values were not changed from the defaults.

## Results

We have data for two experiments.
Let `N` be the number of validator keys in the system,
and `F` be number of validator keys affected.
Each affected validator key was used by two nodes.
So the number of nodes in the system is `(N - F) * 1 + 2 *(F) = N + F` that is always 128. 

The baseline experiment (not presented) had `N = 128` and `F = 0`.
The first experiment had `N = 96` and `F = 32`.
This means that 64 validator nodes shared 32 validator keys, two nodes per key.
The remaining 64 validator nodes were correct, each one with its own key.
The second experiment had `N = 64` and `F = 64`.
This means that 128 validator nodes shared 64 keys, two nodes per key.
No correct validator (key) was present.

The log for these two experiments are uploaded [here][logs].
In the following the contents and results are detailed.

### tput.txt files

The `tput.txt` files were generated by non-validator node, operating as the learner.
It contains, in each column:

1. The height of consensus
1. The number of transactions included in the block
1. The latency of the block, in nanoseconds (time between two consecutive blocks)
1. The round at which the block was committed
1. The number of evidences included in the block
	- Followed by all evidences included, pairs `<vote height> <validator key>`

### val_logs/val_X_log.txt/validator_log.txt

Log files for each of the 128 validators included in the experiment.

### N = 96 / F = 32

The execution consisted in 58 blocks, from height 21 to 78.
For only 3 of those heights, consensus required additional rounds, being reached at round 1 in heights 57 and 60, and at round 2 in height 47.
For most of the heights, 55, consensus was achieved at round 0.

In 20 blocks were reported evidences of misbehavior.
In block 46 were reported 32 evidences of misbehavior, the largest number, all referring to the same height 46.
Notice that this height comprised 3 rounds, being committed at round 2.
Moreover, in block 47 further 17 evidences of misbehavior were reported, referring to height 46.
In total, 210 evidences were included in blocks, on average 3.6 per block.

In the log of 57 nodes, there is the warning `Found conflicting vote from ourselves`.
Recall that 64 nodes had their keys cloned, meaning that they could find their own validator keys being used by another node.

### N = 64 / F = 64

The execution consisted in 58 blocks, from height 21 to 78.
For only 6 of those heights, consensus required an additional round, being reached at round 1.
For most of the heights, 52, consensus was achieved at round 0.

In 25 blocks were reported evidences of misbehavior.
In block 70 were reported 63 evidences of misbehavior, the largest number, all referring to height 69.
In total, 890 evidences were included in blocks, on average 15.3 per block.

In the log of 115 nodes, there is the warning `Found conflicting vote from ourselves`.
Recall that all nodes had their keys compromised in this experiment.

[paper]: https://ieeexplore.ieee.org/abstract/document/9603510
[twins]: https://arxiv.org/abs/2004.10617
[logs]: https://drive.google.com/file/d/1SKzmlcdEJLTayOrGRpxvL6ccREUuxAKH/view?usp=sharing
