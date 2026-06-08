import 'package:kazumi/pages/about/about_module.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/settings/interface_settings.dart';
import 'package:kazumi/pages/settings/platform_settings_page.dart';
import 'package:kazumi/pages/settings/theme_settings_page.dart';
import 'package:kazumi/pages/settings/displaymode_settings.dart';

class SettingsModule extends Module {
  @override
  void routes(r) {
    r.child("/", child: (_) => const PlatformSettingsPage());
    r.child("/platform", child: (_) => const PlatformSettingsPage());
    r.child("/theme", child: (_) => const ThemeSettingsPage());
    r.child(
      "/theme/display",
      child: (_) => const SetDisplayMode(),
    );
    r.child("/interface", child: (_) => const InterfaceSettingsPage());
    r.module("/about", module: AboutModule());
  }
}
