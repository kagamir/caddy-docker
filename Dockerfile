# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2
FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CLOUDFLARE_VERSION=latest
ARG LAYER4_VERSION=latest
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_VERSION} \
    --with github.com/mholt/caddy-l4@${LAYER4_VERSION}
RUN /usr/bin/caddy list-modules | grep -Fx dns.providers.cloudflare \
 && /usr/bin/caddy list-modules | grep -Fx layer4

FROM caddy:${CADDY_VERSION}-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
