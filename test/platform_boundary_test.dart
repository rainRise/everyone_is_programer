import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default index module only exposes platform routes', () {
    final source = File('lib/pages/index_module.dart').readAsStringSync();

    expect(source, contains('r.module("/settings", module: SettingsModule())'));
    expect(source, isNot(contains('ImageViewer')));
    expect(source, isNot(contains('image_preview.dart')));
    expect(source, isNot(contains('VideoModule')));
    expect(source, isNot(contains('InfoModule')));
    expect(source, isNot(contains('SearchModule')));
    expect(source, isNot(contains('PopularController')));
    expect(source, isNot(contains('PluginsController')));
    expect(source, isNot(contains('DownloadController')));
  });

  test('default settings module only exposes platform settings', () {
    final source =
        File('lib/pages/settings/settings_module.dart').readAsStringSync();

    expect(source, contains('PlatformSettingsPage'));
    expect(source, contains('ThemeSettingsPage'));
    expect(source, contains('InterfaceSettingsPage'));
    expect(source, contains('AboutModule'));
    expect(source, isNot(contains('PlayerSettingsPage')));
    expect(source, isNot(contains('DanmakuModule')));
    expect(source, isNot(contains('PluginModule')));
    expect(source, isNot(contains('DownloadModule')));
    expect(source, isNot(contains('BangumiModule')));
    expect(source, isNot(contains('WebDavModule')));
    expect(source, isNot(contains('ProxyModule')));
  });

  test('platform about page stays free of legacy media service links', () {
    final source = File('lib/pages/about/about_page.dart').readAsStringSync();
    final moduleSource =
        File('lib/pages/about/about_module.dart').readAsStringSync();
    final metadataSource =
        File('lib/pages/platform/platform_metadata.dart').readAsStringSync();

    expect(source, contains('programmerPlatformTitle'));
    expect(source, contains('programmerPlatformVersion'));
    expect(source, contains('originalKazumiProjectUrl'));
    expect(source, contains('originalKazumiSourceUrl'));
    expect(source, isNot(contains('ApiEndpoints')));
    expect(source, isNot(contains('api_endpoints.dart')));
    expect(moduleSource, contains('programmerPlatformVersion'));
    expect(moduleSource, isNot(contains('ApiEndpoints')));
    expect(moduleSource, isNot(contains('api_endpoints.dart')));
    expect(metadataSource, contains('programmerPlatformVersion'));
    expect(metadataSource, contains('originalKazumiProjectUrl'));
    expect(metadataSource, contains('originalKazumiSourceUrl'));
    expect(source, isNot(contains('mortis')));
    expect(source, isNot(contains('iconUrl')));
    expect(source, isNot(contains('bangumiIndex')));
    expect(source, isNot(contains('dandanIndex')));
    expect(source, isNot(contains('trace.moe')));
    expect(source, isNot(contains('Bangumi')));
    expect(source, isNot(contains('DanDanPlay')));
    expect(source, isNot(contains('Pixiv')));
    expect(metadataSource, isNot(contains('bangumi.tv')));
    expect(metadataSource, isNot(contains('dandanplay.com')));
    expect(metadataSource, isNot(contains('trace.moe')));
  });

  test('platform logs use platform log helpers and file name', () {
    final appWidgetSource = File('lib/app_widget.dart').readAsStringSync();
    final logsPageSource =
        File('lib/pages/logs/logs_page.dart').readAsStringSync();
    final loggerSource = File('lib/utils/logger.dart').readAsStringSync();
    final platformStorageSource =
        File('lib/utils/platform_storage.dart').readAsStringSync();

    expect(loggerSource, contains('class PlatformLogger'));
    expect(loggerSource, contains('class KazumiLogger extends PlatformLogger'));
    expect(loggerSource, contains('platformLogFileName'));
    expect(loggerSource, contains('programmer_platform.log'));
    expect(loggerSource, isNot(contains('kazumi_logs.log')));
    expect(appWidgetSource, contains('PlatformLogger()'));
    expect(appWidgetSource, isNot(contains('KazumiLogger()')));
    expect(platformStorageSource, contains('PlatformLogger()'));
    expect(platformStorageSource, isNot(contains('KazumiLogger()')));
    expect(logsPageSource, contains('getLogsPath()'));
    expect(logsPageSource, contains('clearLogs()'));
    expect(logsPageSource, isNot(contains('kazumi_logs.log')));
    expect(logsPageSource, isNot(contains('getApplicationSupportDirectory')));
  });

  test('default app shell does not hard-code legacy linux app id', () {
    final appWidgetSource = File('lib/app_widget.dart').readAsStringSync();
    final metadataSource =
        File('lib/pages/platform/platform_metadata.dart').readAsStringSync();

    expect(appWidgetSource, contains('platformLinuxApplicationId'));
    expect(appWidgetSource, isNot(contains('io.github.Predidit.Kazumi')));
    expect(metadataSource, contains('platformLinuxApplicationId'));
    expect(metadataSource, contains('io.github.everyone_is_programmer'));
  });

  test('linux packaging metadata uses platform identity', () {
    final cmakeSource = File('linux/CMakeLists.txt').readAsStringSync();
    final desktopSource =
        File('assets/linux/io.github.everyone_is_programmer.Platform.desktop')
            .readAsStringSync();
    final postinstSource =
        File('assets/linux/DEBIAN/postinst').readAsStringSync();
    final postrmSource = File('assets/linux/DEBIAN/postrm').readAsStringSync();
    final nativeSource = File('linux/my_application.cc').readAsStringSync();

    expect(cmakeSource, contains('everyone_is_programmer'));
    expect(cmakeSource, contains('io.github.everyone_is_programmer.Platform'));
    expect(cmakeSource, isNot(contains('io.github.Predidit.Kazumi')));
    expect(desktopSource, contains('人人都是程序员'));
    expect(desktopSource, contains('Exec=everyone_is_programmer'));
    expect(desktopSource, contains('StartupWMClass=everyone_is_programmer'));
    expect(desktopSource,
        contains('Icon=io.github.everyone_is_programmer.Platform'));
    expect(desktopSource, isNot(contains('Kazumi')));
    expect(desktopSource, isNot(contains('kazumi')));
    expect(
      postinstSource,
      contains('/opt/everyone_is_programmer/everyone_is_programmer'),
    );
    expect(postinstSource, contains('/usr/bin/everyone_is_programmer'));
    expect(postinstSource, isNot(contains('/opt/Kazumi')));
    expect(postinstSource, isNot(contains('/usr/bin/kazumi')));
    expect(postrmSource, contains('/usr/bin/everyone_is_programmer'));
    expect(postrmSource, isNot(contains('/usr/bin/kazumi')));
    expect(nativeSource, contains('人人都是程序员'));
    expect(nativeSource,
        isNot(contains('gtk_header_bar_set_title(header_bar, "kazumi")')));
    expect(nativeSource,
        isNot(contains('gtk_window_set_title(window, "kazumi")')));
    expect(
      File('assets/linux/io.github.Predidit.Kazumi.desktop').existsSync(),
      isFalse,
    );
  });

  test('web app metadata uses platform identity', () {
    final indexSource = File('web/index.html').readAsStringSync();
    final manifestSource = File('web/manifest.json').readAsStringSync();

    expect(indexSource, contains('人人都是程序员'));
    expect(indexSource, contains('资料学习'));
    expect(indexSource, isNot(contains('kazumi')));
    expect(indexSource, isNot(contains('A new Flutter project')));
    expect(manifestSource, contains('人人都是程序员'));
    expect(manifestSource, contains('程序员平台'));
    expect(manifestSource, contains('资料学习'));
    expect(manifestSource, isNot(contains('kazumi')));
    expect(manifestSource, isNot(contains('A new Flutter project')));
  });

  test('android visible metadata uses platform identity', () {
    final androidManifestSource =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final zhTitle =
        File('fastlane/metadata/android/zh-CN/title.txt').readAsStringSync();
    final zhShortDescription = File(
      'fastlane/metadata/android/zh-CN/short_description.txt',
    ).readAsStringSync();
    final zhFullDescription = File(
      'fastlane/metadata/android/zh-CN/full_description.txt',
    ).readAsStringSync();
    final enTitle =
        File('fastlane/metadata/android/en-US/title.txt').readAsStringSync();
    final enShortDescription = File(
      'fastlane/metadata/android/en-US/short_description.txt',
    ).readAsStringSync();
    final enFullDescription = File(
      'fastlane/metadata/android/en-US/full_description.txt',
    ).readAsStringSync();

    expect(androidManifestSource, contains('android:label="人人都是程序员"'));
    expect(androidManifestSource, isNot(contains('android:label="Kazumi"')));
    expect(zhTitle, contains('人人都是程序员'));
    expect(zhShortDescription, contains('资料学习'));
    expect(zhFullDescription, contains('本地 RAG'));
    expect(enTitle, contains('Everyone Is Programmer'));
    expect(enShortDescription, contains('coding practice'));
    expect(enFullDescription, contains('local RAG'));
    for (final source in [
      zhTitle,
      zhShortDescription,
      zhFullDescription,
      enTitle,
      enShortDescription,
      enFullDescription,
    ]) {
      expect(source, isNot(contains('Kazumi')));
      expect(source, isNot(contains('anime')));
      expect(source, isNot(contains('danmaku')));
    }
  });

  test('apple visible metadata uses platform identity', () {
    final iosInfoSource = File('ios/Runner/Info.plist').readAsStringSync();
    final macosAppInfoSource =
        File('macos/Runner/Configs/AppInfo.xcconfig').readAsStringSync();
    final macosProjectSource =
        File('macos/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final macosSchemeSource =
        File('macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme')
            .readAsStringSync();

    expect(iosInfoSource, contains('<string>人人都是程序员</string>'));
    expect(iosInfoSource, isNot(contains('<string>Kazumi</string>')));
    expect(iosInfoSource, isNot(contains('<string>kazumi</string>')));
    expect(macosAppInfoSource, contains('PRODUCT_NAME = 人人都是程序员'));
    expect(macosAppInfoSource, isNot(contains('PRODUCT_NAME = kazumi')));
    expect(macosAppInfoSource,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.kazumi'));
    expect(macosProjectSource, contains('人人都是程序员.app'));
    expect(
      macosProjectSource,
      contains(
        r'$(BUILT_PRODUCTS_DIR)/人人都是程序员.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/人人都是程序员',
      ),
    );
    expect(macosProjectSource, isNot(contains('Kazumi.app')));
    expect(macosProjectSource, isNot(contains('PRODUCT_NAME = Kazumi')));
    expect(macosProjectSource,
        isNot(contains(r'$(BUILT_PRODUCTS_DIR)/kazumi.app')));
    expect(macosProjectSource,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.example.kazumi'));
    expect(macosSchemeSource, contains('BuildableName = "人人都是程序员.app"'));
    expect(macosSchemeSource, isNot(contains('BuildableName = "Kazumi.app"')));
  });

  test('windows external player temp stream files use platform prefix', () {
    final externalPlayerSource =
        File('windows/runner/external_player_utils.cpp').readAsStringSync();

    expect(externalPlayerSource, contains('everyone_is_programmer_stream_'));
    expect(externalPlayerSource, isNot(contains('kazumi_stream_')));
  });

  test('windows native shell keeps platform runtime identity', () {
    final mainSource = File('windows/runner/main.cpp').readAsStringSync();
    final shortcutSource =
        File('windows/runner/shortcut_utils.cpp').readAsStringSync();
    final resourceSource = File('windows/runner/Runner.rc').readAsStringSync();

    expect(mainSource, contains('everyone_is_programmer.win.mutex'));
    expect(mainSource, contains('kPlatformWindowTitle'));
    expect(mainSource, isNot(contains('kazumi.win.mutex')));
    expect(shortcutSource, contains('!everyone_is_programmer'));
    expect(shortcutSource, isNot(contains('!kazumi')));
    expect(resourceSource, contains('"Everyone Is Programmer"'));
    expect(resourceSource, contains('"everyone_is_programmer"'));
    expect(resourceSource, contains('"everyone_is_programmer.exe"'));
    expect(resourceSource, isNot(contains('"Kazumi"')));
    expect(resourceSource, isNot(contains('"kazumi.exe"')));
  });

  test('updater fallback installer file name uses platform identity', () {
    final updaterSource =
        File('lib/utils/auto_updater.dart').readAsStringSync();

    expect(
      updaterSource,
      contains("return 'everyone_is_programmer-\$version\$extension';"),
    );
    expect(
      updaterSource,
      isNot(contains("return 'Kazumi-\$version\$extension';")),
    );
  });

  test(
      'android background download notification channel uses platform identity',
      () {
    final serviceSource =
        File('lib/utils/background_download_service.dart').readAsStringSync();

    expect(
      serviceSource,
      contains("channelId: 'everyone_is_programmer_download_channel'"),
    );
    expect(
      serviceSource,
      isNot(contains("channelId: 'kazumi_download_channel'")),
    );
  });

  test('audio service runtime identifiers use platform identity', () {
    final audioSource =
        File('lib/utils/audio_controller.dart').readAsStringSync();

    expect(
      audioSource,
      contains("dBusName: 'io.github.everyone_is_programmer.channel.audio'"),
    );
    expect(
      audioSource,
      contains('androidNotificationChannelId:'),
    );
    expect(
      audioSource,
      contains("'io.github.everyone_is_programmer.channel.audio'"),
    );
    expect(
        audioSource, contains("identity: 'Everyone Is Programmer Playback'"));
    expect(
      audioSource,
      contains(
        "androidNotificationChannelName: 'Everyone Is Programmer Playback'",
      ),
    );
    expect(
      audioSource,
      isNot(contains('io.github.Predidit.Kazumi.channel.audio')),
    );
    expect(audioSource, isNot(contains('Kazumi Playback')));
  });

  test('platform startup stays free of legacy service initialization', () {
    final source = File('lib/pages/init_page.dart').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final appWidgetSource = File('lib/app_widget.dart').readAsStringSync();
    final dialogHelperSource =
        File('lib/bean/dialog/dialog_helper.dart').readAsStringSync();
    final platformDialogSource =
        File('lib/pages/platform/platform_dialog.dart').readAsStringSync();
    final platformThemeProviderSource =
        File('lib/pages/platform/platform_theme_provider.dart')
            .readAsStringSync();
    final platformThemeColorsSource =
        File('lib/pages/platform/platform_theme_colors.dart')
            .readAsStringSync();
    final aboutSource =
        File('lib/pages/about/about_page.dart').readAsStringSync();
    final logsSource = File('lib/pages/logs/logs_page.dart').readAsStringSync();
    final interfaceSettingsSource =
        File('lib/pages/settings/interface_settings.dart').readAsStringSync();
    final themeSettingsSource =
        File('lib/pages/settings/theme_settings_page.dart').readAsStringSync();
    final platformStorageSource =
        File('lib/utils/platform_storage.dart').readAsStringSync();
    final platformUtilsSource =
        File('lib/utils/platform_utils.dart').readAsStringSync();
    final platformPaletteCardSource =
        File('lib/pages/platform/platform_palette_card.dart')
            .readAsStringSync();
    final menuSource = File('lib/pages/menu/menu.dart').readAsStringSync();
    final platformNativeControlAreaSource =
        File('lib/pages/platform/platform_native_control_area.dart')
            .readAsStringSync();
    final platformAppBarSource =
        File('lib/pages/platform/platform_app_bar.dart').readAsStringSync();

    expect(source, contains('normalizePlatformStartupPath'));
    expect(source, contains('themeProvider.setDynamic'));
    expect(source, isNot(contains('PluginsController')));
    expect(source, isNot(contains('BangumiSyncService')));
    expect(source, isNot(contains('WebDav')));
    expect(source, isNot(contains('DownloadController')));
    expect(source, isNot(contains('ShadersController')));
    expect(source, isNot(contains('WindowsShortcut')));
    expect(source, isNot(contains('rootBundle')));
    expect(mainSource, isNot(contains('ProxyManager')));
    expect(
        mainSource, isNot(contains("package:kazumi/utils/proxy_manager.dart")));
    expect(mainSource, isNot(contains('MediaKit.ensureInitialized')));
    expect(mainSource, isNot(contains("package:media_kit/media_kit.dart")));
    expect(mainSource, isNot(contains("package:kazumi/utils/utils.dart")));
    expect(mainSource, contains('PlatformThemeProvider'));
    expect(mainSource,
        contains("package:kazumi/pages/platform/platform_theme_provider.dart"));
    expect(mainSource,
        isNot(contains("package:kazumi/bean/settings/theme_provider.dart")));
    expect(source, isNot(contains("package:kazumi/utils/utils.dart")));
    expect(source, contains('PlatformThemeProvider'));
    expect(
      source,
      contains("package:kazumi/pages/platform/platform_theme_provider.dart"),
    );
    expect(source,
        isNot(contains("package:kazumi/bean/settings/theme_provider.dart")));
    expect(appWidgetSource, isNot(contains("package:kazumi/utils/utils.dart")));
    expect(appWidgetSource,
        isNot(contains("package:kazumi/utils/constants.dart")));
    expect(appWidgetSource, contains('PlatformThemeProvider'));
    expect(appWidgetSource,
        contains("package:kazumi/pages/platform/platform_theme_provider.dart"));
    expect(appWidgetSource,
        isNot(contains("package:kazumi/bean/settings/theme_provider.dart")));
    expect(appWidgetSource, contains('PlatformDialog'));
    expect(appWidgetSource,
        contains("package:kazumi/pages/platform/platform_dialog.dart"));
    expect(appWidgetSource,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(appWidgetSource, isNot(contains('KazumiDialog.')));
    expect(source, contains('PlatformDialog'));
    expect(
        source, contains("package:kazumi/pages/platform/platform_dialog.dart"));
    expect(source,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(source, isNot(contains('KazumiDialog.')));
    expect(aboutSource, contains('PlatformDialog'));
    expect(aboutSource,
        contains("package:kazumi/pages/platform/platform_dialog.dart"));
    expect(aboutSource,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(aboutSource, isNot(contains('KazumiDialog.')));
    expect(aboutSource, contains('PlatformAppBar'));
    expect(aboutSource,
        contains("package:kazumi/pages/platform/platform_app_bar.dart"));
    expect(aboutSource,
        isNot(contains("package:kazumi/bean/appbar/sys_app_bar.dart")));
    expect(logsSource, contains('PlatformDialog'));
    expect(logsSource,
        contains("package:kazumi/pages/platform/platform_dialog.dart"));
    expect(logsSource,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(logsSource, isNot(contains('KazumiDialog.')));
    expect(logsSource, contains('PlatformAppBar'));
    expect(logsSource,
        contains("package:kazumi/pages/platform/platform_app_bar.dart"));
    expect(logsSource,
        isNot(contains("package:kazumi/bean/appbar/sys_app_bar.dart")));
    expect(interfaceSettingsSource, contains('PlatformAppBar'));
    expect(
      interfaceSettingsSource,
      contains("package:kazumi/pages/platform/platform_app_bar.dart"),
    );
    expect(
      interfaceSettingsSource,
      isNot(contains("package:kazumi/bean/appbar/sys_app_bar.dart")),
    );
    expect(themeSettingsSource, contains('PlatformDialog'));
    expect(themeSettingsSource,
        contains("package:kazumi/pages/platform/platform_dialog.dart"));
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(themeSettingsSource, isNot(contains('KazumiDialog.')));
    expect(themeSettingsSource, contains('PlatformPaletteCard'));
    expect(themeSettingsSource,
        contains("package:kazumi/pages/platform/platform_palette_card.dart"));
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/bean/card/palette_card.dart")));
    expect(themeSettingsSource, contains('PlatformThemeProvider'));
    expect(themeSettingsSource,
        contains("package:kazumi/pages/platform/platform_theme_provider.dart"));
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/bean/settings/theme_provider.dart")));
    expect(themeSettingsSource, contains('platformColorThemeTypes'));
    expect(themeSettingsSource,
        contains("package:kazumi/pages/platform/platform_theme_colors.dart"));
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/bean/settings/color_type.dart")));
    expect(themeSettingsSource, isNot(contains('colorThemeTypes')));
    expect(themeSettingsSource, contains('PlatformAppBar'));
    expect(themeSettingsSource,
        contains("package:kazumi/pages/platform/platform_app_bar.dart"));
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/bean/appbar/sys_app_bar.dart")));
    expect(platformDialogSource, contains('class PlatformDialog'));
    expect(platformDialogSource, contains('class PlatformDialogObserver'));
    expect(platformDialogSource, contains('hasPlatformDialog'));
    expect(platformDialogSource, contains('PlatformBottomSheet'));
    expect(platformDialogSource,
        isNot(contains("package:kazumi/bean/dialog/dialog_helper.dart")));
    expect(platformDialogSource, isNot(contains('KazumiDialog')));
    expect(platformDialogSource, isNot(contains('KazumiDialogObserver')));
    expect(platformPaletteCardSource, contains('class PlatformPaletteCard'));
    expect(platformPaletteCardSource,
        isNot(contains("package:kazumi/bean/card/palette_card.dart")));
    expect(menuSource, contains('PlatformNativeControlArea'));
    expect(
      menuSource,
      contains(
          "package:kazumi/pages/platform/platform_native_control_area.dart"),
    );
    expect(
      menuSource,
      isNot(contains(
        "package:kazumi/bean/widget/embedded_native_control_area.dart",
      )),
    );
    expect(
      platformNativeControlAreaSource,
      contains('class PlatformNativeControlArea'),
    );
    expect(platformNativeControlAreaSource, contains('PlatformStorage'));
    expect(platformNativeControlAreaSource, contains('PlatformSettingKey'));
    expect(
      platformNativeControlAreaSource,
      isNot(contains("package:kazumi/utils/storage.dart")),
    );
    expect(platformAppBarSource, contains('class PlatformAppBar'));
    expect(platformAppBarSource, contains('PlatformNativeControlArea'));
    expect(platformAppBarSource, contains('PlatformStorage'));
    expect(platformAppBarSource, contains('PlatformUtils'));
    expect(
      platformAppBarSource,
      isNot(contains("package:kazumi/bean/appbar/sys_app_bar.dart")),
    );
    expect(
      platformAppBarSource,
      isNot(contains(
        "package:kazumi/bean/widget/embedded_native_control_area.dart",
      )),
    );
    expect(
      platformAppBarSource,
      isNot(contains("package:kazumi/utils/utils.dart")),
    );
    expect(
      platformAppBarSource,
      isNot(contains("package:kazumi/utils/storage.dart")),
    );
    expect(dialogHelperSource, isNot(contains('class PlatformDialog')));
    expect(dialogHelperSource,
        isNot(contains("package:kazumi/utils/constants.dart")));
    expect(
        platformThemeProviderSource, contains('class PlatformThemeProvider'));
    expect(platformThemeProviderSource, contains('platformAppFontFamily'));
    expect(platformThemeProviderSource,
        isNot(contains("package:kazumi/bean/settings/theme_provider.dart")));
    expect(platformThemeProviderSource,
        isNot(contains("package:kazumi/utils/constants.dart")));
    expect(platformThemeColorsSource, contains('platformColorThemeTypes'));
    expect(platformThemeColorsSource, isNot(contains('colorThemeTypes')));
    expect(aboutSource, isNot(contains("package:kazumi/utils/utils.dart")));
    expect(
      themeSettingsSource,
      isNot(contains("package:kazumi/utils/utils.dart")),
    );
    expect(themeSettingsSource,
        isNot(contains("package:kazumi/utils/constants.dart")));
    expect(mainSource, contains('PlatformStorage.init()'));
    expect(mainSource, isNot(contains('GStorage.init()')));
    expect(platformStorageSource, contains('class PlatformStorage'));
    expect(platformStorageSource, contains('static Future<void> init()'));
    expect(appWidgetSource, contains('platformProgressIndicatorTheme'));
    expect(themeSettingsSource, contains('platformProgressIndicatorTheme'));
    expect(platformUtilsSource, contains('class PlatformUtils'));
    expect(platformUtilsSource, contains('PlatformLogger()'));
    expect(platformUtilsSource,
        isNot(contains("package:kazumi/request/config/api_endpoints.dart")));
    expect(platformUtilsSource,
        isNot(contains("package:kazumi/modules/danmaku/danmaku_module.dart")));
    expect(platformUtilsSource,
        isNot(contains("package:flutter_inappwebview_platform_interface")));
  });

  test('platform repositories use platform storage instead of legacy storage',
      () {
    const repositoryPaths = [
      'lib/pages/platform/platform_rag_repository.dart',
      'lib/pages/platform/platform_learning_progress_repository.dart',
      'lib/pages/platform/platform_relax_session_repository.dart',
    ];

    for (final path in repositoryPaths) {
      final source = File(path).readAsStringSync();

      expect(source, contains('PlatformSettingKey'));
      expect(source, isNot(contains("package:kazumi/utils/storage.dart")));
      expect(source, isNot(contains('GStorage')));
      expect(source, isNot(contains('SettingBoxKey')));
    }
  });
}
