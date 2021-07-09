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

The current PEX service has two versions. The first uses IP/port pair but since
the p2p stack is moving towards a transport agnostic approach,  node endpoints
require a `Protocol` and `Path` hence the V2 version uses a
[url](https://golang.org/pkg/net/url/#URL) instead.

### PexRequest

PexRequest is an empty message requesting a list of peers.

> EmptyRequest

### PexResponse

PexResponse is an list of net addresses provided to a peer to dial.

| Name      | Type                               | Description                              | Field Number |
|-----------|------------------------------------|------------------------------------------|--------------|
| addresses | repeated [PexAddress](#PexAddress) | List of peer addresses available to dial | 1            |

### PexAddress

PexAddress provides needed information for a node to dial a peer.

| Name | Type   | Description      | Field Number |
|------|--------|------------------|--------------|
| id   | string | NodeID of a peer | 1            |
| ip   | string | The IP of a node | 2            |
| port | port   | Port of a peer   | 3            |

### PexNode

`PexNode` provides needed information for a node to dial a peer.

| Name | Type     | Description                                              | Field Number |
|------|----------|----------------------------------------------------------|--------------|
| url  | string   | See [golang url](https://golang.org/pkg/net/url/#URL)    | 1            |
| info | NodeInfo | See [NodeInfo](..//peer.md#tendermint-version-handshake) | 2            |


### PexRequestInfo

`PexRequestInfo` is a message with one optional field for the network/chain-id
to fitler by.


| Name    | Type   | Description                                | Field Number |
|---------|--------|--------------------------------------------|--------------|
| network | string | Network/chain-id to fitler the response by | 1            |

### PexResponseInfo

`PexResponseInfo` is an list of `PexNode`.

| Name  | Type                         | Description                     | Field Number |
|-------|------------------------------|---------------------------------|--------------|
| nodes | repeated [PexNode](#PexNode) | List of nodes available to dial | 1            |

### Message

Message is a [`oneof` protobuf type](https://developers.google.com/protocol-buffers/docs/proto#oneof).
The one of consists of two messages.

| Name              | Type                                | Description                                          | Field Number |
|-------------------|-------------------------------------|------------------------------------------------------|--------------|
| pex_request       | [PexRequest](#PexRequest)           | Empty request asking for a list of addresses to dial | 1            |
| pex_response      | [PexResponse](#PexResponse)         | List of addresses to dial                            | 2            |
| pex_request_info  | [PexRequestInfo](#PexRequestInfo)   | Request asking for a list of nodes to dial           | 3            |
| pex_response_info | [PexRespinseInfo](#PexResponseInfo) | List of nodes to dial                            | 4            |
