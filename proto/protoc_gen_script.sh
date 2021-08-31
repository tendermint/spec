#!/bin/sh

protoc -I=./ -I=$HOME/repos/tendermint/third_party/proto --go_out=./go_out \
	--go_opt=Mtendermint/abci/types.proto=github.com/tendermint/proto/tendermint/abci \
	--go_opt=Mtendermint/crypto/proof.proto=github.com/tendermint/proto/tendermint/crypto \
	--go_opt=Mtendermint/crypto/keys.proto=github.com/tendermint/proto/tendermint/crypto \
	--go_opt=Mtendermint/version/types.proto=github.com/tendermint/proto/tendermint/version \
	--go_opt=Mtendermint/types/validator.proto=github.com/tendermint/proto/tendermint/types \
	--go_opt=Mtendermint/types/types.proto=github.com/tendermint/proto/tendermint/types \
	--go_opt=Mtendermint/types/params.proto=github.com/tendermint/proto/tendermint/types \
	tendermint/abci/types.proto

