# Proposer-Based Time v2 - Part I

## System Model

#### **[PBTS-CLOCK-NEWTON.0]**

There is a reference Newtonian real-time `t` (UTC).

No process has direct access to this reference time, used only for specification purposes.

### Synchronized clocks

Processes are assumed to be equipped with synchronized clocks.

This requires processes to periodically synchronize their local clocks with an
external and trusted source of the time (e.g. NTP servers).
Each synchronization cycle aligns the process local clock with the external
source of time, making it a *fairly accurate* source of real time.
The periodic (re)synchronization aims to correct the *drift* of local clocks,
which tend to pace slightly faster or slower than the real time.

To avoid an excessive level detail in the parameters and guarantees of
synchronized clocks, we adopt a single system parameter `PRECISION` to 
encapsulate the potential inaccuracy of the synchronization mechanisms,
and drifts of local clocks from real time.

#### **[PBTS-CLOCK-PRECISION.0]**

There exists a system parameter `PRECISION`, such that
for any two processes `p` and `q`, with local clocks `C_p` and `C_q`,
that read their local clocks at the same real-time `t`,  we have:

- If `p` and `q` are equipped with synchronized clocks, then `|C_p(t) - C_q(t)| < PRECISION`

`PRECISION` thus bounds the difference on the times simultaneously read by processes
from their local clocks, so that their clocks can be considered synchronized.

#### Accuracy

The [previous system model][v1] included a second clock-related parameter, `ACCURACY`,
that relates the values read by processes from their synchronized clocks with the real time.

This parameter was removed in this version for two reasons:

- Clock accuracy is hard, if possible at all, to assess in distributed systems
- The adoption of an `ACCURACY` parameter renders the `PRECISION` parameter redundant:
if the accuracy of processes clocks is bound by `ACCURACY`,
then the clocks precision must be bound by `2 * ACCURACY`.

The adoption of an `ACCURACY` was intended to formalize the relation between a block time and the real time.
We observe, however, that clients will compare the block time to their local time,
or to the time they retrieve from a trusted source of time, not to a physical clock.
The restriction imposed by the `PRECISION` parameter can then be used, indirectly,
to bound the difference block times and real time.

### Message Delays

The assumption that processes have access to synchronized clocks ensures that proposal times
assigned by *correct processes* have a bounded relation with the real time.
It is not enough, however, to identify (and reject) proposal times proposed by Byzantine processes.

To properly evaluate whether the time assigned to a proposal is consistent with the real time,
we need some information regarding the time it takes for a message carrying a proposal
to reach all its (correct) destinations.
More precisely, the *maximum delay* for delivering a proposal to its destinations allows
defining a lower bound, a *minimum time* that a correct process assigns to proposal.
While *minimum delay* for delivering a proposal to a destination allows defining
an upper bound, the *maximum time* assigned to a proposal.

#### **[PBTS-MSG-D.0]**

There exists a system parameter `MSGDELAY` for end-to-end delays of messages carrying proposals,
such for any two correct processes `p` and `q`, and any real time `t`:

- If `p` sends a message `m` carrying a proposal at time `ts`,
then `q` receives the message, and learns the proposal,
at time `t` such that `ts <= t <= ts + MSGDELAY`.

While we don't want to impose particular restrictions regarding the format of `m`,
we need to assume that their size is upper bounded.
In practice, using messages with a fixed-size to carry proposals allows
for a more accurate estimation of `MSGDELAY`, and therefore is advised.

## Problem Statement

In this section we define the properties of Tendermint consensus
(cf. the [arXiv paper][arXiv]) in this new system model.

#### **[PBTS-PROPOSE.0]**

A proposer proposes a consensus value `v` with an associated proposal time `v.time`.

#### **[PBTS-INV-AGREEMENT.0]**

[Agreement] No two correct processes decide on different values `v` or proposal times `v.time`.

#### **[PBTS-INV-VALID.0]**

[Validity] If a correct process decides on value `v`,
then `v` satisfies a predefined `valid` predicate.

#### **[PBTS-INV-TIMELY.0]**

[Time-Validity] If a correct process decides on value `v`,
then the associated proposal time `v.time` satisfies a predefined `timely` predicate.

> Both [Validity] and [Time-Validity] must be observed even if up to `2f` validators are faulty.

### Timely proposals

The `timely` predicate is evaluated when a process receives a proposal.
Let `now_p` be time a process `p` reads from its local clock when `p` receives a proposal.
Let `v` be the proposed value and `v.time` the proposal time.
The proposal is considered `timely` by `p` if:

1. `now_p >= v.time - PRECISION` and
1. `now_p <= v.time + MSGDELAY + PRECISION`

### Timely Proof-of-Locks

We denote by `POL(v,r)` a *Proof-of-Lock* of value `v` at the round `r` of consensus.
`POL(v,r)` consists of a set of `PREVOTE` messages of round `r` for the value `v`
from processes whose cumulative voting power is at least `2f + 1`.

If

- there is a valid `POL(v,r*)` for height `h`, and
- `r*` is the lowest-numbered round `r` of height `h` for which there is a valid `POL(v,r)`, and
- `POL(v,r*)` contains a `PREVOTE` message from at least one correct process,

Then, where `p` is a such correct process:

- `p` received a `PROPOSE` message of round `r*` and height `h`,
- the `PROPOSE` message contained a proposal for value `v` with proposal time `v.time`
- and `p` considered the proposal `timely`

The round `r*` above defined will be, in most cases,
the round in which `v` was originally proposed, and when `v.time` was assigned,
using a `PROPOSE` message with `POLRound = -1`.
In any case, at least one correct process must consider the proposal `timely` at round `r*`
to enable a valid `POL(v,r*)` to be observed.

### Derived Proof-of-Locks

If

- there is a valid `POL(v,r)` for height `h`, and
- `POL(v,r)` contains a `PREVOTE` message from at least one correct process,

Then

- there is a valid `POL(v,r*)` for height `h`, with `r* <= r`
- `POL(v,r*)` contains a `PREVOTE` message from at least one correct process that considered the proposal for `v` a `timely` proposal

The above relation derives from a recursion on the round number `r`.
It is trivially observed when `r = r*`, the base of the recursion,
when a *timely* `POL(v,r*)` is obtained.
We need to ensure that, once a `timely POL(v,r*)` is obtained,
it is possible to obtain a valid `POL(v,r)` with `r > r*`,
without the need of satisfying the `timely` predicate (again) in round `r`.
In fact, since rounds are started in order, it is not likely that
a proposal time `v.time`, assigned when the round `r*` was in progress,
will still be considered `timely` when the round `r > r*` is in progress.

In other words, the algorithm should ensure that once a `POL(v,r*)` attests
that the proposal for `v` is `timely`, according to at least a correct process,
further valid `POL(v,r)` with `r > r*` can be obtained,
even though processes do not consider the proposal for `v` `timely` anymore.

> This can be achieved if the proposer of round `r' > r*` proposes `v` in a `PROPOSE` message
with `POLRound = r*`, and at least one correct processes is aware of a `POL(v,r*)`.
> From this point, if a valid `POL(v,r')` is achieved, it can replace any adopted `POL(v,r*)`.

### SAFETY

The safety of the algorithm requires a *timely* proof-of-lock for a decided value,
either directly evaluated by a correct process,
or indirectly received through a derived proof-of-lock.

#### **[PBTS-CONSENSUS-TIME-VALID.0]**

If

- there is a valid commit `C` for height `k` and round `r`, and
- `C` contains a `PRECOMMIT` message from at least one correct process

Then, where `p` is one such correct process:

- since `p` is correct, `p` received a valid `POL(v,r)`
- `POL(v,r)` contains a `PREVOTE` message from at least one correct process,
- `POL(v,r)` is derived from a timely `POL(v,r*)` with `r* <= r`,
- `POL(v,r*)` contains a `PREVOTE` message from at least one correct process,
- then a correct process considered a proposal for `v` at round `r*` a `timely` proposal.

Back to [main document][main].

[main]: ./pbts_001_draft.md
[v1]: ./pbts-sysmodel_001_draft.md
[arXiv]: https://arxiv.org/abs/1807.04938
