# Utaha OS: Full Specification (Android ROM for Redmi Note 5A "ugglite")

> **Provenance:** this file is a verbatim copy of the project specification as
> supplied by the project owner. It is the source of truth for the project.
> Where M0 research has proven an assumption here wrong, the correction lives in
> `docs/M0-findings.md` — this file is **not** edited to hide the original intent.

## 1. Overview
Utaha OS is a lightweight custom Android ROM for the **Xiaomi Redmi Note 5A / Redmi Y1 Lite (codename `ugglite`, Snapdragon 425 / MSM8917, 2 GB RAM or less)**. Goals: Material You design, low RAM use, fast and smooth on weak hardware, custom kernel, custom camera sensor and flash support.

Out of scope: writing a new OS from scratch, postmarketOS, Flutter, Slint (all dropped).

## 2. Targets and Success Metrics (measure before and after every milestone)
| Metric | Target |
|---|---|
| Free RAM after boot, idle (`free -m`, `dumpsys meminfo`) | 800 MB or more on 2 GB device |
| Cold boot time | under 45 s |
| App cold start (Settings, Camera, browser) | at least 15% faster than the unmodified base |
| Background app retention (apps kept alive) | at least as good as the base |
| Idle battery drain overnight | no worse than the base |
| UI smoothness | no sustained frame drops in launcher scroll and app drawer (`dumpsys gfxinfo`) |
Keep a `docs/benchmarks.md` with baseline (unmodified base) and each milestone's results. Do not claim an improvement without numbers.

## 3. Build Host
- **x86_64 Linux only** (Ubuntu 22.04 or 24.04). arm64 hosts cannot build AOSP or LineageOS.
- 16 GB RAM minimum (32 GB recommended), 300 GB+ SSD, 8+ cores, 16 GB+ swap, ccache 50 GB+.
- Tools: repo, git, build-essential, python3, adb, fastboot, ccache.
- The arm64 VPS is used only for the OTA server and website.

## 4. Device Facts (agent must verify from live sources)
- Codename `ugglite`, SoC MSM8917 (4x Cortex-A53), Adreno 308, 2 GB RAM (variant dependent), 16 GB storage, stock kernel Linux 3.18.x (Xiaomi/CAF downstream).
- `ugg` (Note 5A Prime, MSM8937) is a different device. Confirm with `getprop ro.product.device`.
- Check whether stock userspace is 32-bit or 64-bit (`ro.product.cpu.abilist`). A 32-bit-only userspace saves RAM and is what Android Go targets.
- Bootloader: Xiaomi Mi Unlock (waiting period, wipes data). Provide a **recovery plan first**: how to return to stock MIUI via Mi Flash (fastboot/EDL).
- Back up `persist`, `modemst1`, `modemst2`, `fsg` and EFS-type partitions before flashing anything.

## 5. Base Selection (M0, no silent choices)
1. Search GitHub, the LineageOS wiki, and XDA for `ugglite` / `msm8917-common` device, vendor and kernel trees. Record each with Android version, last commit date, and what works.
2. Choose by priority: working and maintained, then newest Android version.
3. **Material You (monet) needs Android 12 or newer.** If the newest working tree is older:
   - Option A: use it, and simulate the look (Material-You-style launcher such as Lawnchair, themed icons, overlays, fixed palette). No wallpaper-based dynamic color.
   - Option B: port to Android 12+ on kernel 3.18. List blockers (HALs, sepolicy, kernel features needed by newer Android such as eBPF, FUSE passthrough, cgroup and PSI support) and estimate effort.
4. Present the options with pros and cons, and let the user decide.
5. Use the **Android Go (low_ram) product configuration** as the starting point for a 2 GB device.

## 6. Source Layout
```
~/utaha/
  .repo/local_manifests/utaha.xml   # all custom repos
  device/xiaomi/ugglite/            # device tree
  device/xiaomi/msm8917-common/     # common tree (if used)
  vendor/xiaomi/ugglite/            # proprietary blobs
  kernel/xiaomi/msm8917/            # forked as utaha-kernel-ugglite
  vendor/utaha/                     # branding, overlays, apps, product makefiles
  docs/                             # benchmarks, status, licenses, build notes
```

## 7. Branding and Material You (vendor/utaha)
- Product `utaha_ugglite.mk`: name, brand, model, `ro.utaha.version`, fingerprint props. "Utaha OS" in About phone.
- Material You: use native monet if Android 12+, otherwise the simulated approach from section 5. Default seed color violet (configurable). Themed icons, rounded shapes, tonal surfaces.
- Resource overlays (RRO) for SystemUI, Settings, framework-res and launcher: colors, corner radii, QS layout, status bar.
- Fonts: open-licensed (for example Roboto Flex). Check licenses.
- Launcher: Lawnchair or Launcher3 (low-RAM friendly). Boot animation, wallpapers, ringtones.
- Cheap visuals: no blur, minimal shadows, short animations. Default animation scale 0.5x, no live wallpapers.

## 8. Low-RAM Userspace Tuning
- Debloat: remove unneeded apps, keep a minimal set (Settings, Dialer, Messages, Contacts, Camera, Gallery, Files, Browser, Clock).
- No GApps by default. Offer microG or minimal Play as an option, since Play services alone use a lot of RAM.
- Properties to evaluate and measure: `ro.config.low_ram=true`, `dalvik.vm.heapstartsize`, `dalvik.vm.heapgrowthlimit`, `dalvik.vm.heapsize`, `ro.sys.fw.bg_apps_limit`, ART compiler filter `speed-profile`, `persist.sys.fflag.override.settings_enable_monitor_phantom_procs` (only if on a version that has it; verify).
- Remove or disable heavy system services not needed (verify each against the base before removal).
- ZRAM: size around 50 to 75% of RAM, algorithm lz4 (fast) and test zstd (better ratio) if the kernel supports it. Tune `vm.swappiness`, `vm.vfs_cache_pressure`, `vm.min_free_kbytes`, and compare in `docs/benchmarks.md`.
- Memory killer: use lmkd properly configured for the kernel (see section 9.4).

## 9. Custom Kernel: Speed and Low RAM

### 9.1 Source and Toolchain
- Fork the Xiaomi msm8917 / ugglite kernel source (MiCode GitHub org or the LineageOS kernel for msm8917; verify exact repo and branch) as `utaha-kernel-ugglite`. One commit per change so it can be reverted and bisected.
- Use the toolchain the tree expects (often GCC 4.9 or an early clang). If switching to clang, apply the needed patches and prove it boots first.
- Ship as prebuilt `Image` (or `Image.gz-dtb`) plus modules, or build in-tree via the Lineage kernel build. Keep the stock config as baseline `utaha_ugglite_defconfig`.

### 9.2 Size and Memory Reduction (kernel footprint)
- Start from the working defconfig and remove unused features **one group at a time**, rebooting and testing each time:
  - Disable debug and tracing: `CONFIG_DEBUG_*`, ftrace, kprobes, `CONFIG_SCHED_DEBUG`, `CONFIG_PROFILING`, slab debugging, `CONFIG_PAGE_POISONING`, lockdep.
  - Disable unused drivers and filesystems (unused USB gadgets, NFS, unneeded network protocols, unused sensors and touchscreen drivers for other devices).
  - Enable size optimization: `CONFIG_CC_OPTIMIZE_FOR_SIZE` where it does not hurt speed (compare both builds).
  - Reduce `CONFIG_LOG_BUF_SHIFT` and disable verbose logging in production builds.
  - Use `CONFIG_KALLSYMS` minimization if not needed.
- Device tree reserved memory: audit `reserved-memory`, CMA, ION heaps and carveouts in the DTS. Reduce **only** what is oversized for this device (for example CMA pool, camera/display buffer pools), and test camera, video playback and display after each change. Never shrink modem, TZ or other secure carveouts. Report each region with its size and owner before changing it.
- Report kernel memory with `dmesg | grep -i memory`, `/proc/meminfo` and before/after `MemAvailable`.

### 9.3 Speed
- CPU governor: evaluate `interactive` (tuned), `schedutil` (backport if needed), and conservative parameters. Provide tuned values (`above_hispeed_delay`, `hispeed_freq`, `go_hispeed_load`, `min_sample_time`, `timer_rate`) and measure responsiveness plus battery.
- I/O scheduler: compare `cfq`, `deadline`, `noop`, and a lighter one (for example `zen`/`maple` only if the source is trusted and compatible). Keep the best for eMMC. Tune `read_ahead_kb`.
- Filesystem: prefer f2fs for `/data` if the device and base support it; confirm with fsck and stability tests.
- Scheduler and boost: reduce or remove aggressive input boost if it wastes power; keep a modest boost for touch. Verify the thermal config so the SoC does not throttle early.
- Network: `bbr` or `westwood` only if the kernel supports it; verify.
- Backport only what is proven and compatible with 3.18: zstd for ZRAM/zswap, cpu-boost improvements, bug fixes from newer CAF/LTS 3.18.y (merge upstream 3.18.y stable updates for fixes and security).

### 9.4 Memory Management (most important)
- **ZRAM** support with `lz4` (and `zstd` if backported), multiple compression streams, correct `zram_size`, and `swappiness` tuned.
- **Low memory killer:** 3.18 uses the in-kernel `lowmemorykiller` driver with `minfree` values, or userspace `lmkd`. Check which the base Android version expects. Android 10+ lmkd prefers PSI, which 3.18 does not have: either backport PSI (significant work), or configure lmkd in legacy mode and tune `minfree` and `adj` thresholds for 2 GB. Document the choice and test with real multitasking.
- **KSM:** evaluate, but it costs CPU on this SoC. Enable only if measurements show benefit.
- **zswap/zcache:** do not combine with ZRAM without testing.
- Tune `vm.*` sysctls via init rc: `swappiness`, `vfs_cache_pressure`, `dirty_ratio`, `dirty_background_ratio`, `min_free_kbytes`, `extra_free_kbytes` (where present).
- Avoid risky "RAM booster" hacks that only move numbers around.

### 9.5 Camera Sensor and Flash (custom drivers)
- Camera stack: **legacy Qualcomm mm-camera** with `msm_camera` v2 kernel drivers (`drivers/media/platform/msm/camera_v2/`). Confirm in the tree.
- Adding a sensor needs: kernel sensor entry and DTS node (I2C address, regulators, GPIOs, MCLK, CSI lanes), sensor userspace library (`libmmcamera_<sensor>.so`), sensor config XML and chromatix tuning in the vendor tree, and updated camera HAL config. If the sensor library is closed or missing, **report it as a blocker immediately; do not fabricate it.**
- Flash: use the existing LED/PMIC flash node (`qcom,camera-flash` or `qcom,leds`-style). Enforce max current and timeout limits. Expose torch via `/sys/class/leds/...` and the Android torch API. Add sepolicy rules; no permissive mode in releases.
- Ask the user for exact rear and front sensor models, the flash controller, datasheets or reference drivers. Never invent register values or init sequences.
- Verify with `dmesg`, `ls /dev/video* /dev/v4l-subdev*`, `dumpsys media.camera`, and a camera app (preview, capture, torch, flash capture).

### 9.6 Safety Rules for the Kernel
- Keep the stock kernel and a known-good boot image as fallback. Test via `fastboot boot` before flashing.
- One change group per commit and per test cycle. A failing change is reverted, not stacked on.
- Never overvolt, overclock or remove thermal protections.
- Run a stability test (at least 24 hours of mixed usage, plus stress and memory pressure tests) before every release.

## 10. SELinux and Security
- Add sepolicy for new nodes and services. No `permissive` in release builds.
- Keep SELinux enforcing, dm-verity/AVB status documented, and apply upstream security patches (kernel 3.18.y merges, Android security bulletin patches) where feasible.

## 11. Build and Release
```
repo init -u <lineageos manifest url> -b <verified branch>
repo sync -c -j8 --no-tags
source build/envsetup.sh
breakfast utaha_ugglite-userdebug
mka bacon
```
- Use `userdebug` during development and `user` for releases.
- Signing: generate release keys, use `sign_target_files_apks` and `ota_from_target_files`. Keep keys out of git.
- OTA: update server (LineageOS Updater server or similar) on the arm64 VPS, with a changelog and website.

## 12. Roadmap
- **M0: Feasibility.** Verify host, device, bootloader unlock, find trees, choose the Android version, record baseline benchmarks on the stock or base ROM.
- **M1: Boot unmodified base.** Everything stock works (Wi-Fi, data, calls, audio, camera, GPS, sensors).
- **M2: Rebrand and Material You.**
- **M3: Debloat and Android Go tuning.** Measure RAM and battery.
- **M4: Custom kernel, stock config.** Boots and passes all M1 checks.
- **M5: Kernel footprint and speed tuning (9.2, 9.3, 9.4).** Measure each change.
- **M6: Camera sensor driver and HAL integration.**
- **M7: Flash driver and torch.**
- **M8: Signed release, OTA, public changelog.**

## 13. Agent Working Rules
- Work milestone by milestone, and never skip M0 or the baseline benchmarks.
- Verify all repo URLs, branch names, package names and property names against live sources. If unsure or not found, say so.
- Give exact commands and complete files (makefiles, overlays, patches, defconfig diffs).
- Keep `docs/ugglite-status.md` (what works and what's broken: RIL, VoLTE, camera, GPS, sensors, audio, Bluetooth) and `docs/benchmarks.md`.
- Warn clearly about bricking, data wipe on unlock, closed vendor camera blobs, Play Integrity limits, and warranty.
- Keep a list of third-party licenses in `docs/LICENSES.md`.

## 14. Open Questions (agent should ask the user)
1. Confirm device with `getprop ro.product.device` (ugglite vs ugg) and RAM size.
2. Bootloader already unlocked? Which stock MIUI version is installed?
3. Which x86_64 machine will build the ROM?
4. Priority if Material You requires a risky Android 12 port: true monet, or stability on the best working older base?
5. GApps, microG, or none?
6. Exact camera sensor and flash models (stock and new)?
