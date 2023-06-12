FROM golang:1.13-alpine

# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo_extended
# VERSION can be either 'latest' or a specific version number
ARG VERSION=latest

RUN apk add --update --no-cache ca-certificates openssl git curl && \
    case ${VERSION} in \
    latest) \
    export VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}') ;;\
    esac && \
    echo ${VERSION} && \
    echo ${TARGETARCH} && \
    if ["${TARGETARCH}" = "amd64" ]; then \
    { \
        $(curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-64bit.tar.gz | tar -xz); \
        go get github.com/yaegashi/muslstack; \
        muslstack -s 0x800000 hugo; \
    }\
    else\
    {\
        $(curl -L https://github.com/gohugoio/hugo/archive/refs/tags/v$HUGO_VERSION.tar.gz | tar -xz -C /); \
        go build --tags extended; \
        chmod +x hugo; \
    }\
    fi && \
    mv hugo /usr/bin/hugo

FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-3.12
# Required for hugo_extended
RUN apk add --update --no-cache libc6-compat
COPY --from=0 /usr/bin/hugo /usr/bin
EXPOSE 1313
WORKDIR /src
CMD ["/usr/bin/hugo server --buildDrafts --buildFuture"]
