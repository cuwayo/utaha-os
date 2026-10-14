#!/usr/bin/env bash
#
# Utaha OS — repo sync helper.
#
# Run this on the x86_64 BUILD HOST (SPEC §3). It does not work on arm64.
#
set -euo pipefail

BRANCH="${UTAHA_BRANCH:-lineage-20}"
MANIFEST_URL="${UTAHA_MANIFEST:-https://github.com/LineageOS/android.git}"
JOBS="${UTAHA_JOBS:-8}"
TREE="${UTAHA_TREE:-$HOME/utaha}"

echo "== Utaha sync =="
echo "branch : $BRANCH"
echo "tree   : $TREE"

# Refuse to run on arm64 (SPEC §3).
arch="$(uname -m)"
if [ "$arch" != "x86_64" ]; then
  echo "ERROR: build host must be x86_64, this is $arch." >&2
  echo "       AOSP/LineageOS do not build on arm64. See docs/build-notes.md" >&2
  exit 1
fi

if ! command -v repo >/dev/null; then
  echo "ERROR: 'repo' not found. Install it first (see docs/build-notes.md)." >&2
  exit 1
fi

mkdir -p "$TREE"
cd "$TREE"

if [ ! -d .repo ]; then
  echo ">> repo init"
  repo init -u "$MANIFEST_URL" -b "$BRANCH" --git-lfs
fi

# Install the local manifest that declares all Utaha repos.
# The canonical tracked copy lives at manifests/utaha.xml (the .repo/ directory
# is gitignored, so .repo/local_manifests/ is the *installed* location, not the
# source of truth).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p .repo/local_manifests
cp "$script_dir/../manifests/utaha.xml" .repo/local_manifests/utaha.xml
echo ">> local manifest installed"

echo ">> repo sync"
repo sync -c -j"$JOBS" --no-tags --force-sync --no-clone-bundle

echo "== sync done =="
