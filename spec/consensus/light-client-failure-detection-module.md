# Light Client Failure Detection Module

The light client must be able to detect failures in the trust assumptions.
Ideally, it should never trust a header, which was forged by malicious
validators.

## Connectivity requirement

To meet the above requirement, it must be connected to at least one honest
full node. This is sufficient so long as there's no fork on the main chain.

If there is a fork on the main chain, it means that two full nodes have decided
on two different headers for the same height. Then the requirement would at
least require that the lite client is **connected to one honest full node on
each branch of the fork**.

_Remark_: +1/3 of malicious validators can create an unlimited number of forks.

However, if we assume that correct full node is going to halt in case of a fork
on the main chain, then we only need to notice that fact.

In practice, this means connecting to 1 or more geographically distributed full
nodes (called witnesses), which belong to different companies. Note this number
does not include the primary full node (called primary), which is used for
obtaining new headers.

_Remark_: we can't guarantee all witnesses won't follow the same branch of a
fork. to guarantee that, we'll need the light client to be connected to +1/3 of
nodes, which is impractical.

## Evidence detection

After the light client verifies a new header (`H`) it received from primary, it
should cross-check `H` with the headers from all witnesses. Cross-checking
means comparing hashes of the headers. If any two hashes (or more) diverge,
there's a fork (on the main chain OR phantom fork targeting this light client).

The light client will then need to validate the header it got from a witness
(`H1`) and verify it's signed by at least one trusted validator. If either of
these fails, it should disconnect from the offending witness.

1. Equivocation

  If some validator double signed, the light client should form & submit a
  `DuplicateVoteEvidence`.

  After doing so, the light client must stop its operation. The operator will be
  forced to reset the light client (resetting does not imply deleting the data
  here) with a new trusted header.

2. Phantom validators

  If there's a vote from a validator outside of the validator set for that
  height, the light client should reject the header it came from. If it came
  from primary, it should select a new primary from the list of witnesses and
  try to continue. If it came from a witness, it should simply disconnect.

3. Other attacks (Flip-flopping Amnesia & Back to the past, Lunatic)

  Since there is no way for the light client to detect who's lying to it (which
  full node - primary or one of the witnesses), it must form an evidence and
  submit it to all connected full nodes (witnesses and primary). The evidence
  will typically contain a set of diverged headers (including commits for each of
  them).

  After doing so, the light client must stop its operation. The operator will be
  forced to reset the light client (resetting does not imply deleting the data
  here) with a new trusted header.
