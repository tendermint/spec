FROM bufbuild/buf:latest as buf

FROM golang:1.16-alpine3.14 as builder

ENV GOLANG_PROTOBUF_VERSION=1.3.1 \
  GOGO_PROTOBUF_VERSION=1.3.2

RUN GO111MODULE=on go get \
  github.com/golang/protobuf/protoc-gen-go@v${GOLANG_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogo@v${GOGO_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogofaster@v${GOGO_PROTOBUF_VERSION} && \
  mv /go/bin/protoc-gen-go* /usr/local/bin/


FROM alpine:edge

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
  apk add --update --no-cache clang-extra-tools curl git && \
  rm -rf /var/cache/apk/*

WORKDIR /work

COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=buf /usr/local/bin/* /usr/local/bin/
