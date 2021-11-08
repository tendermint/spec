DOCKER_PROTO := docker run -v $(shell pwd):/workspace --workdir /workspace tendermintdev/docker-build-proto
HTTPS_GIT := https://github.com/tendermint/spec.git

###############################################################################
###                                Protobuf                                 ###
###############################################################################

proto-all: proto-lint proto-check-breaking
.PHONY: proto-all

proto-gen:
	# @docker pull -q tendermintdev/docker-build-proto
	@echo "Generating Protobuf files"
	@$(DOCKER_PROTO) buf generate 
.PHONY: proto-gen

proto-lint:
	@$(DOCKER_PROTO) buf lint --error-format=json
.PHONY: proto-lint

proto-format:
	@echo "Formatting Protobuf files"
	@$(DOCKER_PROTO) find ./ -not -path "./third_party/*" -name *.proto -exec clang-format -i {} \;
.PHONY: proto-format

proto-check-breaking:
	@$(DOCKER_PROTO) buf breaking --against .git#branch=master
.PHONY: proto-check-breaking

proto-check-breaking-ci:
	@$(DOCKER_PROTO) buf breaking --against $(HTTPS_GIT)#branch=master
.PHONY: proto-check-breaking-ci
