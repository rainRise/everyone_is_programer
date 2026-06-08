import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_code_audit_repository.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';

void main() {
  test('code audit repository lists recent markdown reports first', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit-history');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final olderReport = await saveCodeAuditReport(
      scanCodeSnippet(
        'print("old");',
        filePath: 'older.dart',
      ),
      baseDirectory: tempDir,
    );
    final newerReport = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'newer.dart',
      ),
      baseDirectory: tempDir,
    );

    await olderReport.setLastModified(DateTime(2026, 1, 1));
    await newerReport.setLastModified(DateTime(2026, 1, 2));

    final reports = await listCodeAuditReports(
      baseDirectory: tempDir,
      limit: 1,
    );

    expect(reports, hasLength(1));
    expect(reports.single.path, newerReport.path);
    expect(reports.single.fileName, newerReport.uri.pathSegments.last);
    expect(reports.single.reportType, CodeAuditReportType.snippet);
    expect(reports.single.modifiedAt, DateTime(2026, 1, 2));
    expect(reports.single.sizeBytes, greaterThan(0));
  });

  test('code audit repository labels snippet and project report history',
      () async {
    final tempDir =
        await Directory.systemTemp.createTemp('code-audit-history-type');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final snippetReport = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'snippet.dart',
      ),
      baseDirectory: tempDir,
    );
    final projectReport = await saveCodeAuditProjectReport(
      CodeAuditProjectReport(
        rootPath: tempDir.path,
        scannedFileCount: 1,
        skippedFileCount: 0,
        findings: scanCodeSnippet(
          'print("project");',
          filePath: 'lib/main.dart',
        ),
      ),
      baseDirectory: tempDir,
    );

    await snippetReport.setLastModified(DateTime(2026, 1, 1));
    await projectReport.setLastModified(DateTime(2026, 1, 2));

    final reports = await listCodeAuditReports(baseDirectory: tempDir);

    expect(reports.map((report) => report.reportType), [
      CodeAuditReportType.project,
      CodeAuditReportType.snippet,
    ]);
    expect(reports.first.fileName, startsWith('project_code_audit_'));
    expect(reports.last.fileName, startsWith('code_audit_'));
  });

  test('code audit repository filters report history by type', () async {
    final tempDir =
        await Directory.systemTemp.createTemp('code-audit-history-filter');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final snippetReport = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'snippet.dart',
      ),
      baseDirectory: tempDir,
    );
    final projectReport = await saveCodeAuditProjectReport(
      CodeAuditProjectReport(
        rootPath: tempDir.path,
        scannedFileCount: 1,
        skippedFileCount: 0,
        findings: scanCodeSnippet(
          'print("project");',
          filePath: 'lib/main.dart',
        ),
      ),
      baseDirectory: tempDir,
    );

    final projectReports = await listCodeAuditReports(
      baseDirectory: tempDir,
      reportType: CodeAuditReportType.project,
    );
    final snippetReports = await listCodeAuditReports(
      baseDirectory: tempDir,
      reportType: CodeAuditReportType.snippet,
    );

    expect(projectReports.map((report) => report.path), [projectReport.path]);
    expect(snippetReports.map((report) => report.path), [snippetReport.path]);
  });

  test('code audit repository formats report history summary markdown', () {
    final summary = formatCodeAuditReportHistorySummary(
      [
        CodeAuditSavedReport(
          fileName: 'code_audit_snippet.md',
          reportType: CodeAuditReportType.snippet,
          path: r'C:\tmp\code_audit_snippet.md',
          modifiedAt: DateTime(2026, 1, 1, 10),
          sizeBytes: 128,
        ),
        CodeAuditSavedReport(
          fileName: 'project_code_audit_app.md',
          reportType: CodeAuditReportType.project,
          path: r'C:\tmp\project_code_audit_app.md',
          modifiedAt: DateTime(2026, 1, 2, 10),
          sizeBytes: 256,
        ),
      ],
      filterLabel: '全部',
      generatedAt: DateTime(2026, 1, 3, 9, 30),
    );

    expect(summary, contains('# 审计报告历史总览'));
    expect(summary, contains('- 生成时间：2026-01-03 09:30'));
    expect(summary, contains('- 当前筛选：全部'));
    expect(summary, contains('- 报告数量：2'));
    expect(summary, contains('- 总大小：384 B'));
    expect(summary, contains('片段审计 1'));
    expect(summary, contains('项目审计 1'));
    expect(summary.indexOf('project_code_audit_app.md'),
        lessThan(summary.indexOf('code_audit_snippet.md')));
    expect(summary, contains(r'C:\tmp\project_code_audit_app.md'));
  });

  test('code audit repository reads saved markdown reports', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit-read');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final file = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'auth.dart',
      ),
      baseDirectory: tempDir,
    );
    final reports = await listCodeAuditReports(baseDirectory: tempDir);

    final markdown = await readCodeAuditReportMarkdown(reports.single);

    expect(reports.single.path, file.path);
    expect(markdown, contains('# 本地代码审计报告'));
    expect(markdown, contains('auth.dart:1'));
  });

  test('code audit repository deletes saved markdown reports', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit-delete');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final file = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'auth.dart',
      ),
      baseDirectory: tempDir,
    );
    final reports = await listCodeAuditReports(baseDirectory: tempDir);

    await deleteCodeAuditReport(reports.single);

    expect(await file.exists(), isFalse);
    expect(await listCodeAuditReports(baseDirectory: tempDir), isEmpty);
  });

  test('code audit repository restores deleted markdown reports', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit-restore');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final file = await saveCodeAuditReport(
      scanCodeSnippet(
        'const token = "abcdef123456";',
        filePath: 'auth.dart',
      ),
      baseDirectory: tempDir,
    );
    final report = (await listCodeAuditReports(baseDirectory: tempDir)).single;
    final markdown = await readCodeAuditReportMarkdown(report);

    await deleteCodeAuditReport(report);
    await restoreCodeAuditReportMarkdown(report, markdown);

    expect(await file.exists(), isTrue);
    expect(await file.readAsString(), markdown);
    expect(await listCodeAuditReports(baseDirectory: tempDir), hasLength(1));
  });

  test('code audit repository rejects oversized markdown copy reads', () async {
    final tempDir = await Directory.systemTemp.createTemp('code-audit-large');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final file = await saveCodeAuditReport(
      scanCodeSnippet(
        'print("large");',
        filePath: 'large.dart',
      ),
      baseDirectory: tempDir,
    );
    await file.writeAsString('x' * 32);
    final reports = await listCodeAuditReports(baseDirectory: tempDir);

    expect(
      () => readCodeAuditReportMarkdown(reports.single, maxBytes: 16),
      throwsA(isA<FileSystemException>()),
    );
  });
}
