# Build notes

## Hosts

| Host | Arch | RAM | Role |
|---|---|---|---|
| `95.216.212.168` | **arm64** (aarch64) | 15 GB | OTA server + website only |
| _TBD_ | x86_64 | ≥16 GB | **Build host** — required, not yet chosen |

### ⚠️ The current VPS cannot build this ROM

SPEC §3 requires an **x86_64** build host. `95.216.212.168` is **aarch64**
(Ubuntu 26.04, 8 cores, 15 GB RAM, 150 GB disk, 8 GB swap). AOSP and LineageOS
do not build on arm64 — no arm64 host toolchain exists for a full `mka` build.

This host is correctly used for:
- the OTA update server,
- the project website and changelogs,
- git remotes / mirrors of our trees,
- holding `docs/` and release artifacts.

The build itself must run on an x86_64 machine meeting SPEC §3
(16 GB+ RAM, 300 GB+ SSD, 8+ cores, ccache 50 GB+).

**Open question for the user:** which x86_64 machine will build? (SPEC §14.3)

---

## Build host setup (x86_64)

```bash
sudo apt update
sudo apt install -y git-core gnupg flex bison build-essential zip curl \
  zlib1g-dev libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev \
  libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
  fontconfig python3 python-is-python3 ccache rsync
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
```

## Build (once the host exists)

```bash
cd ~/utaha
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
mkdir -p .repo/local_manifests
cp <this repo>/.repo/local_manifests/utaha.xml .repo/local_manifests/
repo sync -c -j8 --no-tags
source build/envsetup.sh
breakfast utaha_ugglite-userdebug
mka bacon
```

Or use `scripts/sync.sh` and `scripts/build.sh`.

## Verified repo facts (see `M0-findings.md` for the full table)

- Branch to start from: **`lineage-23.2`** (Android 16, kernel 4.19.325) — *pending user decision*.
- Device tree: `device/xiaomi/Mi8937` + `device/xiaomi/mithorium-common` (there is no `device/xiaomi/ugglite`).
- Vendor: `TheMuppets/proprietary_vendor_xiaomi_Mi8917`.
- Kernel: `LineageOS/android_kernel_xiaomi_msm8937`.
- Target is **arm64**; only the camera HAL is 32-bit.

## Recoverability (SPEC §4) — to prepare before any flashing

1. Unlock bootloader via Xiaomi Mi Unlock (waiting period applies, **wipes data**).
2. **Back up before flashing anything:** `persist`, `modemst1`, `modemst2`, `fsg`, EFS-type partitions.
3. Keep a known-good boot image and the stock MIUI fastboot ROM for Mi Flash.
4. Always test with `fastboot boot <image>` before `fastboot flash`.

_Recovery procedure to be written up and verified before M1._
