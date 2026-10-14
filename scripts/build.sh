#!/usr/bin/env bash
#
# Utaha OS — build helper.
#
# Run on the x86_64 build host after scripts/sync.sh.
#
set -euo pipefail

VARIANT="${UTAHA_VARIANT:-userdebug}"
TARGET="${UTAHA_TARGET:-utaha_ugglite}"
JOBS="${UTAHA_JOBS:-8}"
TREE="${UTAHA_TREE:-$HOME/utaha}"

arch="$(uname -m)"
if [ "$arch" != "x86_64" ]; then
  echo "ERROR: build host must be x86_64, this is $arch." >&2
  exit 1
fi

cd "$TREE"

# ccache (SPEC §3 wants 50 GB+)
export USE_CCACHE=1
export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
ccache -M 50G >/dev/null 2>&1 || true

source build/envsetup.sh
breakfast "${TARGET}-${VARIANT}"
mka bacon -j"$JOBS"

echo "== build done =="
echo "output: $TREE/out/target/product/*/lineage-*.zip"
