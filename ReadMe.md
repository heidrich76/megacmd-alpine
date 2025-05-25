# Building MEGAcmd under Alpine Linux

This is a proof of concept for building the MEGAcmd tool on Alpine Linux.
While APK packages exist for older versions, newer versions use **VCPKG** as their build system and cannot be built the same way.

The files are provided as-is. Use them at your own risk.

Archives for **arm64** and **amd64** are automatically built.



## Getting Started

* **Build and start locally:**

  ```bash
  docker-compose up --build -d
  docker exec -it megacmd-alpine /bin/bash
  ```


## Links

* [MEGAcmd source code and build instructions](https://github.com/meganz/MEGAcmd)
* [Existing APK package for older versions](https://pkgs.alpinelinux.org/package/v3.21/community/armhf/megacmd)
* Inspiration from existing Docker containers for older MEGAcmd versions:
  * [GitLab: megacmd-alpine Dockerfile](https://gitlab.com/danielquinn/megacmd-alpine/-/blob/master/Dockerfile?ref_type=heads)
  * [Docker Hub: roinj/megacmd-alpine](https://hub.docker.com/r/roinj/megacmd-alpine)



## Changes to the Original Build Chain

* Patched the `pdfium` port overlay and added the `tinyxml2` overlay from VCPKG ports to MEGAcmd’s port overlays.
* Patched `/MEGAcmd/src/updater/MegaUpdater.cpp` by adding missing headers required for Alpine.
* Patched `/MEGAcmd/sdk/src/posix/net.cpp` to resolve an issue with a more recent OpenSSL version.
* Disabled `freeimage` in the build using `-DUSE_FREEIMAGE=OFF` (due to build issues on Alpine).
