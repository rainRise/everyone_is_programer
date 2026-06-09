import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'platform_code_audit_rules.dart';

enum CodeAuditReportType {
  snippet,
  project,
}

extension CodeAuditReportTypeLabel on CodeAuditReportType {
  String get label {
    return switch (this) {
      CodeAuditReportType.snippet => '片段审计',
      CodeAuditReportType.project => '项目审计',
    };
  }
}

class CodeAuditSavedReport {
  const CodeAuditSavedReport({
    required this.fileName,
    required this.reportType,
    required this.path,
    required this.modifiedAt,
    required this.sizeBytes,
  });

  final String fileName;
  final CodeAuditReportType reportType;
  final String path;
  final DateTime modifiedAt;
  final int sizeBytes;
}

Future<File> saveCodeAuditReport(
  List<CodeAuditFinding> findings, {
  Directory? baseDirectory,
}) async {
  return _saveCodeAuditMarkdownReport(
    markdown: formatCodeAuditReport(findings),
    filePrefix: 'code_audit',
    baseDirectory: baseDirectory,
  );
}

Future<File> saveCodeAuditProjectReport(
  CodeAuditProjectReport report, {
  Iterable<CodeAuditRule>? enabledRules,
  Directory? baseDirectory,
}) async {
  return _saveCodeAuditMarkdownReport(
    markdown: formatCodeAuditProjectReport(
      report,
      enabledRules: enabledRules,
    ),
    filePrefix: 'project_code_audit',
    baseDirectory: baseDirectory,
  );
}

Future<File> _saveCodeAuditMarkdownReport({
  required String markdown,
  required String filePrefix,
  Directory? baseDirectory,
}) async {
  final reportDirectory = await _codeAuditReportDirectory(baseDirectory);

  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final reportFile = File(
    '${reportDirectory.path}${Platform.pathSeparator}${filePrefix}_$timestamp.md',
  );
  await reportFile.writeAsString(markdown);
  return reportFile;
}

Future<List<CodeAuditSavedReport>> listCodeAuditReports({
  Directory? baseDirectory,
  int limit = 6,
  CodeAuditReportType? reportType,
}) async {
  final reportDirectory = await _codeAuditReportDirectory(baseDirectory);
  if (!await reportDirectory.exists()) return [];

  final reports = <CodeAuditSavedReport>[];
  await for (final entity in reportDirectory.list(followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;

    final fileName = entity.uri.pathSegments.last;
    final detectedType = _reportTypeFromFileName(fileName);
    if (reportType != null && detectedType != reportType) continue;

    final stat = await entity.stat();
    reports.add(
      CodeAuditSavedReport(
        fileName: fileName,
        reportType: detectedType,
        path: entity.path,
        modifiedAt: stat.modified,
        sizeBytes: stat.size,
      ),
    );
  }

  reports.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  return reports.take(limit).toList(growable: false);
}

Future<String> readCodeAuditReportMarkdown(
  CodeAuditSavedReport report, {
  int maxBytes = 256 * 1024,
}) async {
  final file = File(report.path);
  if (!await file.exists()) {
    throw FileSystemException('审计报告不存在', report.path);
  }

  final size = await file.length();
  if (size > maxBytes) {
    throw FileSystemException('审计报告超过可复制大小限制', report.path);
  }

  return file.readAsString();
}

Future<void> deleteCodeAuditReport(CodeAuditSavedReport report) async {
  final file = File(report.path);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<File> restoreCodeAuditReportMarkdown(
  CodeAuditSavedReport report,
  String markdown,
) async {
  final file = File(report.path);
  await file.parent.create(recursive: true);
  return file.writeAsString(markdown);
}

class CodeAuditReportHistoryHighlights {
  const CodeAuditReportHistoryHighlights({
    required this.latestReport,
    required this.largestReport,
    required this.smallestReport,
  });

  final CodeAuditSavedReport? latestReport;
  final CodeAuditSavedReport? largestReport;
  final CodeAuditSavedReport? smallestReport;
}

String formatCodeAuditReportHistorySummary(
  List<CodeAuditSavedReport> reports, {
  String filterLabel = '全部',
  DateTime? generatedAt,
}) {
  final sortedReports = [...reports]
    ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  final generatedTime = generatedAt ?? DateTime.now();
  final typeCounts = <CodeAuditReportType, int>{};
  var totalBytes = 0;
  for (final report in sortedReports) {
    typeCounts.update(report.reportType, (count) => count + 1,
        ifAbsent: () => 1);
    totalBytes += report.sizeBytes;
  }
  final averageBytes =
      sortedReports.isEmpty ? 0 : (totalBytes / sortedReports.length).round();
  final highlights = summarizeCodeAuditReportHistoryHighlights(sortedReports);

  final buffer = StringBuffer()
    ..writeln('# 审计报告历史总览')
    ..writeln()
    ..writeln('- 生成时间：${_formatReportTimestamp(generatedTime)}')
    ..writeln('- 当前筛选：$filterLabel')
    ..writeln('- 报告数量：${sortedReports.length}')
    ..writeln('- 总大小：${_formatReportSize(totalBytes)}')
    ..writeln('- 平均大小：${_formatReportSize(averageBytes)}')
    ..writeln(
      '- 类型分布：${_formatReportTypeCounts(typeCounts)}',
    )
    ..writeln();

  buffer
    ..writeln(
      '- \u6700\u8fd1\u62a5\u544a\uff1a'
      '${_formatLatestReportSummary(highlights.latestReport)}',
    )
    ..writeln(
      '- \u6700\u5927\u62a5\u544a\uff1a'
      '${_formatReportSizeHighlight(highlights.largestReport)}',
    )
    ..writeln(
      '- \u6700\u5c0f\u62a5\u544a\uff1a'
      '${_formatReportSizeHighlight(highlights.smallestReport)}',
    )
    ..writeln();

  if (sortedReports.isEmpty) {
    buffer.writeln('暂无审计报告记录。');
    return buffer.toString();
  }

  buffer
    ..writeln('## 最近报告')
    ..writeln();
  for (var index = 0; index < sortedReports.length; index++) {
    final report = sortedReports[index];
    buffer
      ..writeln('${index + 1}. ${report.fileName}')
      ..writeln('   - 类型：${report.reportType.label}')
      ..writeln('   - 修改时间：${_formatReportTimestamp(report.modifiedAt)}')
      ..writeln('   - 大小：${_formatReportSize(report.sizeBytes)}')
      ..writeln('   - 路径：${report.path}');
  }

  return buffer.toString();
}

String formatCodeAuditReportHistoryFilterSummary(
  List<CodeAuditSavedReport> reports,
) {
  final totalBytes = reports.fold<int>(
    0,
    (sum, report) => sum + report.sizeBytes,
  );
  final averageBytes =
      reports.isEmpty ? 0 : (totalBytes / reports.length).round();
  final highlights = summarizeCodeAuditReportHistoryHighlights(reports);
  return '\u5f53\u524d\u7b5b\u9009\uff1a${reports.length} \u4efd / '
      '\u603b\u5927\u5c0f\uff1a${_formatReportSize(totalBytes)} / '
      '\u5e73\u5747\u5927\u5c0f\uff1a${_formatReportSize(averageBytes)} / '
      '\u6700\u8fd1\u62a5\u544a\uff1a'
      '${_formatLatestReportSummary(highlights.latestReport)} / '
      '\u6700\u5927\u62a5\u544a\uff1a'
      '${_formatReportSizeHighlight(highlights.largestReport)} / '
      '\u6700\u5c0f\u62a5\u544a\uff1a'
      '${_formatReportSizeHighlight(highlights.smallestReport)}';
}

CodeAuditReportHistoryHighlights summarizeCodeAuditReportHistoryHighlights(
  List<CodeAuditSavedReport> reports,
) {
  CodeAuditSavedReport? latestReport;
  CodeAuditSavedReport? largestReport;
  CodeAuditSavedReport? smallestReport;
  for (final report in reports) {
    if (latestReport == null ||
        report.modifiedAt.isAfter(latestReport.modifiedAt)) {
      latestReport = report;
    }
    if (largestReport == null || report.sizeBytes > largestReport.sizeBytes) {
      largestReport = report;
    }
    if (smallestReport == null || report.sizeBytes < smallestReport.sizeBytes) {
      smallestReport = report;
    }
  }
  return CodeAuditReportHistoryHighlights(
    latestReport: latestReport,
    largestReport: largestReport,
    smallestReport: smallestReport,
  );
}

String _formatLatestReportSummary(CodeAuditSavedReport? report) {
  if (report == null) return '\u65e0';
  return '${report.fileName} / ${_formatReportTimestamp(report.modifiedAt)} / '
      '${_formatReportSize(report.sizeBytes)}';
}

String _formatReportSizeHighlight(CodeAuditSavedReport? report) {
  if (report == null) return '\u65e0';
  return '${report.fileName} / ${_formatReportSize(report.sizeBytes)}';
}

CodeAuditReportType _reportTypeFromFileName(String fileName) {
  if (fileName.startsWith('project_code_audit_')) {
    return CodeAuditReportType.project;
  }
  return CodeAuditReportType.snippet;
}

Future<Directory> _codeAuditReportDirectory(Directory? baseDirectory) async {
  final base = baseDirectory ?? await getApplicationSupportDirectory();
  final reportDirectory = Directory(
    '${base.path}${Platform.pathSeparator}code_audit_reports',
  );
  await reportDirectory.create(recursive: true);
  return reportDirectory;
}

String _formatReportTypeCounts(Map<CodeAuditReportType, int> counts) {
  if (counts.isEmpty) return '无';
  return CodeAuditReportType.values
      .where((type) => counts.containsKey(type))
      .map((type) => '${type.label} ${counts[type]}')
      .join('，');
}

String _formatReportTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatReportSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}
