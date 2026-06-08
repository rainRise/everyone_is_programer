import 'package:flutter/material.dart';
import 'package:kazumi/pages/about/about_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/logs/logs_page.dart';
import 'package:kazumi/pages/platform/platform_identity.dart';
import 'package:kazumi/pages/platform/platform_metadata.dart';

class AboutModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child("/", child: (_) => const AboutPage());
    r.child("/logs", child: (_) => const LogsPage());
    r.child(
      "/license",
      child: (_) => const LicensePage(
        applicationName: programmerPlatformTitle,
        applicationVersion: programmerPlatformVersion,
        applicationLegalese: '开源许可证',
      ),
    );
  }
}
