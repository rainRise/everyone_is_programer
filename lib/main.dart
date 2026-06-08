import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kazumi/app_module.dart';
import 'package:kazumi/app_widget.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/platform_theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kazumi/utils/platform_storage.dart';
import 'package:kazumi/utils/platform_utils.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/pages/error/storage_error_page.dart';
import 'package:kazumi/pages/platform/platform_identity.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));
  }

  try {
    final hivePath = '${(await getApplicationSupportDirectory()).path}/hive';
    await Hive.initFlutter(hivePath);
    await PlatformStorage.init();
  } catch (e) {
    // Log the error for debugging (if logger is available)
    debugPrint('Storage initialization failed: $e');

    if (PlatformUtils.isDesktop()) {
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow(null, () async {
        // window_manager controls desktop visibility to avoid startup flicker.
        await windowManager.show();
        await windowManager.focus();
      });
    }
    runApp(MaterialApp(
        title: programmerPlatformTitle,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale.fromSubtags(
              languageCode: 'zh', scriptCode: 'Hans', countryCode: "CN")
        ],
        locale: const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: "CN"),
        builder: (context, child) {
          return const StorageErrorPage();
        }));
    return;
  }
  bool showWindowButton = await PlatformStorage.setting
      .get(PlatformSettingKey.showWindowButton, defaultValue: false);
  if (PlatformUtils.isDesktop()) {
    await windowManager.ensureInitialized();
    bool isLowResolution = await PlatformUtils.isLowResolution();
    WindowOptions windowOptions = WindowOptions(
      size: isLowResolution ? const Size(840, 600) : const Size(1280, 860),
      center: true,
      skipTaskbar: false,
      // macOS always hide title bar regardless of showWindowButton setting
      titleBarStyle: (Platform.isMacOS || !showWindowButton)
          ? TitleBarStyle.hidden
          : TitleBarStyle.normal,
      windowButtonVisibility: showWindowButton,
      title: programmerPlatformTitle,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // window_manager controls desktop visibility to avoid startup flicker.
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlatformThemeProvider(),
      child: ModularApp(
        module: AppModule(),
        child: const AppWidget(),
      ),
    ),
  );
}
