#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Hexagon SDK installer
# -----------------------------------------------------------------------------

SDK_VERSION="${SDK_VERSION:-6.4.0.2}"
SDK_URL="https://github.com/snapdragon-toolchain/hexagon-sdk/releases/download/v${SDK_VERSION}/hexagon-sdk-v${SDK_VERSION}-amd64-lnx.tar.xz"
SDK_ROOT="${HEXAGON_SDK_ROOT:-$HOME/.hexagon-sdk/${SDK_VERSION}}"

echo "▶ Installing Hexagon SDK v${SDK_VERSION}"
echo "▶ Target directory: $SDK_ROOT"

mkdir -p "$SDK_ROOT"

TMP_ARCHIVE="/tmp/hexagon-sdk-${SDK_VERSION}.tar.xz"

echo "▶ Downloading Hexagon SDK..."
curl -fL "$SDK_URL" -o "$TMP_ARCHIVE"

echo "▶ Extracting Hexagon SDK..."
tar -xJf "$TMP_ARCHIVE" -C "$SDK_ROOT" --strip-components=1

# -----------------------------------------------------------------------------
# Export environment variables
# -----------------------------------------------------------------------------

HEXAGON_SDK_ROOT="$SDK_ROOT"
HEXAGON_TOOLS_ROOT="$SDK_ROOT/tools/HEXAGON_Tools/19.0.04"

echo "▶ HEXAGON_SDK_ROOT=$HEXAGON_SDK_ROOT"
echo "▶ HEXAGON_TOOLS_ROOT=$HEXAGON_TOOLS_ROOT"

# If running inside GitHub Actions, export to later steps
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "▶ Exporting environment variables to GitHub Actions"
  {
    echo "HEXAGON_SDK_ROOT=$HEXAGON_SDK_ROOT"
    echo "HEXAGON_TOOLS_ROOT=$HEXAGON_TOOLS_ROOT"
  } >> "$GITHUB_ENV"
else
  echo "▶ Exporting environment variables for current shell"
  export HEXAGON_SDK_ROOT
  export HEXAGON_TOOLS_ROOT
fi

# -----------------------------------------------------------------------------
# Sanity check
# -----------------------------------------------------------------------------

LIB_PATH="$SDK_ROOT/ipc/fastrpc/remote/ship/android_aarch64/libcdsprpc.so"

echo "▶ Sanity check: libcdsprpc.so"

if [[ ! -f "$LIB_PATH" ]]; then
  echo "❌ Expected lib missing at:"
  echo "   $LIB_PATH"
  echo
  echo "🔍 Searching for libcdsprpc.so under $SDK_ROOT:"
  find "$SDK_ROOT" -name "libcdsprpc.so" -print || true
  echo
  echo "📂 Listing ipc/fastrpc tree (if present):"
  ls -la "$SDK_ROOT/ipc" || true
  ls -la "$SDK_ROOT/ipc/fastrpc" || true
  exit 1
fi

echo "✅ Hexagon SDK installed correctly at $SDK_ROOT"