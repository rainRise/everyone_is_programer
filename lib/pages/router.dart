import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/coding_zone_module.dart';
import 'package:kazumi/pages/platform/learning_zone_module.dart';
import 'package:kazumi/pages/platform/relax_zone_module.dart';

const defaultPlatformStartupPath = '/tab/learning/';

const defaultPlatformPageLabels = {
  '/tab/learning/': '资料',
  '/tab/coding/': '编程',
  '/tab/relax/': '放松',
};

String normalizePlatformStartupPath(Object? path) {
  if (path is! String) return defaultPlatformStartupPath;
  if (defaultPlatformPageLabels.containsKey(path)) return path;
  return defaultPlatformStartupPath;
}

class MenuRouteItem {
  final String path;
  final Module module;

  const MenuRouteItem({
    required this.path,
    required this.module,
  });
}

class MenuRoute {
  final List<MenuRouteItem> menuList;

  const MenuRoute(this.menuList);

  int get size => menuList.length;

  List<Module> get moduleList {
    return menuList.map((e) => e.module).toList();
  }

  List<ModuleRoute> get routes {
    return menuList.map((e) => ModuleRoute(e.path, module: e.module)).toList();
  }

  String getPath(int index) {
    return menuList[index].path;
  }
}

final MenuRoute menu = MenuRoute([
  MenuRouteItem(
    path: "/learning",
    module: LearningZoneModule(),
  ),
  MenuRouteItem(
    path: "/coding",
    module: CodingZoneModule(),
  ),
  MenuRouteItem(
    path: "/relax",
    module: RelaxZoneModule(),
  ),
]);
