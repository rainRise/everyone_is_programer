import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_code_audit_repository.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';

void main() {
  test('code audit repository saves markdown reports locally', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final findings = scanCodeSnippet(
      'const token = "abcdef123456";',
      filePath: 'settings.dart',
    );

    final file = await saveCodeAuditReport(
      findings,
      baseDirectory: tempDir,
    );

    expect(await file.exists(), isTrue);
    final content = await file.readAsString();
    expect(content, contains('# 本地代码审计报告'));
    expect(content, contains('settings.dart:1'));
  });

  test('code audit repository saves project markdown reports locally',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('project-code-audit');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final findings = scanCodeSnippet(
      'const token = "abcdef123456";',
      filePath: 'lib/main.dart',
    );
    final report = CodeAuditProjectReport(
      rootPath: tempDir.path,
      scannedFileCount: 1,
      skippedFileCount: 0,
      findings: findings,
    );

    final file = await saveCodeAuditProjectReport(
      report,
      enabledRules: localCodeAuditRules.take(1),
      baseDirectory: tempDir,
    );

    expect(await file.exists(), isTrue);
    expect(file.uri.pathSegments.last, startsWith('project_code_audit_'));
    final content = await file.readAsString();
    expect(content, contains('# 项目代码审计报告'));
    expect(content, contains('已扫描文件：1'));
    expect(content, contains('疑似硬编码密钥（高危，`hardcoded-secret`）'));
    expect(content, contains('lib/main.dart:1'));
  });
}
