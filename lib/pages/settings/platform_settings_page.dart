import 'package:card_settings_ui/list/settings_list.dart';
import 'package:card_settings_ui/section/settings_section.dart';
import 'package:card_settings_ui/tile/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PlatformSettingsPage extends StatelessWidget {
  const PlatformSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return Scaffold(
      appBar: AppBar(title: const Text('平台设置')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('平台偏好', style: TextStyle(fontFamily: fontFamily)),
            tiles: [
              SettingsTile.navigation(
                onPressed: (_) => Modular.to.pushNamed('/settings/theme'),
                leading: const Icon(Icons.palette_outlined),
                title: Text('外观设置', style: TextStyle(fontFamily: fontFamily)),
                description: Text(
                  '调整主题、动态取色和桌面窗口外观。',
                  style: TextStyle(fontFamily: fontFamily),
                ),
              ),
              SettingsTile.navigation(
                onPressed: (_) => Modular.to.pushNamed('/settings/interface'),
                leading: const Icon(Icons.space_dashboard_outlined),
                title: Text('界面设置', style: TextStyle(fontFamily: fontFamily)),
                description: Text(
                  '管理默认启动页等平台界面行为。',
                  style: TextStyle(fontFamily: fontFamily),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('支持信息', style: TextStyle(fontFamily: fontFamily)),
            tiles: [
              SettingsTile.navigation(
                onPressed: (_) => Modular.to.pushNamed('/settings/about/'),
                leading: const Icon(Icons.info_outline_rounded),
                title: Text('关于平台', style: TextStyle(fontFamily: fontFamily)),
                description: Text(
                  '查看版本、许可证、日志和缓存管理。',
                  style: TextStyle(fontFamily: fontFamily),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
