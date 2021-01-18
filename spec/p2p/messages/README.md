---
order: 1
parent:
  title: Messages
  order: 1
---

# Messages

An implementation of the spec consists of many components. While many parts of these components are implementation specific, the p2p messages are not. In this section we will be covering all the p2p messages of components.

There are two parts to the P2P messages, the message it self and the channel. The channel is message specific. When a node connect to a peer it will tell the other node which channels are available. This notifies the peer what services the connecting node offers.

- [Block Sync](./block-sync.md)
- [Mempool](./mempool.md)
- [Evidence](./evidence.md)
- [State Sync](./state-sync.md)
- [Pex](./pex.md)
- [Consensus](./consensus.md)
