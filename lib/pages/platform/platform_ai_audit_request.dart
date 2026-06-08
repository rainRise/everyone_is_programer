import 'platform_code_audit_rules.dart';

class CodeAuditAiRequestDraft {
  const CodeAuditAiRequestDraft({
    required this.title,
    required this.contextSummary,
    required this.prompt,
  });

  final String title;
  final String contextSummary;
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

  return CodeAuditAiRequestDraft(
    title: 'AI 审计请求草稿',
    contextSummary: contextSummary,
    prompt: _buildPrompt(
      findings: findings,
      projectReport: projectReport,
      enabledRules: enabledRuleList,
      contextSummary: contextSummary,
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

String _buildPrompt({
  required List<CodeAuditFinding> findings,
  required CodeAuditProjectReport? projectReport,
  required List<CodeAuditRule> enabledRules,
  required String contextSummary,
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
