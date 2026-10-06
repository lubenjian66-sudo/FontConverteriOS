#!/bin/bash
set -euo pipefail
ROOT="${SRCROOT}"
XC="$ROOT/Vendor/Python.xcframework"
DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/PythonHome"
rm -rf "$DEST"
mkdir -p "$DEST"
if [ "${EFFECTIVE_PLATFORM_NAME}" = "-iphoneos" ]; then SLICE="ios-arm64"; else SLICE="ios-arm64_x86_64-simulator"; fi
rsync -a "$XC/$SLICE/lib/" "$DEST/lib/"
