# Evidence

<!-- TODO: add description of evidence and how it is handled in tendermint -->

## Channel

56

```go
EvidenceChannel = byte(0x38)
```

## Messages
```go
type ListMessage struct {
	Evidence []types.Evidence
}
```
