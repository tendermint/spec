# Proposer-Based Time v2 - Part I

## System Model

#### **[PBTS-CLOCK-NEWTON.0]**

There is a reference Newtonian real-time `t` (UTC).

No process has direct access to this reference time, used only for specification purposes.

### Synchronized clocks

Processes are assumed to be equipped with synchronized clocks.
This requires processes to periodically synchronize their local clocks with an
external and trusted source of the reference time (e.g. NTP servers).
Each synchronization cycle aligns the process local clock with the external
source of time, making it a fairly accurate source of real time.
The periodic (re)synchronization aims to correct the drift of local clocks,
which tend to pace slightly faster or slower than the real time.

To avoid an excessive level detail in the parameters and guarantees of
synchronized clocks, we adopt a single system parameter `PRECISION` to 
encapsulate the potential inaccuracy of the synchronization mechanisms,
and the temporary drifts of local clocks from real time.

#### **[PBTS-CLOCK-PRECISION.0]**

There exists a system parameter `PRECISION`, such that
for any two processes `p` and `q`, with local clocks `C_p` and `C_q`,
that read their local clocks at any real-time `t`,  we have:

- `|C_p(t) - C_q(t)| < PRECISION`

`PRECISION` thus bounds the difference on the values simultaneously read by processes from theirs local clocks,
so that their clocks can still be considered synchronized.

#### Accuracy

The [previous system model][v1] included a second clock-related parameter, `ACCURACY`,
that relates the values read by processes from their synchronized clocks with the real time.

This parameter was removed in this version for two reasons:

- Clock accuracy is hard, if possible at all, to assess in distributed systems
- The adoption of an `ACCURACY` parameter renders the `PRECISION` parameter redundant:
if the accuracy of processes clocks is bound by `ACCURACY`, then the clocks precision must be bound by `2 * ACCURACY`.

The adoption of an `ACCURACY` was intended to formalize the relation between a block time and the real time.
We observe, however, that clients will compare the block time to their local time,
or to the time they retrieve from a trusted source of time, not to a physical clock.
The restriction imposed by the `PRECISION` parameter can then be used, indirectly,
to bound the difference block times and real time.

### Message Delays

The assumption that processes have access to synchronized clocks ensures that block times proposed by
*correct processes* have a bounded relation with the real time.
It is not enough, however, to identify (and reject) block times proposed by Byzantine processes.

To properly evaluate whether the time assigned to a block or, more generally, to a message is consistent with the real time,
we need some information regarding the time it takes for the message to be transmitted.
Together with the `PRECISION`, the *minimal delay* for a message defines the *maximum timestamp*
the message could have received from a correct process, equipped with a synchronized clock.
Correspondingly, the *maximum delay* for a message bounds the *maximum timestamp* assigned to it by a correct process.

#### **[PBTS-MSG-D.0]**

There exists a system parameter `MSGDELAY` for message end-to-end delays, counted in real time,
such for any two processes `p` and `q`, and any real time `t`:

- If `p` sends a regular message `m` at time `t`, then `q` delivers `m` at time `t'` with `t <= t' <= MSGDELAY`.

We don't want to adopt detailed restrictions regarding the format and content of a message `m`.
We instead define `m` as a *regular message*, with the meaning that its size should not vary arbitrarily.
This excludes from this definition messages that carry full blocks, as they can have a variable size,
while covers size-limited messages that carry parts of a proposed block.

## Problem Statement

In this section we define the properties of Tendermint consensus (cf. the [arXiv paper][arXiv]) in this new system model.

Back to [main document][main].

[main]: ./pbts_001_draft.md
[v1]: ./pbts-sysmodel_001_draft.md
[arXiv]: https://arxiv.org/abs/1807.04938
