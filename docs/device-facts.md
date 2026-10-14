# Device facts (captured from the physical device)

Fill this by running `scripts/capture-device-facts.sh` with the phone connected
over adb. **Capture while stock MIUI is installed** — the stock userspace ABI and
MIUI build identity are gone once LineageOS is flashed.

| Field | Value | Source |
|---|---|---|
| Codename | _pending_ | `getprop ro.product.device` |
| Model | _pending_ | `getprop ro.product.model` |
| RAM | _pending_ | `free -m` |
| Storage | _pending_ | `df -h /data` |
| Android version | _pending_ | `getprop ro.build.version.release` |
| MIUI version | _pending_ | `getprop ro.miui.ui.version.name` |
| Build fingerprint | _pending_ | `getprop ro.build.fingerprint` |
| **CPU ABI (32/64-bit)** | _pending_ | `getprop ro.product.cpu.abilist` |
| Bootloader locked | _pending_ | `getprop ro.boot.flash.locked` |
| Kernel | _pending_ | `uname -a` |

## Camera sensors — THE KEY UNKNOWN

Which sensor a specific retail unit carries is not documented anywhere; it must
be read from the device. Expected candidates (from the vendor tree):

| Position | Candidates |
|---|---|
| Rear 13 MP | Samsung **S5K3L8** or OmniVision **OV13855** |
| Front 5 MP | Samsung **S5K5E8** (two module variants) |

**Confirmed on this unit:** _pending_ — see the `Camera` section of the capture output.

## Raw capture

_pending — paste `capture-device-facts.sh` output below_

```
(not yet captured)
```
