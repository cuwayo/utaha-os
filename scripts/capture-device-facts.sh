#!/usr/bin/env bash
#
# Utaha OS — capture device facts from a connected ugglite.
#
# RUN THIS WHILE STOCK MIUI IS ON THE DEVICE. Once LineageOS is flashed, some of
# this (the stock userspace ABI, the MIUI build identity) is gone for good.
#
# Read-only: this script only reads. It never writes to the device.
#
# Prerequisites on the device:
#   Settings -> About phone -> tap "MIUI version" 7x to enable Developer options
#   Settings -> Additional settings -> Developer options -> USB debugging: ON
#
# Usage:
#   ./capture-device-facts.sh              # print to stdout
#   ./capture-device-facts.sh > facts.txt  # save to a file
#
set -uo pipefail

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb not found. Install android-tools / platform-tools." >&2
  exit 1
fi

if [ "$(adb get-state 2>/dev/null || true)" != "device" ]; then
  echo "ERROR: no device in 'device' state." >&2
  echo "  - is USB debugging enabled?" >&2
  echo "  - did you accept the RSA prompt on the phone?" >&2
  echo "  - check 'adb devices'" >&2
  exit 1
fi

sh() { adb shell "$@" 2>/dev/null | tr -d '\r'; }
prop() { sh getprop "$1"; }
section() { printf '\n=== %s ===\n' "$1"; }

printf '# Utaha OS — device facts\n'
printf '# captured: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '# NOTE: captured while STOCK MIUI was installed.\n'

section "Identity"
for p in ro.product.device ro.product.model ro.product.name ro.product.brand \
         ro.product.manufacturer ro.product.board ro.board.platform \
         ro.build.version.release ro.build.version.sdk \
         ro.build.display.id ro.build.fingerprint ro.build.date \
         ro.miui.ui.version.name ro.miui.ui.version.code \
         ro.build.characteristics; do
  printf '%-32s %s\n' "$p" "$(prop "$p")"
done

section "CPU ABI (32-bit vs 64-bit — KEY QUESTION)"
for p in ro.product.cpu.abi ro.product.cpu.abilist \
         ro.product.cpu.abilist32 ro.product.cpu.abilist64 \
         ro.zygote ro.dalvik.vm.native.bridge; do
  printf '%-32s %s\n' "$p" "$(prop "$p")"
done

section "Bootloader / verified boot"
for p in ro.boot.flash.locked ro.boot.verifiedbootstate ro.boot.veritymode \
         ro.secureboot.lockstate ro.boot.bootloader ro.boot.hardware; do
  printf '%-32s %s\n' "$p" "$(prop "$p")"
done

section "SoC / hardware"
sh 'cat /proc/cpuinfo | grep -E "Hardware|Processor|model name" | head -5'
sh 'ls /sys/devices/system/cpu/ | grep -E "^cpu[0-9]+$" | wc -l | sed "s/^/cpu cores: /"'

section "Memory (RAM)"
sh 'free -m'
sh 'grep -E "^(MemTotal|MemAvailable|SwapTotal)" /proc/meminfo'

section "Storage"
sh 'df -h /data /system /cache 2>/dev/null'
sh 'cat /proc/partitions | head -30'

section "Partition layout (by-name)"
sh 'ls -la /dev/block/bootdevice/by-name/ 2>/dev/null'

section "Camera — sensor identity (the key unknown)"
echo '-- supported sensor libs --'
sh 'ls /vendor/lib/libmmcamera_*.so 2>/dev/null || ls /system/lib/libmmcamera_*.so 2>/dev/null'
echo '-- sensor config xml --'
sh 'ls /vendor/etc/overlayfs/*/camera/ 2>/dev/null; ls /vendor/etc/camera/ 2>/dev/null'
echo '-- kernel log (may be empty without root) --'
sh 'dmesg 2>/dev/null | grep -i -E "s5k3l8|ov13855|s5k5e8|ov16885|s5k3p8|imx[0-9]|camera.*sensor|sensor.*probe" | head -30'
echo '-- via root, if available --'
sh 'su -c "dmesg | grep -i -E \"s5k3l8|ov13855|s5k5e8|sensor\" | head -30"' 2>/dev/null
echo '-- camera daemon --'
sh 'dumpsys media.camera 2>/dev/null | grep -i -E "sensor|camera id|module" | head -20'

section "Flash / torch LED"
sh 'ls /sys/class/leds/ 2>/dev/null'
sh 'ls /sys/class/leds/*flash*/ 2>/dev/null'

section "Sensors"
sh 'ls /sys/class/sensors/ 2>/dev/null'
sh 'dumpsys sensorservice 2>/dev/null | head -20'

section "Battery / thermal"
sh 'cat /sys/class/power_supply/battery/capacity 2>/dev/null'
sh 'cat /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -10'

section "Kernel"
sh 'uname -a'
sh 'cat /proc/version'

printf '\n=== end ===\n'
printf 'Save this output and commit it to docs/device-facts.md.\n'
