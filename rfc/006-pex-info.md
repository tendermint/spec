# RFC 006: Extend PEX messages with additional info

## Changelog

- 2021-07-07: Initial draft

## Author

- @xla

## Context

The majority of tendermint deployments run nodes with varying responsibilities
offering subsets of all available channels/reactors. While this is accounted
for in the p2p stack by not sending messages to a peer which did not advise the
corresponding channel, it depends on the `NodeInfo` exchanged during
a handshake after a connect. Consequently there currently isn't a protocol
native way to do rudimentally discovery to find and connect to nodes offering
certain capabilities.

## Proposal

This document proposes a change to the current set of PEX messages to support
discovery based on advertised channels. In a way that is backward compabitible
to avoid it requiring a hard-fork of any running networks.

At the core is the introduction of a new request-response pair which besides
the endpoint information (ip:port/url) carries the `NodeInfo` exchanged during
handshake in the response. As that carries the channels active/supported on the
peer a receiving node can apply filtering appropriate for local use-cases.
Furthermore any extensions to the `NodeInfo` will be carried with the response
enabling follow-up changes extending the ABCI to involve the application in the
node discovery.

### Message changes

The recently introduced [v2 messages](https://github.com/tendermint/spec/pull/312)
SHALL be replaced with versions which carry additional information about known
peers.

``` proto
message PexNode {
  // Encoded endpoint including protocol, id and path.
  string   url  = 1 [(gogoproto.customname) = "URL"];
  // Unaltered NodeInfo obtained during handshake with the peer.
  NodeInfo info = 2;
}

message PexRequestInfo {
  // Optional network/chain id to restrict the query to only return nodes which
  // are part of that chain.
  string network;
}

message PexResponseInfo {
  repeated PexNode nodes = 1 [gogoproto.nullable) = false];
}
```

The resulting sum of pex messages SHALL look as follows:

``` proto
message PexMessage {
  oneof sum {
    PexRequest      pex_request       = 1;
    PexResponse     pex_response      = 2;
    PexRequestInfo  pex_request_info  = 3;
    PexResponseInfo pex_response_info = 4;
  }
}
```

## Status

Proposed

## Consequences

### Positive

- enable discovery use-cases for heterogenous node networks
- build foundation for multi-chain deployments
- backwards compatible improvement

### Negative

- address book implementations have to adapt and will consequently become more
  complex

### Neutral

- application driven use-cases depend on a follow up extension to ABCI
