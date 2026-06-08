import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/coding_zone_page.dart';

class CodingZoneModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const CodingZonePage());
  }
}
