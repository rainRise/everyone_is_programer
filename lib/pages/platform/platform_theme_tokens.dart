// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String platformAppFontFamily = 'MI_Sans_Regular';

/// `year2023` flag is deprecated since 3.29 but not default to false yet. Keep
/// it to false so the platform shell uses the latest Material 3 indicator.
const ProgressIndicatorThemeData platformProgressIndicatorTheme =
    ProgressIndicatorThemeData(year2023: false);

/// `year2023` flag is deprecated since 3.29 but not default to false yet. Keep
/// it to false so the platform shell uses the latest Material 3 slider.
const SliderThemeData platformSliderTheme = SliderThemeData(
  year2023: false,
  showValueIndicator: ShowValueIndicator.always,
);

const PageTransitionsTheme platformPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
  },
);
