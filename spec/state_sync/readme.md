# State-sync

<!-- TODO: add descriptions of state_sync -->

## Channel

```go
const (
  // SnapshotChannel exchanges snapshot metadata
  SnapshotChannel = byte(0x60) 96 
  // ChunkChannel exchanges chunk contents
  ChunkChannel = byte(0x61) 97
)
```

## Messages

When a new node begin state syncing, it will ask all peers it encounters if it has any
available snapshots:

```go
type snapshotsRequestMessage struct{}
```

The receiver will query the local ABCI application via `ListSnapshots`, and send a message 
containing snapshot metadata (limited to 4 MB) for each of the 10 most recent snapshots:

```go
type snapshotsResponseMessage struct {
	Height   uint64
	Format   uint32
	Chunks   uint32
	Hash     []byte
	Metadata []byte
}
```

The node running state sync will offer these snapshots to the local ABCI application via
`OfferSnapshot` ABCI calls, and keep track of which peers contain which snapshots. Once a snapshot
is accepted, the state syncer will request snapshot chunks from appropriate peers:

```go
type chunkRequestMessage struct {
	Height uint64
	Format uint32
	Index  uint32
}
```

The receiver will load the requested chunk from its local application via `LoadSnapshotChunk`,
and respond with it (limited to 16 MB):

```go
type chunkResponseMessage struct {
	Height  uint64
	Format  uint32
	Index   uint32
	Chunk   []byte
	Missing bool
}
```

Here, `Missing` is used to signify that the chunk was not found on the peer, since an empty
chunk is a valid (although unlikely) response. 

The returned chunk is given to the ABCI application via `ApplySnapshotChunk` until the snapshot
is restored. If a chunk response is not returned within some time, it will be re-requested,
possibly from a different peer.

The ABCI application is able to request peer bans and chunk refetching as part of the ABCI protocol.

If no state sync is in progress (i.e. during normal operation), any unsolicited response messages 
are discarded.
