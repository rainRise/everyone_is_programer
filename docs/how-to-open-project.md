# 项目打开与运行说明

这份说明用于从零打开本项目，并在本地运行当前 Flutter 程序员学习平台。

## 1. 准备环境

本项目是 Flutter 项目，根目录是：

```text
D:\SelfStudy\everyone_is_programer\Kazumi
```

需要准备：

- Flutter SDK：项目声明版本为 `3.44.0`
- Dart SDK：`>=3.3.4 <4.0.0`，通常随 Flutter 一起安装
- Git
- Windows 开发时建议安装 Visual Studio 的 Desktop development with C++ 工作负载
- 编辑器建议使用 VS Code 或 Android Studio

先确认 Flutter 可用：

```powershell
flutter --version
flutter doctor
```

如果 `flutter doctor` 提示缺少 Windows、Android 或 iOS 相关工具，按提示补齐对应平台环境即可。

## 2. 用 VS Code 打开

在 PowerShell 中进入项目目录：

```powershell
cd D:\SelfStudy\everyone_is_programer\Kazumi
code .
```

建议安装 VS Code 插件：

- Flutter
- Dart

打开后先执行依赖安装：

```powershell
flutter pub get
```

## 3. 用命令行运行

进入项目目录：

```powershell
cd D:\SelfStudy\everyone_is_programer\Kazumi
```

获取依赖：

```powershell
flutter pub get
```

查看可运行设备：

```powershell
flutter devices
```

在 Windows 桌面端运行：

```powershell
flutter run -d windows
```

如果要运行到 Chrome 或 Android 设备，把 `windows` 替换成 `flutter devices` 中显示的设备 id。

## 4. 常用验证命令

运行全部测试：

```powershell
flutter test
```

运行静态分析：

```powershell
dart analyze lib test
```

构建 Windows 桌面版：

```powershell
flutter build windows
```

构建产物默认位置：

```text
build\windows\x64\runner\Release\everyone_is_programmer.exe
```

## 5. 当前平台入口

当前版本已经改造成程序员学习平台，启动后主要入口包括：

- 资料学习区
- 编程区
- 放松区

如果只是体验当前平台功能，优先使用：

```powershell
flutter run -d windows
```

## 6. 常见问题

### 依赖下载失败

先确认网络和 Git 可用，再重试：

```powershell
flutter pub get
```

本项目部分依赖来自 Git 仓库，首次拉取可能较慢。

### Windows 无法运行

先执行：

```powershell
flutter doctor
```

重点检查 Windows toolchain 是否完整。通常需要 Visual Studio 的 C++ 桌面开发组件。

### 运行后不是预期页面

当前平台默认入口应进入程序员学习平台。如果你改过启动配置，优先检查：

```text
lib\main.dart
lib\pages\platform\
```

### 中文在 PowerShell 里显示乱码

源码和文档本身使用 UTF-8。若 PowerShell 显示乱码，可以先切换输出编码：

```powershell
chcp 65001
```

或者直接用 VS Code 打开文件查看。
