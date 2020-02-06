# Failure Detection

If there are more than 1/3 (or more) faulty validators, safety may be violated.
This document describes how the light client can detect such violations (after
the fact) and the next steps.

## 1. Detection

The bare minimum requirement is to be connected to at least one honest full
node. This is sufficient so long as there's no fork on the main chain.

If there is a fork on the main chain, it means that two full nodes have decided
on two different headers for the same height. Then the requirement would at
least require that the lite client is connected to one honest full node on
each branch of the fork.

_Remark_: +1/3 of malicious validators can create an unlimited number of forks.

In practice, this means connecting to 1 or more geographically distributed full
nodes (called **witnesses**), which belong to different companies. Note this
number does not include the primary full node (called primary), which is used
for obtaining new headers.

_Remark_: we can't guarantee all witnesses won't follow the same branch of a
fork. to guarantee that, we'll need the light client to be connected to +1/3 of
nodes, which is impossible (_the structure of the network where validators are
hidden behind sentries makes this impossible_).

Full nodes are much more connected. And, if we assume a correct full node is
going to halt in case of a fork on the main chain, then **we only need to
notice that fact**.

After the light client verifies a new header (`H`) it received from primary, it
should cross-check `H` with the headers from all witnesses. Cross-checking
means comparing hashes of the headers. If any two hashes (or more) diverge,
there's a fork (on the main chain OR phantom fork targeting this light client).

The light client will then need to validate the header it got from a witness
(`H1`) and verify the signers account for +1/3 of the voting power.

- if verification fails, this is a faulty full node (2.1).
- if verification succeeds, we have a successful +1/3 attack (2.2).

## 2. Error modes

1. Faulty full node: mark them as bad and stop talking to them, but otherwise
   continue.
2. Successful +1/3 attack: submit evidence and halt, wait for human
   intervention.

### 2.1 Faulty full node

A faulty full node might send the light client a conflicting header (`H2`) that
does not fully verify but does contain say a double sign from a validator.
Technically there is a faulty validator in here, but they would just go
unpunished (NOTE: subject to a change).

### 2.2 Successful +1/3 attack

If a conflicting header (`H2`) is signed by +1/3 of the voting power, it means
there's at least one correct validator on both branches (`H1` and `H2`).

Since there is no way for the light client to detect who's lying to it (which
full node - primary or one of the witnesses), it must form an evidence and
submit it to all connected full nodes (witnesses and primary). The evidence
will typically contain a set of diverged headers (including the commits).

After doing so, the light client must stop its operation. The operator will be
forced to reset the light client (resetting does not imply deleting the data
here) with a new trusted header.
