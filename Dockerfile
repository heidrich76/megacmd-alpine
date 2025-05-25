# Basis for running application
FROM alpine:3.21 AS base
RUN apk add --no-cache bash fuse gcompat git nano util-linux zstd


# Basis for building application
FROM base AS builder-base
RUN apk add --no-cache autoconf autoconf-archive automake ca-certificates \
  ccache cmake curl fuse-dev g++ gmock gtest jq linux-headers make nasm \
  ninja-build patch pkgconfig python3 unzip zip
COPY scripts /opt/scripts


# Actual build of application
FROM builder-base AS builder
ARG MEGA_TAG=2.1.1_Linux
RUN bash /opt/scripts/build.sh "${MEGA_TAG}"


# Final release stage
FROM builder AS final
RUN mkdir -p /build && \
    tar -czf /build/megacmd_${MEGA_TAG}_alpine_$(uname -m).tar.gz -C /tmp/mega_install .
