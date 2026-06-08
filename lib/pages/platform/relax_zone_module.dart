import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/relax_zone_page.dart';

class RelaxZoneModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const RelaxZonePage());
  }
}
