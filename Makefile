EXAMPLE_CMD=protoc --plugin=/home/william/godev/bin/protoc-gen-doc \
	-I=./thirdparty/proto \
	-I=./proto \

markdown-proto-gen:
	@$(EXAMPLE_CMD) --doc_out spec/abci --doc_opt='spec/template.tmpl,abci_generated.md:Ignore*' proto/tendermint/abci/types.proto
