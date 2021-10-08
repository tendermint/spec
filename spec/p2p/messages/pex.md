---
order: 6
---

# Peer Exchange

## Channels

Pex has one channel. The channel identifier is listed below.

| Name       | Number |
|------------|--------|
| PexChannel | 0      |

## Message Types

### PexRequest

PexRequest is an empty message requesting a list of peers.

> EmptyRequest

### PexResponse

PexResponse is an list of net addresses provided to a peer to dial.

| Name  | Type                               | Description                              | Field Number |
|-------|------------------------------------|------------------------------------------|--------------|
| addresses | repeated [PexAddress](#PexAddress) | List of peer addresses available to dial | 1            |

### PexAddress

PexAddress provides needed information for a node to dial a peer.

| Name | Type   | Description      | Field Number |
|------|--------|------------------|--------------|
| url   | string | See [golang url](https://golang.org/pkg/net/url/#URL) | 1            |

### Message

Message is a [`oneof` protobuf type](https://developers.google.com/protocol-buffers/docs/proto#oneof). The one of consists of two messages.

| Name         | Type                      | Description                                          | Field Number |
|--------------|---------------------------|------------------------------------------------------|--------------|
| pex_request  | [PexRequest](#PexRequest) | Empty request asking for a list of addresses to dial | 1            |
| pex_response | [PexResponse](#PexResponse)  | List of addresses to dial                            | 2            |
