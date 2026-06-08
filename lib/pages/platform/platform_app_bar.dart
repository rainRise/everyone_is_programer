import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/pages/platform/platform_native_control_area.dart';
import 'package:kazumi/utils/platform_storage.dart';
import 'package:kazumi/utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

class PlatformAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? toolbarHeight;
  final Widget? title;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final PreferredSizeWidget? bottom;
  final bool needTopOffset;

  const PlatformAppBar({
    super.key,
    this.toolbarHeight,
    this.title,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.bottom,
    this.needTopOffset = true,
  });

  bool showWindowButton() {
    return PlatformStorage.setting.get(
      PlatformSettingKey.showWindowButton,
      defaultValue: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarActions = <Widget>[];
    if (actions != null) {
      appBarActions.addAll(actions!);
    }
    if (PlatformUtils.isDesktop()) {
      if (!showWindowButton()) {
        appBarActions.add(CloseButton(onPressed: () => windowManager.close()));
      }
      appBarActions.add(const SizedBox(width: 8));
    }

    return GestureDetector(
      onPanStart: (_) =>
          PlatformUtils.isDesktop() ? windowManager.startDragging() : null,
      child: AppBar(
        toolbarHeight: preferredSize.height,
        scrolledUnderElevation: 0.0,
        title: title != null
            ? PlatformNativeControlArea(
                requireOffset: needTopOffset,
                child: title!,
              )
            : null,
        centerTitle: Platform.isIOS,
        actions: appBarActions.map((action) {
          return PlatformNativeControlArea(
            requireOffset: needTopOffset,
            child: action,
          );
        }).toList(),
        leading: _buildLeading(context),
        leadingWidth: leadingWidth,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        bottom: bottom,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return PlatformNativeControlArea(
        requireOffset: needTopOffset,
        child: leading!,
      );
    }
    if (!Navigator.canPop(context)) {
      return null;
    }
    return PlatformNativeControlArea(
      requireOffset: needTopOffset,
      child: IconButton(
        onPressed: () {
          Navigator.maybePop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  @override
  Size get preferredSize {
    if (Platform.isMacOS && needTopOffset && showWindowButton()) {
      return Size.fromHeight((toolbarHeight ?? kToolbarHeight) + 22);
    }
    return Size.fromHeight(toolbarHeight ?? kToolbarHeight);
  }
}
