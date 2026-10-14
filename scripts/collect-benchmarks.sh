#!/usr/bin/env bash
#
# Utaha OS — collect baseline / milestone benchmarks from a connected device.
#
# Usage: ./collect-benchmarks.sh [label]
#   e.g. ./collect-benchmarks.sh "M1-unmodified-base"
#
# Writes a report to stdout; append it to docs/benchmarks.md.
# Requires: adb, device connected and booted.
#
set -euo pipefail

LABEL="${1:-unlabelled}"

if ! command -v adb >/dev/null; then
  echo "ERROR: adb not found." >&2
  exit 1
fi
if [ "$(adb get-state 2>/dev/null || true)" != "device" ]; then
  echo "ERROR: no device. Check 'adb devices'." >&2
  exit 1
fi

echo "## Run: $LABEL"
echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

echo "### Identity"
echo '```'
adb shell getprop ro.product.device
adb shell getprop ro.product.cpu.abilist
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.build.display.id
echo '```'
echo

echo "### Free RAM (idle)"
echo '```'
adb shell free -m
echo '```'
echo

echo "### meminfo summary"
echo '```'
adb shell dumpsys meminfo | head -20
echo '```'
echo

echo "### Cold boot time (record manually with a stopwatch, or parse last boot)"
echo '```'
adb shell cat /proc/uptime
echo '```'
echo

echo "### Frame stats — launcher scroll"
echo "  (scroll the launcher, then run: adb shell dumpsys gfxinfo com.android.launcher3)"
echo

echo "### ZRAM"
echo '```'
adb shell 'cat /sys/block/zram0/disksize 2>/dev/null || echo no-zram'
adb shell 'cat /sys/block/zram0/comp_algorithm 2>/dev/null || true'
echo '```'
echo

echo "### vm sysctls"
echo '```'
for k in swappiness vfs_cache_pressure min_free_kbytes dirty_ratio dirty_background_ratio; do
  printf '%s = ' "$k"
  adb shell "cat /proc/sys/vm/$k" 2>/dev/null || echo n/a
done
echo '```'

echo
echo ">> Append this block to docs/benchmarks.md, then fill in the summary table."
