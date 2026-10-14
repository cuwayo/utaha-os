# M0 — Feasibility Findings

**Date:** 2026-10-14
**Method:** every URL below was checked against live sources — `git ls-remote`
(authoritative branch lists), `raw.githubusercontent.com` (file contents), the
LineageOS download API, and the LineageOS wiki. Items seen only in forum search
snippets are labelled *forum-sourced* and are **not** independently verified.

---

## 1. Headline corrections to the specification

The spec (§4, §5, §9.1) assumed a much older device state than reality.
These are the verified facts, and they change M0/M1 planning:

| Spec assumption | Verified reality |
|---|---|
| Stock kernel is Linux 3.18.x; we fork that | LineageOS kernel is **4.19.325** (`android_kernel_xiaomi_msm8937`, branch `lineage-23.2`). The stock MiCode drop `ulysse-n-oss` is 3.18.31 but we should **not** use it. |
| Userspace may be 32-bit (Android Go target) | Userspace is **64-bit**: `TARGET_ARCH := arm64`, `TARGET_CPU_ABI := arm64-v8a`, secondary `armeabi-v7a`. Only the **camera HAL** is 32-bit (`BOARD_QTI_CAMERA_32BIT_ONLY := true`). |
| Material You may require a risky Android 12+ port (Option B) | **Material You is available today with no port.** Official LineageOS shipped 19.1 (Android 12L) → 23.2 (Android 16) for this device. |
| Ceiling may be Android 10/11 | Ceiling is **Android 16** (`lineage-23.2-20260820-nightly-Mi8917-signed.zip`, `os_sdk_level: 36`). |
| There may be a `device/xiaomi/ugglite` tree | There is **no such repo** (404). ugglite is folded into the unified **`Mi8917`** target. |
| Kernel 3.18 lacks PSI/eBPF → lmkd blockers | Kernel is 4.19 — most of those blockers do not apply. Verify each individually. |

**Consequence:** SPEC §5's "Option A vs Option B" fork is moot. The realistic
choice is now *which LineageOS branch* (stability vs newest), not *whether*
Material You is reachable.

---

## 2. Device trees (verified)

ugglite is **not** a standalone device in LineageOS. It is the `Mi8917`
hardware variant of a unified target.

Confirmed in `android_device_xiaomi_Mi8937/lineage-23.2/BoardConfig.mk`:

```make
ifeq ($(PRODUCT_HARDWARE),Mi8917)
TARGET_OTA_ASSERT_DEVICE := ugglite,rolex,riva,Mi8917
else ifeq ($(PRODUCT_HARDWARE),Mi8937)
TARGET_OTA_ASSERT_DEVICE := land,santoni,ugg,Mi8937
```

So **ugglite = the `Mi8917` variant** (shares code with `rolex`/Redmi 4A and
`riva`/Redmi 5A). The `ugg` (Note 5A **Prime**) is the separate `Mi8937` variant.

| Repo | Path | Branches | Role |
|---|---|---|---|
| `LineageOS/android_device_xiaomi_Mi8917` | `device/xiaomi/Mi8917` | 19.1 … 23.2 | **Wrapper only** — README: *"Nothing is really here."* Pulls in Mi8937. |
| `LineageOS/android_device_xiaomi_Mi8937` | `device/xiaomi/Mi8937` | 19.1 … 23.2, 24.0 | **The real device tree** (`BoardConfig.mk`, `lineage_Mi8917.mk`, `device.mk`, `proprietary-files*.txt`). |
| `LineageOS/android_device_xiaomi_mithorium-common` | `device/xiaomi/mithorium-common` | 19.1 … 23.2, 24.0 | Shared common tree (arch, kernel config, audio, sepolicy, Wi-Fi). |

There is **no** `msm8917-common` repo — the common tree is `mithorium-common`.
The kernel-common config lives at `vendor/xiaomi/msm8937/common.config`.

### Wiki / maintenance status

- ugglite page: <https://wiki.lineageos.org/devices/Mi8917/variant3/>
  — *"Architecture: arm64"*, *"Kernel version: 4.19"*, models `MDE6 MDG6 MDT6`.
- **Warning:** the wiki now shows *"The Xiaomi Redmi Note 5A Lite is no longer
  maintained"* and the wiki metadata has `maintainers: []`, **yet** the download
  API still serves a signed 23.2 nightly (2026-08-20). Best reading: recently
  demoted; last official build still published. **This is a risk to track** —
  if official support ends, we own the device tree going forward.

---

## 3. Vendor blobs (verified)

| Repo | Branches | Notes |
|---|---|---|
| `TheMuppets/proprietary_vendor_xiaomi_Mi8917` | 19.1 … 23.2 | The vendor tree LineageOS uses for ugglite. Contains `proprietary/vendor/etc/overlayfs/ugglite/camera/camera_config.xml`. |
| `TheMuppets/proprietary_vendor_xiaomi_Mi8937` | — | Companion vendor for the `ugg`/Prime variants. |

`LineageOS/android_vendor_xiaomi_Mi8917` does **not** exist (404) — LineageOS
does not host proprietary blobs; TheMuppets does.

---

## 4. Kernel source (verified)

| Repo | Branch | Version | Notes |
|---|---|---|---|
| `LineageOS/android_kernel_xiaomi_msm8937` | `lineage-23.2` | **4.19.325** | The tree to fork as `utaha-kernel-ugglite`. |
| `LineageOS/android_kernel_xiaomi_msm8937` | `lineage-20` | 4.9.337 | Older branch, for reference. |
| `MiCode/Xiaomi_Kernel_OpenSource` | `ulysse-n-oss` | 3.18.31 | Stock Nougat drop (2018). Unified ugg+ugglite. **Superseded.** |
| `msm89x7-mainline/linux` | `msm89x7/6.12.5` … `6.14` | 6.x | Mainline port (active). Long-term option only. |

There is **no** `LineageOS/android_kernel_xiaomi_msm8917` (404). The ugglite
kernel repo is named `..._msm8937`.

**Arch confirmation:** `arch/arm64/configs/vendor/xiaomi/msm8937/mi8917.config`
returns HTTP 200; the `arch/arm/...` equivalent 404s → built **arm64**.

---

## 5. Maximum Android version achieved

| Source | Version | Evidence |
|---|---|---|
| **Official LineageOS** | **Android 16 (23.2)** | Download API: `lineage-23.2-20260820-nightly-Mi8917-signed.zip`, `os_sdk_level: 36`, 2026-08-20. |
| Official LineageOS history | 19.1 (12L) → 20 (13) → 21 (14) → 22.2 (15) → 23.0/23.2 (16) | Wiki "previously supported versions". |
| Unofficial (XDA) | ~Android 13 | LineageOS 20 / crDroid 9.2 / PixelExperience Plus A13 ports. |

Official LineageOS is **ahead** of the unofficial scene here. The unofficial
Android 13 ports have *more* bugs than official 23.2.

---

## 6. Camera (legacy Qualcomm mm-camera / `camera_v2`)

Source: `TheMuppets/proprietary_vendor_xiaomi_Mi8917/lineage-23.2/proprietary/vendor/etc/overlayfs/ugglite/camera/camera_config.xml`

A given ugglite unit carries **one of two** rear sensors and **one of two**
front sensors, selected at runtime by the HAL:

| Position | Candidates |
|---|---|
| Rear 13 MP | **Samsung S5K3L8** (`s5k3l8_ohp0502_d6`) **or** **OmniVision OV13855** (`ov13855_f13855bd_d6`) |
| Front 5 MP | **Samsung S5K5E8** (`s5k5e8_oef0501_d6`) **or** (`s5k5e8_f5e8ybf_d6`) |

Sensor libraries present: `libmmcamera_s5k3l8_ohp0502_d6.so`,
`libmmcamera_ov13855_f13855bd_d6.so`, `libmmcamera_s5k5e8_oef0501_d6.so`,
`libmmcamera_s5k5e8_f5e8ybf_d6.so`.
Actuators: `libactuator_dw9714.so`, `libactuator_fp5510_f13855bd.so`.

**Unknown / to confirm on the real device:** which exact sensor a specific retail
unit has. This must be read from `dmesg` / `dumpsys media.camera` on the actual
handset, not assumed. Known *forum-sourced* bug: front camera black on some
LineageOS 20 builds (unverified).

**Flash:** spec §9.5 says use the existing `qcom,camera-flash` node — confirm
against the 4.19 tree (not 3.18) after sync.

---

## 7. Answers to SPEC §14 open questions

1. **Device / RAM** — still needs `getprop ro.product.device` on the physical unit. Expect `ugglite`.
2. **Bootloader unlocked? Stock MIUI version?** — **must be answered by the user.**
3. **Which x86_64 machine builds?** — **must be answered by the user.** The VPS is arm64.
4. **Material You priority** — resolved: native monet is available (Android 16). No risky port needed.
5. **GApps / microG / none** — default is **none** (see `vendor/utaha/config/`).
6. **Exact camera sensors** — rear ∈ {S5K3L8, OV13855}, front ∈ {S5K5E8 variants}; per-unit identity to be read from the device.

---

## 8. Recommended base choice (for user decision)

| Option | Branch | Android | Kernel | Pros | Cons |
|---|---|---|---|---|---|
| **A (recommended)** | `lineage-23.2` | 16 | 4.19.325 | Newest; native Material You; signed nightly exists as a baseline reference | Device flagged unmaintained; newest = least battle-tested on 2 GB |
| B | `lineage-22.2` | 15 | 4.19.325 | Still has monet; slightly more mature | One version behind |
| C | `lineage-20` | 13 | 4.9.337 | Older, lighter kernel | No longer newest; loses 2 years of fixes |

**Decision required from the user before M1.** Baseline benchmarks must be
recorded on the chosen base before any modification.
