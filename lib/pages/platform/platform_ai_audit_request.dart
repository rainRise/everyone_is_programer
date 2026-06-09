import 'platform_code_audit_rules.dart';

class CodeAuditAiRequestDraft {
  const CodeAuditAiRequestDraft({
    required this.title,
    required this.contextSummary,
    required this.riskDigest,
    required this.locationDigest,
    required this.ruleDigest,
    required this.prompt,
  });

  final String title;
  final String contextSummary;
  final String riskDigest;
  final String locationDigest;
  final String ruleDigest;
  final String prompt;
}

CodeAuditAiRequestDraft buildCodeAuditAiRequestDraft({
  required List<CodeAuditFinding> findings,
  CodeAuditProjectReport? projectReport,
  Iterable<CodeAuditRule> enabledRules = const [],
}) {
  final enabledRuleList = enabledRules.toList(growable: false);
  final contextSummary = _buildContextSummary(
    findings: findings,
    projectReport: projectReport,
    enabledRules: enabledRuleList,
  );
  final riskDigest = _buildRiskDigest(findings);
  final locationDigest = _buildLocationDigest(findings);
  final ruleDigest = _buildRuleDigest(findings);

  return CodeAuditAiRequestDraft(
    title: 'AI 审计请求草稿',
    contextSummary: contextSummary,
    riskDigest: riskDigest,
    locationDigest: locationDigest,
    ruleDigest: ruleDigest,
    prompt: _buildPrompt(
      findings: findings,
      projectReport: projectReport,
      enabledRules: enabledRuleList,
      contextSummary: contextSummary,
      riskDigest: riskDigest,
      locationDigest: locationDigest,
      ruleDigest: ruleDigest,
    ),
  );
}

String _buildContextSummary({
  required List<CodeAuditFinding> findings,
  required CodeAuditProjectReport? projectReport,
  required List<CodeAuditRule> enabledRules,
}) {
  final buffer = StringBuffer()..write('本地规则命中 ${findings.length} 个风险');

  if (projectReport != null) {
    buffer.write(
      '，项目扫描 ${projectReport.scannedFileCount} 个文件，'
      '跳过 ${projectReport.skippedFileCount} 个文件',
    );
  }

  if (enabledRules.isNotEmpty) {
    buffer.write('，启用 ${enabledRules.length} 条规则');
  }

  buffer.write('。');
  return buffer.toString();
}

String _buildRiskDigest(List<CodeAuditFinding> findings) {
  final counts = {
    for (final severity in CodeAuditSeverity.values) severity: 0,
  };
  for (final finding in findings) {
    counts.update(finding.rule.severity, (count) => count + 1);
  }

  return '风险分布：高危 ${counts[CodeAuditSeverity.high]} / '
      '中危 ${counts[CodeAuditSeverity.medium]} / '
      '低危 ${counts[CodeAuditSeverity.low]}。';
}

String _buildLocationDigest(List<CodeAuditFinding> findings) {
  if (findings.isEmpty) {
    return '\u547d\u4e2d\u6587\u4ef6\uff1a0 \u4e2a\uff0c'
        '\u884c\u53f7\u8303\u56f4\uff1a\u65e0\u3002';
  }

  final fileCounts = <String, int>{};
  var minLine = findings.first.lineNumber;
  var maxLine = findings.first.lineNumber;

  for (final finding in findings) {
    fileCounts.update(
      finding.filePath,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    if (finding.lineNumber < minLine) minLine = finding.lineNumber;
    if (finding.lineNumber > maxLine) maxLine = finding.lineNumber;
  }

  final hottestFile = fileCounts.entries.reduce((a, b) {
    final countCompare = b.value.compareTo(a.value);
    if (countCompare != 0) return countCompare > 0 ? b : a;
    return a.key.compareTo(b.key) <= 0 ? a : b;
  });

  return '\u547d\u4e2d\u6587\u4ef6\uff1a${fileCounts.length} \u4e2a\uff0c'
      '\u6700\u9ad8\u96c6\u4e2d\uff1a${hottestFile.key} ${hottestFile.value} \u4e2a\uff0c'
      '\u884c\u53f7\u8303\u56f4\uff1a$minLine-$maxLine\u3002';
}

String _buildRuleDigest(List<CodeAuditFinding> findings) {
  if (findings.isEmpty) {
    return '规则覆盖：命中 0 条规则，最高频：无。';
  }

  final ruleCounts = <String, int>{};
  for (final finding in findings) {
    ruleCounts.update(
      finding.rule.title,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  final topRule = ruleCounts.entries.reduce((a, b) {
    final countCompare = b.value.compareTo(a.value);
    if (countCompare != 0) return countCompare > 0 ? b : a;
    return a.key.compareTo(b.key) <= 0 ? a : b;
  });

  return '规则覆盖：命中 ${ruleCounts.length} 条规则，'
      '最高频：${topRule.key} ${topRule.value} 个。';
}

String _buildPrompt({
  required List<CodeAuditFinding> findings,
  required CodeAuditProjectReport? projectReport,
  required List<CodeAuditRule> enabledRules,
  required String contextSummary,
  required String riskDigest,
  required String locationDigest,
  required String ruleDigest,
}) {
  final buffer = StringBuffer()
    ..writeln('# AI 代码审计请求')
    ..writeln()
    ..writeln('## 审计目标')
    ..writeln()
    ..writeln('请基于本地确定性规则扫描结果进行二次代码审计。重点判断真实风险、影响范围、误报可能性、最小修复方案和需要补充的测试。')
    ..writeln()
    ..writeln('## 本地扫描上下文')
    ..writeln()
    ..writeln(contextSummary)
    ..writeln(riskDigest)
    ..writeln(locationDigest)
    ..writeln(ruleDigest)
    ..writeln();

  if (projectReport != null) {
    buffer
      ..writeln('- 项目路径：`${projectReport.rootPath}`')
      ..writeln('- 已扫描文件：${projectReport.scannedFileCount}')
      ..writeln('- 已跳过文件：${projectReport.skippedFileCount}')
      ..writeln();
  }

  if (enabledRules.isNotEmpty) {
    buffer
      ..writeln('## 本次启用规则')
      ..writeln();
    for (final rule in enabledRules) {
      buffer.writeln(
          '- ${rule.title}（${rule.severity.label}）：${rule.suggestion}');
    }
    buffer.writeln();
  }

  buffer
    ..writeln('## 复核优先级')
    ..writeln();

  if (findings.isEmpty) {
    buffer
      ..writeln('- 当前没有本地规则命中，请优先做架构、鉴权、数据流和异常路径审计。')
      ..writeln();
  } else {
    final prioritizedFindings = [...findings]..sort(_compareFindingPriority);
    for (final finding in prioritizedFindings.take(5)) {
      buffer.writeln(
        '- ${finding.rule.severity.label} · ${finding.rule.title} · '
        '`${finding.filePath}:${finding.lineNumber}`',
      );
    }
    buffer.writeln();
  }

  buffer
    ..writeln('## 本地规则命中')
    ..writeln();

  if (findings.isEmpty) {
    buffer
      ..writeln('当前未命中本地规则。请重点检查本地规则未覆盖的认证、权限、输入校验、错误处理、并发和数据持久化风险。')
      ..writeln();
  } else {
    for (var i = 0; i < findings.length; i++) {
      final finding = findings[i];
      buffer
        ..writeln('### ${i + 1}. ${finding.rule.title}')
        ..writeln()
        ..writeln('- 严重级别：${finding.rule.severity.label}')
        ..writeln('- 位置：`${finding.filePath}:${finding.lineNumber}`')
        ..writeln('- 说明：${finding.rule.description}')
        ..writeln('- 本地建议：${finding.rule.suggestion}')
        ..writeln()
        ..writeln('```text')
        ..writeln(finding.lineText)
        ..writeln('```')
        ..writeln();
    }
  }

  buffer
    ..writeln('## 请输出')
    ..writeln()
    ..writeln('1. 风险是否成立及原因')
    ..writeln('2. 影响范围和触发条件')
    ..writeln('3. 最小修复步骤')
    ..writeln('4. 需要补充的测试')
    ..writeln('5. 可以沉淀到本地 RAG 的知识片段');

  return buffer.toString();
}

int _compareFindingPriority(CodeAuditFinding a, CodeAuditFinding b) {
  final severityCompare = _severityRank(a.rule.severity).compareTo(
    _severityRank(b.rule.severity),
  );
  if (severityCompare != 0) return severityCompare;
  final fileCompare = a.filePath.compareTo(b.filePath);
  if (fileCompare != 0) return fileCompare;
  return a.lineNumber.compareTo(b.lineNumber);
}

int _severityRank(CodeAuditSeverity severity) {
  return switch (severity) {
    CodeAuditSeverity.high => 0,
    CodeAuditSeverity.medium => 1,
    CodeAuditSeverity.low => 2,
  };
}
