# PEX Reactor

## Channels

Implements rate-limiting by enforcing minimal time between two consecutive
`pexRequestMessage` requests. If the peer sends us addresses we did not ask,
it is stopped.

Sending incorrectly encoded data or data exceeding `maxMsgSize` will result
in stopping the peer.
