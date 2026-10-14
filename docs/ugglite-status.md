# ugglite — Status: what works and what is broken

Device: Xiaomi Redmi Note 5A / Y1 Lite (`ugglite`, MSM8917)
Maintained per milestone. Update this file after every test cycle.

**Current milestone: M0 (feasibility). No ROM built or flashed yet.**
Everything below is therefore *expected* status from upstream, not verified on our build.

| Area | Status | Notes |
|---|---|---|
| RIL (calls, SMS, data) | expected OK | upstream LineageOS 23.2 is a signed official build |
| VoLTE | **unknown** | must be tested on the physical unit; region-dependent |
| Camera | expected OK | legacy mm-camera; see `M0-findings.md` §6 for sensor candidates |
| GPS | expected OK | |
| Sensors | expected OK | |
| Audio | expected OK | |
| Bluetooth | expected OK | |
| Wi-Fi | expected OK | |
| Flash / torch | expected OK | to be re-verified after kernel changes |
| F2FS on /data | unknown | only if base supports it; test with fsck |

**Not yet tested on real hardware.** Every "expected OK" becomes a real result
only after M1. Do not report a working feature without having tested it.
