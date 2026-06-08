import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:kazumi/pages/platform/platform_dialog.dart';
import 'package:kazumi/utils/platform_storage.dart';
import 'package:kazumi/utils/platform_utils.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/router.dart';
import 'package:kazumi/pages/platform/platform_theme_provider.dart';
import 'package:provider/provider.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  Box setting = PlatformStorage.setting;
  late final PlatformThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<PlatformThemeProvider>(context, listen: false);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkRunningOnX11();

    await _startDefaultPage();
    // delay to ensure that the default page is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _startDefaultPage() async {
    final storedStartupPage = setting.get(
      PlatformSettingKey.defaultStartupPage,
      defaultValue: defaultPlatformStartupPath,
    );
    final defaultStartupPage = normalizePlatformStartupPath(storedStartupPage);
    if (defaultStartupPage != storedStartupPage) {
      await setting.put(
          PlatformSettingKey.defaultStartupPage, defaultStartupPage);
    }
    // Workaround for dynamic_color. dynamic_color need PlatformChannel to get color, it takes time.
    // setDynamic here to avoid white screen flash when themeMode is dark.
    themeProvider.setDynamic(
        setting.get(PlatformSettingKey.useDynamicColor, defaultValue: false));
    Modular.to.navigate(defaultStartupPage);
  }

  Future<void> _checkRunningOnX11() async {
    if (!Platform.isLinux) {
      return;
    }
    bool isRunningOnX11 = await PlatformUtils.isRunningOnX11();
    if (isRunningOnX11) {
      await PlatformDialog.show(
        clickMaskDismiss: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('X11环境检测'),
              content: const Text(
                  '检测到您当前运行在 X11 环境下，人人都是程序员可能出现性能问题或界面异常，建议切换到 Wayland 以获得更好的体验。您是否希望在 X11 下继续使用？'),
              actions: [
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(
                    '退出',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    PlatformDialog.dismiss();
                  },
                  child: const Text('继续'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget();
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
