PROTOC_CMD=protoc --plugin=/home/william/godev/bin/protoc-gen-doc \
	-I=./thirdparty/proto \
	-I=./proto

markdown-proto-gen-abci:
	@$(PROTOC_CMD) --doc_out=spec/abci --doc_opt=spec/abci/templates/abci.tmpl,abci_generated.md:Ignore* proto/tendermint/abci/types.proto
