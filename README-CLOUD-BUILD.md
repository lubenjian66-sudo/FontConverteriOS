# 不用 Mac 构建 .app

这个项目可以通过 GitHub Actions 的 macOS 构建机生成 iPhone 真机用的 `FontConverter.app`。

## 步骤

1. 新建一个 GitHub 仓库。
2. 把本目录全部上传到仓库根目录。
3. 打开仓库的 **Actions**。
4. 选择 **Build iOS .app**。
5. 点击 **Run workflow**。
6. 构建完成后，在该次运行页面的 **Artifacts** 下载 `FontConverter-iOS-app`。
7. 解压得到 `FontConverter.app`。

这是**未签名**的 `.app`。它不能像普通 App 那样直接双击安装；你的越狱设备需要使用适合你当前 iOS/越狱环境的安装方式，或者之后再进行签名。

## 重要

- GitHub Actions 使用 macOS 构建机，因为 iOS 构建需要完整 Xcode 工具链。
- Python 运行时由 `PythonRuntime/Scripts/restore_python_runtime.sh` 下载，不把约百 MB 的 XCFramework 放进仓库。
- Python `fontTools` 中的 Linux `.so` 已移除；当前字体转换逻辑使用 fontTools 的纯 Python 部分处理 TTF/TTC。
- 如果后续使用到需要原生扩展的 fontTools 功能，需要针对 iOS 单独编译对应扩展，不能使用 Linux `.so`。
