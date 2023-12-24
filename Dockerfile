FROM node:16 as builder


WORKDIR /build
COPY web/package.json .
RUN npm install
COPY ./web .
COPY ./VERSION .
RUN DISABLE_ESLINT_PLUGIN='true' REACT_APP_VERSION=$(cat VERSION) npm run build

FROM golang:1.21.5 AS builder2
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on \
    CGO_ENABLED=1 \
    GOOS=linux
WORKDIR /build
ADD go.mod go.sum ./

RUN go mod download
COPY . .
COPY --from=builder /build/build ./web/build
RUN go build -ldflags "-s -w -X 'fly-api/common.Version=$(cat VERSION)' -extldflags '-static'" -o fly-api
#COPY ./fly-api fly-api
FROM alpine

RUN RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates 2>/dev/null || true

COPY --from=builder2 /build/fly-api /
EXPOSE 3000
WORKDIR /data
ENTRYPOINT ["/fly-api"]
