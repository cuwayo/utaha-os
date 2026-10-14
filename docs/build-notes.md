# Build notes

## Hosts

| Host | Arch | Spec | Role |
|---|---|---|---|
| `95.216.212.168` | **x86_64** | AMD EPYC-Genoa, 8 cores, 15 GB RAM, 301 GB disk, 8 GB swap | **Build host** (decided) + OTA server + website |

The host was re-provisioned on 2026-10-14 and is now **x86_64** (it was arm64
before). It therefore satisfies SPEC §3's architecture requirement and is being
used as the build host.

### SPEC §3 requirement check

| Requirement | Actual | Status |
|---|---|---|
| x86_64 Linux | x86_64 | ✅ |
| Ubuntu 22.04/24.04 | **Ubuntu 26.04 LTS** | ⚠️ newer than specified; untested with `repo`/AOSP |
| 16 GB RAM minimum | 15 GiB | ⚠️ just under |
| 32 GB recommended | 15 GiB | ❌ |
| 300 GB+ SSD | 301 GB (287 GB free) | ✅ (tight — the full tree + build needs ~250 GB) |
| 8+ cores | 8 | ✅ (minimum) |
| 16 GB+ swap | 8 GB | ⚠️ consider raising |
| ccache 50 GB+ | not installed | ❌ to install |

**Assessment:** viable but at the low end. 15 GB RAM is under the 16 GB
minimum, and a full `mka bacon` on 8 cores with 15 GB RAM will be slow and may
need `-j4` rather than `-j8`. Watch disk: 287 GB free is enough for one tree
plus `out/`, but leaves little headroom. ccache will consume a further 50 GB.

## Build host setup

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

> Note: `libncurses5` / `lib32ncurses5-dev` are the Ubuntu 22.04 package names.
> On Ubuntu 26.04 they may be renamed (`libncurses-dev`, `lib32ncurses-dev`) or
> unavailable. Verify before running — this is a known 26.04 risk.

## Build

```bash
cd ~/utaha
./scripts/sync.sh      # repo init -b lineage-20 + sync, installs the local manifest
./scripts/build.sh     # breakfast utaha_ugglite-userdebug && mka bacon
```

Or manually:

```bash
cd ~/utaha
repo init -u https://github.com/LineageOS/android.git -b lineage-20 --git-lfs
mkdir -p .repo/local_manifests
cp manifests/utaha.xml .repo/local_manifests/
repo sync -c -j8 --no-tags
source build/envsetup.sh
breakfast utaha_ugglite-userdebug
mka bacon
```

## Verified repo facts (see `M0-findings.md` for the full table)

Base branch **`lineage-20`** (Android 13). Verified on 2026-10-14:

- Device tree: `device/xiaomi/Mi8937` + `device/xiaomi/mithorium-common`
  (there is **no** `device/xiaomi/ugglite` — ugglite is the `Mi8917` variant).
- Vendor: `TheMuppets/proprietary_vendor_xiaomi_Mi8917`.
- Kernel: `LineageOS/android_kernel_xiaomi_msm8937` @ `lineage-20` = **4.9.337**.
- Defconfig: `arch/arm64/configs/vendor/xiaomi/msm8937/mi8917.config` (arm64 path
  confirmed; the `arch/arm/` path 404s).
- Target is **arm64**; only the camera HAL is 32-bit (`BOARD_QTI_CAMERA_32BIT_ONLY`).

---

## ⚠️ Device state: postmarketOS, no Android, no baseline

The device currently runs **postmarketOS** and has **no Android installed**.
This changes M0/M1 in three ways:

1. **No baseline exists.** SPEC §2 requires measuring the unmodified base before
   any change. There is no Android on the device to measure. The first working
   LineageOS 20 boot becomes the de-facto baseline — record it before modifying
   anything.
2. **No fallback.** SPEC §9.6 says keep a known-good boot image as fallback.
   Until M1 succeeds, the fallback is the postmarketOS image (and the stock MIUI
   fastboot ROM). Preserve both.
3. **Recovery path must be verified first.** How postmarketOS was installed
   (lk2nd? which partition?) determines how to get Android back. This is
   documented separately in `docs/recovery-plan.md` and must be confirmed
   against the actual device before flashing anything.

## Recovery / preparation (SPEC §4) — REQUIRED BEFORE FLASHING

1. **Back up** `persist`, `modemst1`, `modemst2`, `fsg` and EFS-type partitions.
   Losing `persist`/`modemst*` breaks Wi-Fi/BT MAC and IMEI. Do this first.
2. Keep the **stock MIUI fastboot ROM** for Mi Flash as the last-resort restore.
3. Keep the current **postmarketOS boot image** as the immediate fallback.
4. Always `fastboot boot <image>` before `fastboot flash`.
5. Verify the EDL path for MSM8917 before it is needed.

_See `docs/recovery-plan.md` (written from verified sources) for exact commands._
