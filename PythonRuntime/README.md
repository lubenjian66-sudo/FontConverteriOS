# Embedded CPython runtime

This project uses BeeWare Python-Apple-support 3.13-b14. The official package provides an iOS XCFramework containing CPython and its standard library. iOS uses embedded Python; there is no standalone `python` executable/REPL.

## Setup on a Mac

1. Install Xcode and command-line tools.
2. From the project root run:

```sh
./PythonRuntime/Scripts/restore_python_runtime.sh
```

3. Add `Vendor/Python.xcframework` to the Xcode target and set it to **Embed & Sign**.
4. Add a Run Script Build Phase containing:

```sh
"$SRCROOT/PythonRuntime/Scripts/copy_python_home.sh"
```

Place this after Copy Bundle Resources and before the app is signed.
5. Add `PythonApp` as a folder reference / Copy Bundle Resources so `fontTools` is in the app bundle.
6. Add `PythonRuntimeManager.m`, `PythonRuntimeManager.h`, `FontPythonBridge.m`, and `FontPythonBridge.h` to the target.

The bridge initializes CPython, adds the bundled `PythonApp` to the module search path, and calls `font_converter_ios.convert_font(...)`.

### Why 3.13-b14?

Python-Apple-support currently publishes 3.13-b14 and 3.14-b10 releases. This project pins 3.13-b14 because it is a mature supported iOS embedding target and has published device/simulator support. The build script verifies the official SHA-256 before extraction.
