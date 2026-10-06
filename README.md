# FontConverteriOS — embedded Python + fontTools

This is the next integration stage of the font conversion app. It keeps the original conversion algorithm but exposes it as a callable Python function and embeds CPython into the iOS app.

## Architecture

SwiftUI UI → Objective-C `FontPythonBridge` → embedded CPython → bundled `fontTools` → `.ttf/.ttc` output.

No server is required. Font files remain on-device.

## Included

- Original 16/17/18-26/SFUI templates from the previous project bundle.
- `PythonApp/fontTools` vendored from fontTools 4.63.0.
- `PythonApp/font_converter_ios.py` — callable conversion API.
- Objective-C CPython bootstrap + bridge.
- SwiftUI file picker/export UI.
- Runtime restore script for BeeWare Python-Apple-support 3.13-b14.
- Build-phase script that copies the correct iOS standard library into `PythonHome`.

## Important

The ~40 MB CPython support archive is intentionally **not** embedded in this ZIP. The restore script downloads the official release and verifies its SHA-256. This avoids distributing a large binary archive and makes the build reproducible.

The app is not an already-signed IPA. You still need macOS + Xcode and your own Apple signing identity to build/install it.

## Compatibility

The embedded Python runtime supports iOS 13+ according to Python-Apple-support documentation. Your Xcode deployment target can be raised as needed for the devices you want to support.
