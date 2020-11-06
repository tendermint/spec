# Light Client Specification

This directory contains work-in-progress English and TLA+ specifications for the Light Client
protocol. Implementations of the light client can be found in
[Rust](https://github.com/informalsystems/tendermint-rs/tree/master/light-client) and
[Go](https://github.com/tendermint/tendermint/tree/master/light).

Light clients are assumed to be initialized once from a trusted source
with a trusted header and validator set. The light client
protocol allows a client to then securely update its trusted state by requesting and
verifying a minimal set of data from a network of full nodes (at least one of which is correct).

The light client is decomposed into three components:

- Commit Verification - verify signed headers and associated validator set changes from a single full node
- Fork Detection -  verify commits across multiple full nodes and detect conflicts (ie. the existence of forks)
- Fork Accountability - given a fork, which validators are responsible for it.

## Commit Verification

The [English specification](verification/verification.md) describes the light client
commit verification problem in terms of the temporal properties
[LCV-DIST-SAFE.1](https://github.com/informalsystems/tendermint-rs/blob/master/docs/spec/lightclient/verification/verification.md#lcv-dist-safe1) and
[LCV-DIST-LIVE.1](https://github.com/informalsystems/tendermint-rs/blob/master/docs/spec/lightclient/verification/verification.md#lcv-dist-live1).
Commit verification is assumed to operate within the Tendermint Failure Model, where +2/3 of validators are correct for some time period and
validator sets can change arbitrarily at each height.

A light client protocol is also provided, including all checks that
need to be performed on headers, commits, and validator sets
to satisfy the temporal properties - so a light client can continuously
synchronize with a blockchain. Clients can skip possibly
many intermediate headers by exploiting overlap in trusted and untrusted validator sets.
When there is not enough overlap, a bisection routine can be used to find a
minimal set of headers that do provide the required overlap.

The [TLA+ specification ver. 001](verification/Lightclient_A_1.tla)
is a formal description of the
commit verification protocol executed by a client, including the safety and
termination, which can be model checked with Apalache.

A more detailed TLA+ specification of
[Light client verification ver. 003](verification/Lightclient_003_draft.tla)
is currently under peer review.

The `MC*.tla` files contain concrete parameters for the
[TLA+ specification](verification/Lightclient_A_1.tla), in order to do model checking.
For instance, [MC4_3_faulty.tla](verification/MC4_3_faulty.tla) contains the following parameters
for the nodes, heights, the trusting period, the clock drifts,
correctness of the primary node, and the ratio of the faulty processes:

```tla
AllNodes == {"n1", "n2", "n3", "n4"}
TRUSTED_HEIGHT == 1
TARGET_HEIGHT == 3
TRUSTING_PERIOD == 1400     \* the trusting period in some time units
CLOCK_DRIFT = 10            \* how much we assume the local clock is drifting
REAL_CLOCK_DRIFT = 3        \* how much the local clock is actually drifting
IS_PRIMARY_CORRECT == FALSE
FAULTY_RATIO == <<1, 3>>    \* < 1 / 3 faulty validators
```

To run a complete set of experiments, clone [apalache](https://github.com/informalsystems/apalache) and [apalache-tests](https://github.com/informalsystems/apalache-tests) into a directory `$DIR` and run the following commands:

```sh
$DIR/apalache-tests/scripts/mk-run.py --memlimit 28 002bmc-apalache-ok.csv $DIR/apalache . out
./out/run-all.sh
```

After the experiments have finished, you can collect the logs by executing the following command:

```sh
cd ./out
$DIR/apalache-tests/scripts/parse-logs.py --human .
```

All lines in `results.csv` should report `Deadlock`, which means that the algorithm
has terminated and no invariant violation was found.

Similar to [002bmc-apalache-ok.csv](verification/002bmc-apalache-ok.csv),
file [003bmc-apalache-error.csv](verification/003bmc-apalache-error.csv) specifies
the set of experiments that should result in counterexamples:

```sh
$DIR/apalache-tests/scripts/mk-run.py --memlimit 28 003bmc-apalache-error.csv $DIR/apalache . out
./out/run-all.sh
```

All lines in `results.csv` should report `Error`.


The following table summarizes the experimental results for Light client verification
version 001. The TLA+ properties can be found in the
[TLA+ specification](verification/Lightclient_A_1.tla).
 The experiments were run in an AWS instance equipped with 32GB
RAM and a 4-core Intel® Xeon® CPU E5-2686 v4 @ 2.30GHz CPU.
We write “✗=k” when a bug is reported at depth k, and “✓<=k” when
no bug is reported up to depth k.

![Experimental results](experiments.png)

The experimental results for version 003 are to be added.

## Attack Detection

This is a work-in-progress draft.

The [English specification](detection/detection_001_reviewed.md)
defines blockchain forks and light client attacks, and describes
the problem of a light client detecting them from communication with a network
of full nodes, where at least one is correct.

The [TLA+ specification](detection/LCDetector_003_draft.tla)
is a formal description of the
detection protocol for two peers, including the safety and
termination, which can be model checked with Apalache.


The `LCD_MC*.tla` files contain concrete parameters for the
[TLA+ specification](detection/LCDetector_003_draft.tla),
in order to run the model checker.
For instance, [LCD_MC4_4_faulty.tla](detection/MC4_4_faulty.tla)
contains the following parameters
for the nodes, heights, the trusting period, the clock drifts,
correctness of the nodes, and the ratio of the faulty processes:

```tla
AllNodes == {"n1", "n2", "n3", "n4"}
TRUSTED_HEIGHT == 1
TARGET_HEIGHT == 3
TRUSTING_PERIOD == 1400     \* the trusting period in some time units
CLOCK_DRIFT = 10            \* how much we assume the local clock is drifting
REAL_CLOCK_DRIFT = 3        \* how much the local clock is actually drifting
IS_PRIMARY_CORRECT == FALSE
IS_SECONDARY_CORRECT == FALSE
FAULTY_RATIO == <<1, 3>>    \* < 1 / 3 faulty validators
```

To run a complete set of experiments, clone [apalache](https://github.com/informalsystems/apalache) and [apalache-tests](https://github.com/informalsystems/apalache-tests) into a directory `$DIR` and run the following commands:

```sh
$DIR/apalache-tests/scripts/mk-run.py --memlimit 28 004bmc-apalache-ok.csv $DIR/apalache . out
./out/run-all.sh
```

After the experiments have finished, you can collect the logs by executing the following command:

```sh
cd ./out
$DIR/apalache-tests/scripts/parse-logs.py --human .
```

All lines in `results.csv` should report `Deadlock`, which means that the algorithm
has terminated and no invariant violation was found.

Similar to [004bmc-apalache-ok.csv](verification/004bmc-apalache-ok.csv),
file [005bmc-apalache-error.csv](verification/005bmc-apalache-error.csv) specifies
the set of experiments that should result in counterexamples:

```sh
$DIR/apalache-tests/scripts/mk-run.py --memlimit 28 005bmc-apalache-error.csv $DIR/apalache . out
./out/run-all.sh
```

All lines in `results.csv` should report `Error`.

The detailed experimental results are to be added soon.

## Fork Accountability

There is no English specification yet. TODO: Jovan's work?

TODO: there is a WIP [TLA+
specification](https://github.com/informalsystems/verification/pull/13) in the
verification repo that should be moved over here.
