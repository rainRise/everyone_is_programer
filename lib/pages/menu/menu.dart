import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/platform_native_control_area.dart';
import 'package:kazumi/pages/router.dart';
import 'package:kazumi/utils/platform_storage.dart';
import 'package:provider/provider.dart';

class ScaffoldMenu extends StatefulWidget {
  const ScaffoldMenu({super.key});

  @override
  State<ScaffoldMenu> createState() => _ScaffoldMenu();
}

class NavigationBarState extends ChangeNotifier {
  late int _selectedIndex = getDefaultSelectedIndex();
  bool _isHide = false;
  bool _isBottom = false;

  int get selectedIndex => _selectedIndex;

  bool get isHide => _isHide;

  bool get isBottom => _isBottom;

  int getDefaultSelectedIndex() {
    final defaultPage =
        normalizePlatformStartupPath(PlatformStorage.setting.get(
      PlatformSettingKey.defaultStartupPage,
      defaultValue: defaultPlatformStartupPath,
    ));

    switch (defaultPage) {
      case "/tab/learning/":
        return 0;
      case "/tab/coding/":
        return 1;
      case "/tab/relax/":
        return 2;
      default:
        return 0;
    }
  }

  void updateSelectedIndex(int pageIndex) {
    _selectedIndex = pageIndex;
    notifyListeners();
  }

  void hideNavigate() {
    _isHide = true;
    notifyListeners();
  }

  void showNavigate() {
    _isHide = false;
    notifyListeners();
  }
}

class _ScaffoldMenu extends State<ScaffoldMenu> {
  final PageController _page = PageController();

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => NavigationBarState(),
        child: Consumer<NavigationBarState>(builder: (context, state, _) {
          return OrientationBuilder(builder: (context, orientation) {
            state._isBottom = orientation == Orientation.portrait;
            return orientation != Orientation.portrait
                ? sideMenuWidget(context, state)
                : bottomMenuWidget(context, state);
          });
        }));
  }

  Widget bottomMenuWidget(BuildContext context, NavigationBarState state) {
    return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: _page,
            itemCount: menu.size,
            itemBuilder: (_, __) => const RouterOutlet(),
          ),
        ),
        bottomNavigationBar: state.isHide
            ? const SizedBox(height: 0)
            : NavigationBar(
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.school),
                    icon: Icon(Icons.school_outlined),
                    label: '资料',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.code),
                    icon: Icon(Icons.code_outlined),
                    label: '编程',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.spa),
                    icon: Icon(Icons.spa_outlined),
                    label: '放松',
                  ),
                ],
                selectedIndex: state.selectedIndex,
                onDestinationSelected: (int index) {
                  state.updateSelectedIndex(index);
                  Modular.to.navigate("/tab${menu.getPath(index)}/");
                },
              ));
  }

  Widget sideMenuWidget(BuildContext context, NavigationBarState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Row(
        children: [
          PlatformNativeControlArea(
            child: Visibility(
              visible: !state.isHide,
              child: NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                groupAlignment: 1.0,
                leading: const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Icon(Icons.terminal, size: 28),
                ),
                labelType: NavigationRailLabelType.selected,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.school),
                    icon: Icon(Icons.school_outlined),
                    label: Text('资料'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.code),
                    icon: Icon(Icons.code_outlined),
                    label: Text('编程'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.spa),
                    icon: Icon(Icons.spa_outlined),
                    label: Text('放松'),
                  ),
                ],
                selectedIndex: state.selectedIndex,
                onDestinationSelected: (int index) {
                  state.updateSelectedIndex(index);
                  Modular.to.navigate("/tab${menu.getPath(index)}/");
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menu.size,
                  itemBuilder: (_, __) => const RouterOutlet(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
