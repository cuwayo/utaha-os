# Utaha OS

A lightweight custom Android ROM for the **Xiaomi Redmi Note 5A / Redmi Y1 Lite**
(codename **`ugglite`**, SoC MSM8917 / Snapdragon 425, Adreno 308, 2 GB RAM).

Goals: Material You design, low RAM use, smooth performance on weak hardware,
a custom kernel, and custom camera sensor / flash support.

The full specification is in [`docs/SPEC.md`](docs/SPEC.md) and is the source of truth.

---

## Status: M0 — Feasibility

M0 research is complete and verified against live sources.
See **[`docs/M0-findings.md`](docs/M0-findings.md)** — it corrects several
assumptions in the original spec (kernel is 4.19 not 3.18; userspace is 64-bit;
Material You / Android 16 is already available; there is no `device/xiaomi/ugglite`).

Current milestone: **M0** — no code has been built yet. Baseline benchmarks not yet recorded.

---

## Repository layout

```
utaha/
  .repo/local_manifests/utaha.xml   # all custom repos (verified against live sources)
  device/xiaomi/                    # device trees (from LineageOS, via repo sync)
  vendor/xiaomi/                    # proprietary blobs (from TheMuppets, via repo sync)
  kernel/xiaomi/msm8937/            # forked as utaha-kernel-ugglite
  vendor/utaha/                     # branding, overlays, apps, product makefiles  <-- ours
  docs/                             # benchmarks, status, licenses, build notes     <-- ours
  scripts/                          # helper scripts                               <-- ours
```

The **utaha-owned** layer is `vendor/utaha/`, `docs/`, `scripts/` and
`.repo/local_manifests/utaha.xml`. Everything under `device/`, `vendor/xiaomi/`
and `kernel/` comes from upstream git repos declared in the local manifest.

---

## Hosts

| Host | Arch | Role |
|---|---|---|
| `95.216.212.168` | **arm64** | OTA server + website. **Cannot build AOSP/LineageOS.** |
| TBD (x86_64) | x86_64 | **Build host** — required per SPEC §3. Not yet chosen. |

See [`docs/build-notes.md`](docs/build-notes.md).

---

## Quick start

```bash
# on the x86_64 build host only:
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
cp /path/to/utaha/.repo/local_manifests/utaha.xml .repo/local_manifests/
repo sync -c -j8 --no-tags
source build/envsetup.sh
breakfast utaha_ugglite-userdebug
mka bacon
```

---

## Working rules

See SPEC §13. In short: milestone by milestone, never skip M0 or the baseline
benchmarks, verify every repo/branch/property against live sources, and never
claim an improvement without numbers in `docs/benchmarks.md`.
