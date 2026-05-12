FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION
ARG REVISION
ARG BUILD_DATE

WORKDIR /workspace

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT#v} \
    CGO_ENABLED=0 go build \
      -ldflags "-X main.Version=${VERSION} -X main.Revision=${REVISION} -X main.Date=${BUILD_DATE}" \
      -o jx-release-version main.go

FROM alpine:3.17

COPY --from=builder /workspace/jx-release-version /usr/bin/jx-release-version
COPY ./hack/github-actions-entrypoint.sh /usr/bin/github-actions-entrypoint.sh

ENTRYPOINT ["jx-release-version"]
