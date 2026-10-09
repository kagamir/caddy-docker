# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2
FROM --platform=$BUILDPLATFORM caddy:${CADDY_VERSION}-builder AS builder
ARG TARGETOS
ARG TARGETARCH
ARG CLOUDFLARE_VERSION=latest
ARG LAYER4_VERSION=latest
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} xcaddy build \
    --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_VERSION} \
    --with github.com/mholt/caddy-l4@${LAYER4_VERSION}
FROM caddy:${CADDY_VERSION}-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN /usr/bin/caddy list-modules | grep -Fx dns.providers.cloudflare \
 && /usr/bin/caddy list-modules | grep -Fx layer4
