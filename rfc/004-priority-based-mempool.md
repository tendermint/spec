# RFC 004: Priority-based Mempool

## Changelog

- 2020-09-02: Initial draft

## Author(s)

- Junjia He (@ninjaahhh)

## Context

User-defined priorities for blockchain transactions can be useful, e.g. `gasPrice` in Ethereum blockchain works as a first-price auction mechanism to cope with limited capacity. However in Tendermint, current approach for packing transactions into a block follows a first-in-first-out (FIFO) style which is baked in Tendermint engine and can't be affected by ABCI applications.

To make Tendermint support priority-based transaction processing, two main aspects of current architecture in Tendermint need to be updated: one is on ABCI's interface for accepting a transaction (`CheckTx`), and another is on Tendermint's mempool design and implementation. This RFC proposes corresponding changes to address these two aspects.

## Proposal

Add a new field `priority` to the ABCI `ResponseCheckTx` message:

```proto
message ResponseCheckTx {
  uint32         code       = 1;
  bytes          data       = 2;
  string         log        = 3;  // nondeterministic
  string         info       = 4;  // nondeterministic
  int64          gas_wanted = 5 [json_name = "gas_wanted"];
  int64          gas_used   = 6 [json_name = "gas_used"];
  repeated Event events     = 7
      [(gogoproto.nullable) = false, (gogoproto.jsontag) = "events,omitempty"];
  string codespace = 8;
  uint64 priority  = 9;
}
```

Then ABCI developers can add application-specific user-defined priorities for the transactions. This addition is naturally backward-compatible because by default all requests will be returned with 0 priority and on mempool side the process will fallback to FIFO.

The next step is to make current mempool implementation priority-aware. We can have 3 phases to gradually implement this feature to make as least breaking changes as possible.

### Phase 0: Keep existing CList-based mempool

Goal:

1. Zero cost on processing "legacy" transactions (i.e. those have 0 priority)
2. When creating a block, transactions with higher priorities should be included earlier

The first phase will be experimental and only achieves the desired functionality *with potential performance degradation*. The main purpose is to design the code flow and underlying APIs accordingly, without dramatic code changes on existing data structures / algorithms.

A simple approach we can take is the following:

1. When reading `CheckTx` responses, mempool keeps a single counter called `maxPriority`. If all transactions have 0 priorities, the counter should simply have the same 0 value
2. When `Mempool.ReapMaxBytesMaxGas` is called by consensus engine, mempool would check its `maxPriority` value:
    - if it's zero, it should follow existing logic to return eligible transactions in FIFO style
    - if not, should return eligible transactions ranked by their priorities (either by `O(n^2)` brute-force or `O(nlogn)` sort). Then during commit, update mempool's `maxPriority` accordingly since transactions will be removed from mempool

### Phase 1: Abstract away existing mempool interface

In case phase 0 is not enough (for reference, go-ethereum uses [a heap](https://github.com/ethereum/go-ethereum/blob/6c9f040ebeafcc680b0c457e6f4886e2bca32527/core/tx_list.go#L440) to do similar logic), we may want to change the underlying data structure storing transactions. However, before adding a new data structure to replace existing CList implementation, certain refactoring work needs to be finished.

Goal:

1. No functionality change and no performance improvement. This phase should be to design a common underlying mempool interface to allow different implementations

Existing mempool code has many places tightly coupled with CList implementation (like in mempool reactor), and this phase mainly works as a middle ground to abstract away this coupling to allow future mempool implementation using other data structures for better performances.

Proposed interface changes:

```golang
type basemempool struct {
    mempoolImpl

    // Atomic integers
    height   int64 // the last block Update()'d to
    txsBytes int64 // total size of mempool, in bytes

    // Notify listeners (ie. consensus) when txs are available
    notifiedTxsAvailable bool
    txsAvailable         chan struct{} // fires once for each height, when the mempool is not empty

    // Keep a cache of already-seen txs.
    // This reduces the pressure on the proxyApp.
    cache     txCache
    preCheck  PreCheckFunc
    postCheck PostCheckFunc

    config *cfg.MempoolConfig

    // Exclusive mutex for Update method to prevent concurrent execution of
    // CheckTx or ReapMaxBytesMaxGas(ReapMaxTxs) methods.
    updateMtx sync.RWMutex

    wal          *auto.AutoFile // a log of mempool txs
    proxyAppConn proxy.AppConnMempool

    logger  log.Logger
    metrics *Metrics
}

type mempoolImpl interface {
    Size() int

    addTx(*mempoolTx, uint64)
    removeTx(types.Tx) bool // return whether corresponding element is removed or not
    updateRecheckCursor()
    reapMaxTxs(int) types.Txs
    reapMaxBytesMaxGas(int64, int64) types.Txs // based on priority
    recheckTxs(proxy.AppConnMempool)
    isRecheckCursorNil() bool
    getRecheckCursorTx() *mempoolTx
    getMempoolTx(types.Tx) *mempoolTx
    deleteAll()
    // ...and more
}
```

Such that mempool's shared code will live under `basemempool` (callback handling, WAL, etc.) while different `mempoolImpl` only needs to implement required methods on transaction addition / removal / iteration etc. The proposed interface is [implemented in this code base](https://github.com/QuarkChain/tendermintx/blob/master/mempool/mempool.go).

### Phase 2: Implement mempool based on different data structures

We will have more discussions on what data structure fits the requirements best. For reference, we have some preliminary profiling results on [left-leaning red–black tree and BTree](https://github.com/QuarkChain/tendermintx/blob/master/mempool/bench_test.go#L18-L31).

## Status

Proposed

## Consequences

### Positive

- ABCI blockchains will have more customizability on how transactions are included in blocks

### Negative

- At early phases, using priority-based mempools could face performance degradations
- Mempool implementations may have increased complexities

### Neutral

- Mempool code could undergo a non-trivial refactoring

## References

- [Introduction to ABCIx](https://forum.cosmos.network/t/introduction-to-abcix-an-extension-of-abci-with-greater-flexibility-and-security/3771/)
- [On ABCIx’s priority-based mempool implementation](https://forum.cosmos.network/t/on-abcixs-priority-based-mempool-implementation/3912)
- [Existing ABCIx implementation](https://github.com/QuarkChain/tendermintx)
