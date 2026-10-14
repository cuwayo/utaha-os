# Utaha OS

A lightweight custom Android ROM for the **Xiaomi Redmi Note 5A / Redmi Y1 Lite**
(codename **`ugglite`**, SoC MSM8917 / Snapdragon 425, Adreno 308, 2 GB RAM).

Goals: Material You design, low RAM use, smooth performance on weak hardware,
a custom kernel, and custom camera sensor / flash support.

The full specification is in [`docs/SPEC.md`](docs/SPEC.md) and is the source of truth.

---

## Status: M0 — Feasibility

M0 research is complete and verified against live sources.
See **[`docs/M0-findings.md`](docs/M0-findings.md)**.

**Decisions taken (2026-10-14):**

| Question | Decision |
|---|---|
| Base branch | **`lineage-20` — Android 13**, kernel 4.9.337 |
| Build host | `95.216.212.168` (now **x86_64**, AMD EPYC-Genoa, 8 cores, 15 GB RAM, 301 GB disk) |
| GApps / microG | **None** for now |
| Bootloader | Already unlocked |
| Device current state | Runs **postmarketOS**, **no Android installed** |

**Consequence of "no Android installed":** there is no Android baseline to
benchmark against, and no Android to fall back to. Establishing a working
LineageOS 20 boot **is** M1, and the postmarketOS→Android recovery path must be
written and verified first. See [`docs/build-notes.md`](docs/build-notes.md).

Current milestone: **M0** — no ROM built or flashed yet.

---

## Repository layout

```
utaha/
  manifests/utaha.xml               # canonical repo set (tracked)
  .repo/local_manifests/utaha.xml   # installed copy used by repo
  device/xiaomi/                    # device trees (via repo sync)
  vendor/xiaomi/                    # proprietary blobs (via repo sync)
  kernel/xiaomi/msm8937/            # forked as utaha-kernel-ugglite
  vendor/utaha/                     # branding, overlays, apps, product makefiles  <-- ours
  docs/                             # benchmarks, status, licenses, build notes     <-- ours
  scripts/                          # helper scripts                               <-- ours
```

The **utaha-owned** layer is `manifests/`, `vendor/utaha/`, `docs/` and
`scripts/`. Everything under `device/`, `vendor/xiaomi/` and `kernel/` comes
from upstream git repos declared in the manifest.

---

## Quick start

```bash
# on the build host (x86_64):
cd ~/utaha
./scripts/sync.sh          # repo init + sync, pinned to lineage-20
./scripts/build.sh         # breakfast utaha_ugglite-userdebug && mka bacon
```

---

## Working rules

See SPEC §13. In short: milestone by milestone, never skip M0 or the baseline
benchmarks, verify every repo/branch/property against live sources, and never
claim an improvement without numbers in `docs/benchmarks.md`.
