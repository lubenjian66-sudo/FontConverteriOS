# Build checklist

1. Open the project in Xcode.
2. Run `PythonRuntime/Scripts/restore_python_runtime.sh` once.
3. Add `Vendor/Python.xcframework` to the app target as **Embed & Sign**.
4. Add `PythonApp` as a folder reference to Copy Bundle Resources.
5. Add the four Objective-C bridge files to Compile Sources.
6. Add a Run Script Build Phase with:
   `"$SRCROOT/PythonRuntime/Scripts/copy_python_home.sh"`
7. Build for a physical iPhone or Simulator.
8. Configure Signing & Capabilities with your Apple Developer team.
9. For an IPA: Product → Archive → Distribute App.

## Troubleshooting

- `PythonHome/PythonApp not found`: verify both folders are copied into the app bundle.
- `Python.framework not found`: verify the XCFramework is linked and Embed & Sign is selected.
- `ModuleNotFoundError: fontTools`: verify `PythonApp` is a folder reference, not a group whose contents are missing from Copy Bundle Resources.
- Simulator linker errors: ensure the simulator slice is present and Xcode is using the correct architecture.
