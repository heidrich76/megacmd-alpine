# Testing of MEGAcmd mega-sync Bug

Calling mega-sync directly after adding sync pair causes data moved to Rubbish folder.

## Description of Issue

MEGAcmd version: 2.1.1 to 2.5.2

Operating System: Linux in Alpine 3.23 container (tested on arm and x64 containers)

Build: Own MEGAcmd build using on Alpine Linux (see https://github.com/heidrich76/megacmd-alpine)


### Description / Steps

- Create a folder `Test` in MEGA cloud containing some larger files in a subfolder
- Create a local folder `/test` as synchronization target
- Create a script calling mega-sync directly after adding the folder, e.g.:
  ```bash
  mega-sync /test /Test
  mega-sync
  ```
- Wait a bit and call `mega-sync` again
- Some files in the cloud will be moved to the Rubbish folder and folder will only be synchronized partially.


### Example output

- ID LOCALPATH REMOTEPATH RUN_STATE STATUS ERROR SIZE FILES DIRS
- XcTsQ6co7Fo /test /Test Running Pending NO 1336.62 MB 651 134
- ...
- XcTsQ6co7Fo /test /Test Running Pending NO 1336.62 MB 651 134
- XcTsQ6co7Fo /test /Test Running Pending NO 50.10 MB 7 2 *data moved to Rubbish folder in cloud*
- XcTsQ6co7Fo /test /Test Running Synced NO 50.10 MB 7 2


### Observation

Calling mega-sync while status of newly added pair is "Pending" seems to cause the problem.
MEGAcmd creates local folders, which contain no files. When starting the synchronization process, the empty folders are synchronized back to the cloud, which causes the files to be moved to the Rubbish folder in the cloud drive.
Unfortunately the issue is hard to reproduce. I made the experiment multiple times and could reproduce the results with several runs.

Tested versions from 2.1.1 to 2.5.2 on Alpine (own builds) and 2.5.2.1 (code 2050201) on Ubuntu 22.04 (standard apt package). The behavior is reproduceable in all those settings. In my tests, one out of three tests failed and files were moved to the Rubbish folder.

During normal usage in the shell, it does not really matter, as there enough time between adding a sync pair and calling mega-sync again. However, as I'm working on a UI with automatic refresh, I stumbled across this behavior and it may cause data loss, if not immediately discovered for restoring data from the rubbish folder.


## Testing unter Alpine

1. Start container:
```bash
docker run -it --rm -v .:/workspace -w /workspace alpine:3.23 bash
```

2. Install MEGAcmd:
```bash
apk add --no-cache fuse gcompat util-linux zstd && \
  VERSION=v2.5.2b3 && \
  BASE_URL=https://github.com/heidrich76/megacmd-alpine/releases/download/$VERSION && \
  wget "$BASE_URL/megacmd_alpine_${VERSION}_$(uname -m).tar.gz" -O /tmp/megacmd.tar.gz && \
  tar -xzf /tmp/megacmd.tar.gz -C / && rm /tmp/megacmd.tar.gz
uuidgen > /etc/machine-id
```

3. Login to MEGA: `mega-login`

4. Create folder `/Test` in MEGA cloud and store some data in a sub-folder, e.g. `folder`:
```bash
for i in {1..5}; do
  curl -o test_$i.bin https://speed.cloudflare.com/__down?bytes=1000000
done
```

5. Run tests several time until data is moved to Rubbish folder:
```bash
./test.-reset.sh
./test
```


## Testing under Ubuntu

1. Start container:
```bash
docker run -it --rm -v .:/workspace -w /workspace ubuntu:24.04 bash
```

2. Install MEGAcmd:
```bash
apt update
apt install wget uuid-runtime
arch=$(uname -m)
case "$arch" in
  x86_64) pkg_arch=amd64 ;;
  aarch64) pkg_arch=arm64 ;;
esac
wget "https://mega.nz/linux/repo/xUbuntu_24.04/${pkg_arch}/megacmd-xUbuntu_24.04_${pkg_arch}.deb" -O megacmd.deb
apt install -y ./megacmd.deb && rm -rf ./megacmd.deb
uuidgen > /etc/machine-id
```

3. Login to MEGA: `mega-login`

4. Create folder `/Test` in MEGA cloud and store some data in a sub-folder, e.g. `folder` (using another machine or via MEGA web client):
```bash
for i in {1..5}; do
  curl -o test_$i.bin https://speed.cloudflare.com/__down?bytes=1000000
done
```

5. Run tests several time until data is moved to Rubbish folder:
```bash
./test-reset.sh
./test.sh
```


## Further Observations

- Behavior could not be reproduced when running directly on bare metal!
- All my previous tests were performed on containers running Ubuntu or Alpine Linux.
- There, the behavior can perfectly be reproduced running the containers on any ARM or AMD hardware.
- Even though `mega-sync` without arguments should do no harm, it seems to somehow disturb the synchronization process when run instantly after adding a new pair.
- This also works with fairly small file sizes. However, in my tests it only happened when those files were contained in some sub-folder and not placed directly in the synchronization root folder.
- Moreover, it is also not required to constantly polling status with `mega-sync`. It is sufficient to directly call `mega-sync` after adding a new pair once and then wait a couple of seconds for the behavior to occur. 
