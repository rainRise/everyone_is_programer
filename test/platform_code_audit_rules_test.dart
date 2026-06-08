import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';

void main() {
  test('code audit scanner detects common local risks', () {
    final findings = scanCodeSnippet(
      '''
const token = "abcdef123456";
final url = "http://example.com";
console.log(url);
''',
      filePath: 'sample.dart',
    );

    expect(findings.length, 3);
    expect(findings.map((finding) => finding.rule.id), [
      'hardcoded-secret',
      'plain-http',
      'debug-print',
    ]);
    expect(findings.first.filePath, 'sample.dart');
    expect(findings.first.lineNumber, 1);
  });

  test('code audit scanner returns no findings for clean snippet', () {
    final findings = scanCodeSnippet(
      '''
final endpoint = Uri.https('example.com', '/api');
logger.info('request started');
''',
    );

    expect(findings, isEmpty);
  });

  test('code audit scanner detects private key material', () {
    final findings = scanCodeSnippet(
      '''
const key = """
-----BEGIN PRIVATE KEY-----
abc123
-----END PRIVATE KEY-----
""";
''',
      filePath: 'secrets.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'private-key-material',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.high);
    expect(findings.single.filePath, 'secrets.dart');
    expect(findings.single.lineNumber, 2);
  });

  test('code audit scanner detects disabled TLS verification', () {
    final findings = scanCodeSnippet(
      '''
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) => true;
''',
      filePath: 'network.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'tls-verification-disabled',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.high);
    expect(findings.single.filePath, 'network.dart');
    expect(findings.single.lineNumber, 2);
  });

  test('code audit scanner detects weak hash usage', () {
    final findings = scanCodeSnippet(
      '''
final digest = sha1.convert(payload);
''',
      filePath: 'crypto.dart',
    );

    expect(findings.map((finding) => finding.rule.id), ['weak-hash']);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'crypto.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects weak randomness usage', () {
    final findings = scanCodeSnippet(
      '''
final resetCode = Random().nextInt(999999);
''',
      filePath: 'auth.dart',
    );

    expect(findings.map((finding) => finding.rule.id), ['weak-randomness']);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'auth.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects enabled debug mode', () {
    final findings = scanCodeSnippet(
      '''
final config = {'debug': true};
''',
      filePath: 'config.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'debug-mode-enabled',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'config.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects SQL string interpolation', () {
    final findings = scanCodeSnippet(
      r'''
final sql = "SELECT * FROM users WHERE id = $userId";
''',
      filePath: 'repository.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'sql-string-interpolation',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.high);
    expect(findings.single.filePath, 'repository.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects command string interpolation', () {
    final findings = scanCodeSnippet(
      r'''
await Process.run('sh', ['-c', 'rm -rf $targetPath']);
''',
      filePath: 'cleanup.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'command-string-interpolation',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.high);
    expect(findings.single.filePath, 'cleanup.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects wildcard CORS configuration', () {
    final findings = scanCodeSnippet(
      '''
response.headers.set('Access-Control-Allow-Origin', '*');
''',
      filePath: 'server.dart',
    );

    expect(findings.map((finding) => finding.rule.id), ['wildcard-cors']);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'server.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects disabled cookie secure flag', () {
    final findings = scanCodeSnippet(
      '''
final cookie = CookieOptions(secure: false, httpOnly: true);
''',
      filePath: 'session.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'cookie-secure-disabled',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'session.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects disabled CSRF protection', () {
    final findings = scanCodeSnippet(
      '''
final options = SecurityOptions(csrfProtection: false);
''',
      filePath: 'forms.dart',
    );

    expect(findings.map((finding) => finding.rule.id), ['csrf-disabled']);
    expect(findings.single.rule.severity, CodeAuditSeverity.medium);
    expect(findings.single.filePath, 'forms.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner detects JWT none algorithm usage', () {
    final findings = scanCodeSnippet(
      '''
final jwtOptions = {'algorithm': 'none'};
''',
      filePath: 'auth.dart',
    );

    expect(findings.map((finding) => finding.rule.id), [
      'jwt-none-algorithm',
    ]);
    expect(findings.single.rule.severity, CodeAuditSeverity.high);
    expect(findings.single.filePath, 'auth.dart');
    expect(findings.single.lineNumber, 1);
  });

  test('code audit scanner can run selected local rules only', () {
    final findings = scanCodeSnippet(
      '''
const token = "abcdef123456";
final url = "http://example.com";
console.log(url);
''',
      enabledRuleIds: {'plain-http'},
    );

    expect(findings.map((finding) => finding.rule.id), ['plain-http']);
  });

  test('code audit report formats findings as markdown', () {
    final findings = scanCodeSnippet(
      'const password = "abcdef123456";',
      filePath: 'config.dart',
    );

    final report = formatCodeAuditReport(findings);

    expect(report, contains('# 本地代码审计报告'));
    expect(report, contains('风险总数：1'));
    expect(report, contains('严重级别：高危'));
    expect(report, contains('`config.dart:1`'));
    expect(report, contains('疑似硬编码密钥'));
  });

  test('code audit project report includes scan context as markdown', () {
    final findings = scanCodeSnippet(
      '''
const token = "abcdef123456";
final endpoint = "http://example.com";
''',
      filePath: 'lib/main.dart',
      enabledRuleIds: {'hardcoded-secret', 'plain-http'},
    );
    final projectReport = CodeAuditProjectReport(
      rootPath: r'D:\example\project',
      scannedFileCount: 3,
      skippedFileCount: 2,
      findings: findings,
    );

    final report = formatCodeAuditProjectReport(
      projectReport,
      enabledRules: localCodeAuditRules.where(
        (rule) => {'hardcoded-secret', 'plain-http'}.contains(rule.id),
      ),
    );

    expect(report, contains('# 项目代码审计报告'));
    expect(report, contains(r'项目路径：`D:\example\project`'));
    expect(report, contains('已扫描文件：3'));
    expect(report, contains('已跳过文件：2'));
    expect(report, contains('风险总数：2'));
    expect(report, contains('疑似硬编码密钥（高危，`hardcoded-secret`）'));
    expect(report, contains('明文 HTTP 地址（中危，`plain-http`）'));
    expect(report, contains('`lib/main.dart:1`'));
  });

  test('code audit scanner scans local project directories', () async {
    final tempDir = await Directory.systemTemp.createTemp('project-audit');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final libDir = Directory('${tempDir.path}/lib');
    final buildDir = Directory('${tempDir.path}/build');
    await libDir.create(recursive: true);
    await buildDir.create(recursive: true);
    await File('${libDir.path}/main.dart').writeAsString(
      '''
const token = "abcdef123456";
final endpoint = "http://example.com";
''',
    );
    await File('${buildDir.path}/generated.dart').writeAsString(
      'const token = "ignored-secret";',
    );

    final report = await scanCodeProject(tempDir.path);

    expect(report.scannedFileCount, 1);
    expect(report.skippedFileCount, 1);
    expect(report.findings.length, 2);
    expect(report.findings.map((finding) => finding.filePath).toList(), [
      'lib/main.dart',
      'lib/main.dart',
    ]);
  });

  test('code audit project scanner can run selected local rules only',
      () async {
    final tempDir =
        await Directory.systemTemp.createTemp('project-audit-filter');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await File('${tempDir.path}/main.dart').writeAsString(
      '''
const token = "abcdef123456";
final endpoint = "http://example.com";
''',
    );

    final report = await scanCodeProject(
      tempDir.path,
      enabledRuleIds: {'hardcoded-secret'},
    );

    expect(report.findings.map((finding) => finding.rule.id), [
      'hardcoded-secret',
    ]);
  });
}
