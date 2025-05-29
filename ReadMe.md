# Building MEGAcmd under Alpine Linux

This is a proof of concept for building the MEGAcmd tool on Alpine Linux.
While APK packages exist for older versions, newer versions use **VCPKG** as their build system and cannot be built the same way.

The files are provided as-is. Use them at your own risk.

Archives for **arm64** and **amd64** are automatically built.
The license for these archives is available at `/opt/megacmd/LICENSE-megacmd-alpine` inside the archives.
This includes the licensing terms of the original MEGA software.



## Getting Started

* Build image and start container:
  ```bash
  docker-compose up --build -d
  ```
* Start shell in container:
  ```bash
  docker exec -it megacmd-alpine /bin/bash
  ```
* Download and use installation packages:
  ```bash
  apk add --no-cache bash fuse gcompat git nano util-linux zstd
  export BASE_URL=https://github.com/heidrich76/megacmd-alpine/releases/download/v2.1.1b2
  wget "$BASE_URL/megacmd_alpine_v2.1.1b2_$(uname -m).tar.gz" -O /tmp/megacmd.tar.gz && \
    tar -xzf /tmp/megacmd.tar.gz -C / && rm /tmp/megacmd.tar.gz
  uuidgen > /etc/machine-id
  ```
* Start GitHub build by tagging:
  ```bash
  git tag -a v2.1.1b2 -m "Release v2.1.1 (Build 2)"
  git push origin v2.1.1b2
  ```



## Links

* [MEGAcmd source code and build instructions](https://github.com/meganz/MEGAcmd)
* [Existing APK package for older versions](https://pkgs.alpinelinux.org/package/v3.21/community/armhf/megacmd)
* Inspiration from existing Docker containers for older MEGAcmd versions:
  * [GitLab: megacmd-alpine Dockerfile](https://gitlab.com/danielquinn/megacmd-alpine/-/blob/master/Dockerfile?ref_type=heads)
  * [Docker Hub: roinj/megacmd-alpine](https://hub.docker.com/r/roinj/megacmd-alpine)



## Additions to the Original Build Chain

* Created new Dockerfile and build scripts based on Alpine Linux.
* Added new VCPKG overlay triplet for building on `arm64-linux`.
* Patched the `pdfium` port overlay and added the `tinyxml2` overlay from VCPKG ports to MEGAcmd’s port overlays.
* Patched `/MEGAcmd/src/updater/MegaUpdater.cpp` by adding missing headers required for Alpine.
* Patched `/MEGAcmd/sdk/src/posix/net.cpp` to resolve an issue with a more recent OpenSSL version.
* Disabled `freeimage` in the build using `-DUSE_FREEIMAGE=OFF` (due to build issues on Alpine).
