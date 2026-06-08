import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/learning_zone_page.dart';

class LearningZoneModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const LearningZonePage());
  }
}
