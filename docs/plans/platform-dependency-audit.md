# 平台依赖审计

本文记录 `人人都是程序员` 平台模式下的依赖边界。当前仓库仍保留原 Kazumi 的大量 legacy 源码，因此依赖清理分为两步：先让默认平台路径不再初始化和路由到旧业务，再分批删除 legacy 源码和对应依赖。

## 默认平台路径

默认平台路径包括：

- `lib/main.dart`
- `lib/app_widget.dart`
- `lib/app_module.dart`
- `lib/pages/index_module.dart`
- `lib/pages/init_page.dart`
- `lib/pages/router.dart`
- `lib/pages/menu/menu.dart`
- `lib/pages/platform/**`
- `lib/pages/platform/platform_metadata.dart`
- `lib/pages/settings/platform_settings_page.dart`
- `lib/pages/settings/settings_module.dart`
- `lib/pages/settings/interface_settings.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `lib/pages/about/**`
- `lib/utils/platform_storage.dart`
- `lib/utils/logger.dart`

`test/platform_boundary_test.dart` 会守住这条默认路径，防止旧业务路由或旧服务初始化重新挂回平台入口。

## 平台默认路径仍需要的依赖

这些依赖仍被默认平台路径直接或间接使用：

- `flutter_modular`：模块路由。
- `provider`：主题状态注入。
- `dynamic_color`：动态配色。
- `flutter_displaymode`：Android 高刷设置和显示设置页。
- `hive_ce` / `hive_ce_flutter`：平台设置、学习进度、RAG 资料、放松记录。
- `path_provider`：Hive 路径、缓存目录、代码审计报告保存。
- `card_settings_ui`：平台设置、界面设置、主题设置、关于页。
- `url_launcher`：学习资源入口和关于页外部链接。
- `window_manager`：桌面窗口和标题栏行为。
- `tray_manager`：桌面托盘行为。
- `logger`：默认 app shell 和平台存储层使用 `PlatformLogger`；`KazumiLogger` 仅作为 legacy 源码兼容入口暂留。
- `path`：旧存储/平台审计相关路径处理仍有使用。

## Legacy 暂留依赖

这些依赖当前不应该在默认平台入口初始化，但由于 legacy 源码仍在仓库中，暂时不能直接从 `pubspec.yaml` 删除：

- 播放器和媒体栈：`media_kit`、`media_kit_video`、`media_kit_libs_video`、各平台 `media_kit_libs_*` overrides、`audio_service`、`audio_service_mpris`、`audio_service_win`、`audio_session`、`audio_video_progress_bar`、`flutter_volume_controller`。
- WebView 和反爬相关：`webview_windows`、`desktop_webview_window`、`flutter_inappwebview_*`、`cookie_jar`、`xpath_selector`、`xpath_selector_html_parser`、`html`。
- 视频产品功能：`canvas_danmaku`、`dlna_dart`、`webdav_client`、`saver_gallery`、`screen_brightness_*`、`scrollview_observer`、`flutter_foreground_task`、`open_filex`。
- 旧 UI 和资源能力：`flutter_rating_bar`、`flutter_svg`、`photo_view`、`image_picker`、`skeletonizer`。
- 生成和模型层：`mobx`、`flutter_mobx`、`mobx_codegen`、`hive_ce_generator`。
- 网络和更新：`dio`、`connectivity_plus`、`upgrader`。
- BBCode 和解析：`antlr4`。

这些包的后续删除条件是：对应 legacy 页面、模块、controller、repository、webview/player/download/bangumi/plugin 代码被移出默认仓库或移动到独立 legacy 包，并且 `dart analyze lib test` 不再需要它们。

## 已完成的依赖收口

- 默认 `IndexModule` 不再注册旧 controller/repository，也不再路由到 `/video`、`/info`、`/search`。
- 默认 `SettingsModule` 不再注册旧播放器、弹幕、插件、下载、Bangumi、WebDAV、代理设置。
- `InitPage` 不再初始化旧插件、Bangumi、WebDAV、下载、shader、快捷方式或旧更新检查。
- `main.dart` 不再调用 `MediaKit.ensureInitialized()`，平台默认启动不再初始化播放器运行时。
- `main.dart` 默认调用 `PlatformStorage.init()`，只打开平台需要的 `setting` box，不再打开旧收藏、历史、下载等 Hive box。
- 默认 `IndexModule` 不再注册共享图片预览路由，`cached_network_image` / `photo_view` 不再属于平台默认路由图。
- iOS `CFBundleDisplayName` / `CFBundleName` 与 macOS `PRODUCT_NAME` 已使用 `人人都是程序员`；Apple bundle id、Xcode module/project、MethodChannel 名称仍暂留。
- macOS Xcode Runner product reference、shared scheme `BuildableName` 与 RunnerTests `TEST_HOST` 已使用 `人人都是程序员.app`；bundle id、module 与 MethodChannel 名称仍暂留。
- 默认 `AppWidget` 和 `PlatformStorage` 已切换到 `PlatformLogger`；`KazumiLogger` 继续保留给 legacy 播放器、插件、WebView 等旧源码使用。
- 默认平台启动、主题、关于页与 shell 工具调用已切换到 `PlatformUtils`；`utils.dart` 继续作为 legacy 视频/WebView/弹幕工具集合暂留。
- 默认平台主题 token 已切换到 `platform_theme_tokens.dart`；`constants.dart` 继续作为 legacy 播放器、Bangumi header、快捷键与视频配置集合暂留。
- 默认 `main.dart` 不再启动时调用 `ProxyManager.applyProxy()`；代理管理器和 legacy Dio 网络客户端刷新继续保留给旧代理设置页。
- 默认平台 shell、初始化、About、日志和主题设置页已切换到 `PlatformDialog`；`KazumiDialog` 继续作为 legacy 弹窗兼容入口暂留。
- 默认平台 dialog 已在 `lib/pages/platform/platform_dialog.dart` 内独立实现；默认平台路径不再 import `bean/dialog/dialog_helper.dart`，也不再通过 `KazumiDialog` / `KazumiDialogObserver` 转发。

- 默认主题设置页的配色卡片已切换到 `lib/pages/platform/platform_palette_card.dart`；默认平台设置路径不再直接 import `bean/card/palette_card.dart`。
- 默认菜单的原生窗口控制占位组件已切换到 `lib/pages/platform/platform_native_control_area.dart`；默认菜单不再直接 import `bean/widget/embedded_native_control_area.dart`，该平台组件也不再读取 `utils/storage.dart`。
- 默认 About、日志、界面设置和主题设置页已切换到 `lib/pages/platform/platform_app_bar.dart`；这些默认页面不再直接 import `bean/appbar/sys_app_bar.dart`，平台 app bar 也不再依赖 `bean/widget/embedded_native_control_area.dart` 或 `utils/utils.dart`。
- 默认主题状态和配色列表已切换到 `lib/pages/platform/platform_theme_provider.dart` 与 `lib/pages/platform/platform_theme_colors.dart`；默认启动、AppWidget、InitPage 和主题设置页不再直接 import `bean/settings/theme_provider.dart` 或 `bean/settings/color_type.dart`。

## 下一步建议

1. 建立 legacy 入口策略：如果仍要保留旧功能，创建显式 `LegacyModule`；如果不保留，则分批删除旧页面和依赖。
2. 在每次删除依赖前运行 `dart analyze lib test` 和平台边界测试，避免隐式 import 断裂。
