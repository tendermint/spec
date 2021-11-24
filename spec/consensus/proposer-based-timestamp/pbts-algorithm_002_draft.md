# Proposer-Based Time - Part II

## Proposal Time

To the proposed values `v` are associated their proposing times `v.time`.
The proposing time is read from the clock of the process that proposes a value for the first time, its original proposer.

A value that receives `2f + 1 PREVOTES` in a round of consensus may be re-proposed in a subsequent round.
A value that is re-proposed retains its original proposing time, assigned by its original proposer.
In other words, once assigned, the proposing time of a value is definitive.

In the [first version]() of this specification, proposals were defined as pairs `(v, time)`.
In addition, the same value could be proposed, in different rounds, associated to distinct times.
Since this possibility does not exist in this second specification, the proposal time became part of the proposal value.
With this simplification, several small changes to the arXiv algorithm, replacing `v` by `(v, t)`, are not longer required.

## Time Monotonicity

Values decided in successive heights of consensus must have increasing times, so:

- Monotonicity: for any process `p` and any two decided heights `h` and `h'`, if `h > h'` then `decision_p[h].time > decision_p[h'].time`.

For ensuring time monotonicity, it is enough to ensure that a value `v` proposed by process `p` at height `h_p` has `v.time > decision_p[h_p-1].time`.
So, if process `p` is the proposer of a round of height `h_p` and reads from its clock a time `now_p <= decision_p[h_p-1]`,
it should postpone the generation of its proposal until `now_p > decision_p[h_p-1]`.

Notice that monotonicity is not introduced by this proposal, being already ensured by [bfttime]().
In `bfttime`, the `Timestamp` field of every `Precommit` message of height `h_p` sent by a correct process is required to be larger than `decision_p[h_p-1].time`, as one of such `Timestamp` fields becomes the time assigned to a value proposed at height `h_p`.

The time monotonic of values proposed in heights of consensus is verified by the `valid()` predicate, to which every proposed value is submitted.
A value rejected by the `valid()` implementation is not accepted by any correct process.

## Timely Proposals

PBTS introduces a new requirement for a process to accept a proposal: the proposal must be `timely`.
It is a temporal requirement, associated to a couple of synchronous assumptions regarding the behavior of processes and the network.

The evaluation of the `timely` requirement requires comparing the proposal's proposing time with the proposal's receiving time.
As these two time values can be read from different clocks, at different processes, we need to assume that processes' clocks are synchronized.
As these two times refer to two distinct events, we need to assume a minimum and a maximum real time interval between the occurrence of the two events.

The two synchronous assumptions adopted to evaluate the `timely` predicate are:
- Synchronized clocks: the values read from clocks of any two correct processes at the same instant of real time differ by at most `PRECISION`;
- Bounded transmission delays: the real time interval between the generation and sending of a proposal at a correct process, and the reception of the proposal at any correct process is upper bounded by `MSGDELAY`.

Let then `now_p` be the time, read from the clock of process `p`, at which `p` receives the proposed value `v`.
The proposal is considered `timely` by `p` when:
1. `now_p >= v.time - PRECISION`
1. `now_p <= v.time + MSGDELAY + PRECISION`

The first condition derives from the fact that the generation and sending of `v` precedes its reception.
The minimum receiving time `now_p` for `v` be considered `timely` by `p` is derived from the extreme scenario when
the clock of `p` is `PRECISION` *behind* of the clock of the proposer of `v`, and the proposal's transmission delay is `0` (minimum).

The second condition derives from the assumption of an upper bound for the transmission delay of a proposal.
The maximum receiving time `now_p` for `v` be considered `timely` by `p` is derived from the extreme scenario when
the clock of `p` is `PRECISION` *ahead* of the clock of the proposer of `v`, and the proposal's transmission delay is `MSGDELAY` (maximum).
