# Protocol Buffers

This sections defines the types and messages shared across implementations. The definition of the data structures are located in the [core/data_structures](../spec/core/data_structures.md) for the core data types and ABCI definitions are located in the [ABCI](../spec/abci/README.md) section.

## Process of Updates

The `.proto` files within this section are core to the protocol and updates must be treated as such. 

### Steps

1. Make an issue with the proposed change. 
   - Within in the issue members from both the Tendermint-go and Tendermint-rs team will leave comments. If there is not consensus on the change an [RFC](../rfc/README.md) may be requested 
  1a. If a RFC was requested, submission of an RFC as a pull request should be made to facilitate further discussion. 
  1b. If an RFC was written, merge the RFC.
2. Make the necessary changes to the `.proto` file(s), [core data structures](../spec/core/data_structures.md) and/or [ABCI protocol](../spec/abci/apps.md).
3. Open issues within Tendermint-go and Tendermint-rs repos. This is used to notify the teams that a change occurred in the spec.
