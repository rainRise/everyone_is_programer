import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_identity.dart';

void main() {
  test('platform identity exposes programmer learning platform title', () {
    expect(programmerPlatformTitle, '人人都是程序员');
    expect(programmerPlatformSubtitle, contains('资料学习'));
    expect(programmerPlatformSubtitle, contains('编程实践'));
    expect(programmerPlatformSubtitle, contains('节奏恢复'));
    expect(enableLegacyKazumiStartupServices, isFalse);
  });
}
