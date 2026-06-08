import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/utils/logger.dart';

class PlatformUtils {
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  static Future<bool> isLowResolution() async {
    if (Platform.isMacOS) {
      return false;
    }

    final screenInfo = _getScreenInfo();
    return screenInfo['height']! / screenInfo['ratio']! < 900;
  }

  static Map<String, double> _getScreenInfo() {
    final mediaQuery = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final screenSize =
        WidgetsBinding.instance.platformDispatcher.displays.first.size;
    final screenRatio = mediaQuery.devicePixelRatio;

    return {
      'width': screenSize.width,
      'height': screenSize.height,
      'ratio': screenRatio,
    };
  }

  static ThemeData oledDarkTheme(ThemeData defaultDarkTheme) {
    return defaultDarkTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: defaultDarkTheme.colorScheme.copyWith(
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
    );
  }

  static Future<bool> isRunningOnX11() async {
    if (!Platform.isLinux) {
      return false;
    }

    const platform = MethodChannel('com.predidit.kazumi/intent');
    try {
      return await platform.invokeMethod<bool>('isRunningOnX11') ?? false;
    } on PlatformException catch (error) {
      PlatformLogger().w(
        "Platform: failed to check X11 environment: '${error.message}'",
        error: error,
      );
      return false;
    }
  }
}
