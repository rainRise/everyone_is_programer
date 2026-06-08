import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kazumi/utils/platform_storage.dart';

class PlatformNativeControlArea extends StatefulWidget {
  const PlatformNativeControlArea({
    super.key,
    required this.child,
    this.requireOffset = true,
  });

  final Widget child;
  final bool requireOffset;

  @override
  State<PlatformNativeControlArea> createState() =>
      _PlatformNativeControlAreaState();
}

class _PlatformNativeControlAreaState extends State<PlatformNativeControlArea> {
  bool showWindowButton = PlatformStorage.setting.get(
    PlatformSettingKey.showWindowButton,
    defaultValue: false,
  );

  EdgeInsets get insets {
    if (!showWindowButton || !widget.requireOffset) {
      return EdgeInsets.zero;
    }
    if (Platform.isMacOS) {
      return const EdgeInsets.only(top: 22);
    }
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: insets,
      child: widget.child,
    );
  }
}
