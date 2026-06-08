import 'dart:io';

import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_ce/hive.dart';
import 'package:kazumi/pages/platform/platform_app_bar.dart';
import 'package:kazumi/pages/platform/platform_dialog.dart';
import 'package:kazumi/pages/platform/platform_identity.dart';
import 'package:kazumi/pages/platform/platform_metadata.dart';
import 'package:kazumi/utils/platform_storage.dart';
import 'package:kazumi/utils/platform_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final exitBehaviorTitles = <String>['退出应用', '最小化至托盘', '每次都询问'];
  Box setting = PlatformStorage.setting;
  late int exitBehavior =
      setting.get(PlatformSettingKey.exitBehavior, defaultValue: 2);
  double _cacheSizeMB = -1;
  final MenuController menuController = MenuController();

  @override
  void initState() {
    super.initState();
    _getCacheSize();
  }

  void onBackPressed(BuildContext context) {
    if (PlatformDialog.observer.hasPlatformDialog) {
      PlatformDialog.dismiss();
      return;
    }
  }

  Future<Directory> _getCacheDir() async {
    Directory tempDir = await getTemporaryDirectory();
    return Directory('${tempDir.path}/libCachedImageData');
  }

  Future<void> _getCacheSize() async {
    Directory cacheDir = await _getCacheDir();

    if (await cacheDir.exists()) {
      int totalSizeBytes = await _getTotalSizeOfFilesInDir(cacheDir);
      double totalSizeMB = (totalSizeBytes / (1024 * 1024));

      if (mounted) {
        setState(() {
          _cacheSizeMB = totalSizeMB;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _cacheSizeMB = 0.0;
        });
      }
    }
  }

  Future<int> _getTotalSizeOfFilesInDir(final Directory directory) async {
    final List<FileSystemEntity> children = directory.listSync();
    int total = 0;

    try {
      for (final FileSystemEntity child in children) {
        if (child is File) {
          final int length = await child.length();
          total += length;
        } else if (child is Directory) {
          total += await _getTotalSizeOfFilesInDir(child);
        }
      }
    } catch (_) {}
    return total;
  }

  Future<void> _clearCache() async {
    final Directory libCacheDir = await _getCacheDir();
    await libCacheDir.delete(recursive: true);
    _getCacheSize();
  }

  void _showCacheDialog() {
    PlatformDialog.show(
      builder: (context) {
        return AlertDialog(
          title: const Text('缓存管理'),
          content: const Text(
            '缓存主要用于图片和临时资源。清除后再次打开相关内容时需要重新加载，确认要清除吗？',
          ),
          actions: [
            TextButton(
              onPressed: () {
                PlatformDialog.dismiss();
              },
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  _clearCache();
                } catch (_) {}
                PlatformDialog.dismiss();
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const PlatformAppBar(title: Text('关于')),
        // backgroundColor: Colors.transparent,
        body: SettingsList(
          maxWidth: 1000,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    Modular.to.pushNamed('/settings/about/license');
                  },
                  title:
                      Text('开源许可证', style: TextStyle(fontFamily: fontFamily)),
                  description: Text('查看所有开源许可证',
                      style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
            SettingsSection(
              title: Text('外部链接', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    launchUrl(Uri.parse(originalKazumiProjectUrl),
                        mode: LaunchMode.externalApplication);
                  },
                  title:
                      Text('原始工程主页', style: TextStyle(fontFamily: fontFamily)),
                  description: Text(
                    '当前平台基于原 Kazumi 工程壳继续演进。',
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                ),
                SettingsTile.navigation(
                  onPressed: (_) {
                    launchUrl(Uri.parse(originalKazumiSourceUrl),
                        mode: LaunchMode.externalApplication);
                  },
                  title:
                      Text('原始工程仓库', style: TextStyle(fontFamily: fontFamily)),
                  value:
                      Text('Github', style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
            if (PlatformUtils.isDesktop()) // 之后如果有非桌面平台的新选项可以移除
              SettingsSection(
                title: Text('默认行为', style: TextStyle(fontFamily: fontFamily)),
                tiles: [
                  SettingsTile.navigation(
                    onPressed: (_) {
                      if (menuController.isOpen) {
                        menuController.close();
                      } else {
                        menuController.open();
                      }
                    },
                    title:
                        Text('关闭时', style: TextStyle(fontFamily: fontFamily)),
                    value: MenuAnchor(
                      consumeOutsideTap: true,
                      controller: menuController,
                      builder: (_, __, ___) {
                        return Text(exitBehaviorTitles[exitBehavior]);
                      },
                      menuChildren: [
                        for (int i = 0; i < 3; i++)
                          MenuItemButton(
                            requestFocusOnHover: false,
                            onPressed: () {
                              exitBehavior = i;
                              setting.put(PlatformSettingKey.exitBehavior, i);
                              setState(() {});
                            },
                            child: Container(
                              height: 48,
                              constraints: BoxConstraints(minWidth: 112),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  exitBehaviorTitles[i],
                                  style: TextStyle(
                                    color: i == exitBehavior
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            SettingsSection(
              title: Text('平台信息', style: TextStyle(fontFamily: fontFamily)),
              tiles: [
                SettingsTile.navigation(
                  title: Text('当前身份', style: TextStyle(fontFamily: fontFamily)),
                  value: Text(
                    programmerPlatformTitle,
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                ),
                SettingsTile.navigation(
                  title: Text('版本', style: TextStyle(fontFamily: fontFamily)),
                  value: Text(
                    programmerPlatformVersion,
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    Modular.to.pushNamed('/settings/about/logs');
                  },
                  title: Text('错误日志', style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    _showCacheDialog();
                  },
                  title: Text('清除缓存', style: TextStyle(fontFamily: fontFamily)),
                  value: _cacheSizeMB == -1
                      ? Text('统计中...', style: TextStyle(fontFamily: fontFamily))
                      : Text('${_cacheSizeMB.toStringAsFixed(2)}MB',
                          style: TextStyle(fontFamily: fontFamily)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
