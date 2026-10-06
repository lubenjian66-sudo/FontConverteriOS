#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VENDOR="$ROOT/Vendor"
mkdir -p "$VENDOR"
VERSION="3.13-b14"
ARCHIVE="$VENDOR/Python-3.13-iOS-support.b14.tar.gz"
URL="https://github.com/beeware/Python-Apple-support/releases/download/${VERSION}/Python-3.13-iOS-support.b14.tar.gz"
SHA="8b5cb76ef8d8a2946052479358eeec9d54b4496cb60920e175ec1489b5cf7963"
if [ ! -f "$ARCHIVE" ]; then curl -L --fail --retry 3 -o "$ARCHIVE" "$URL"; fi
echo "$SHA  $ARCHIVE" | shasum -a 256 -c -
rm -rf "$VENDOR/Python.xcframework"
tar -xzf "$ARCHIVE" -C "$VENDOR"
echo "Python runtime restored to $VENDOR/Python.xcframework"
