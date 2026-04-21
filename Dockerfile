# Basis for running application
FROM alpine:3.23 AS base
COPY scripts /scripts
COPY build.env /scripts
COPY LICENSE /scripts
RUN apk add --no-cache bash fuse gcompat git nano util-linux zstd


# Basis for building application
FROM base AS builder-base
RUN apk add --no-cache autoconf autoconf-archive automake ca-certificates \
  ccache cmake curl fuse-dev g++ gmock gtest jq libtool linux-headers make \
  nasm ninja-build patch pkgconfig python3 unzip zip


# Actual build of application
FROM builder-base AS builder
RUN bash /scripts/build.sh


# Final packaging stage
FROM base AS final
RUN mkdir -p /tmp/mega_install
COPY --from=builder /tmp/mega_install /tmp/mega_install/
RUN apk add --no-cache alpine-sdk abuild patchelf
RUN bash /scripts/package.sh
