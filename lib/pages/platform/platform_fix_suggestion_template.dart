import 'platform_code_audit_rules.dart';

class CodeAuditFixSuggestionTemplate {
  const CodeAuditFixSuggestionTemplate({
    required this.title,
    required this.location,
    required this.markdown,
  });

  final String title;
  final String location;
  final String markdown;
}

List<CodeAuditFixSuggestionTemplate> buildCodeAuditFixSuggestionTemplates({
  required List<CodeAuditFinding> findings,
  CodeAuditProjectReport? projectReport,
}) {
  if (findings.isEmpty) {
    return [
      CodeAuditFixSuggestionTemplate(
        title: '通用复核修复模板',
        location: projectReport?.rootPath ?? 'local_snippet.dart',
        markdown: _buildEmptyFindingTemplate(projectReport),
      ),
    ];
  }

  return findings
      .map(
        (finding) => CodeAuditFixSuggestionTemplate(
          title: '修复：${finding.rule.title}',
          location: '${finding.filePath}:${finding.lineNumber}',
          markdown: _buildFindingTemplate(finding, projectReport),
        ),
      )
      .toList(growable: false);
}

String formatFixSuggestionTemplates(
  List<CodeAuditFixSuggestionTemplate> templates,
) {
  return templates.map((template) => template.markdown).join('\n---\n\n');
}

String _buildFindingTemplate(
  CodeAuditFinding finding,
  CodeAuditProjectReport? projectReport,
) {
  final buffer = StringBuffer()
    ..writeln('# ${finding.rule.title} 修复建议模板')
    ..writeln()
    ..writeln('## 风险定位')
    ..writeln()
    ..writeln('- 严重级别：${finding.rule.severity.label}')
    ..writeln('- 位置：`${finding.filePath}:${finding.lineNumber}`');

  if (projectReport != null) {
    buffer.writeln('- 项目根路径：`${projectReport.rootPath}`');
  }

  buffer
    ..writeln()
    ..writeln('## 触发证据')
    ..writeln()
    ..writeln('```text')
    ..writeln(finding.lineText)
    ..writeln('```')
    ..writeln()
    ..writeln('## 修复步骤')
    ..writeln()
    ..writeln('1. 确认这条命中是否属于真实业务路径，排除测试样例或已脱敏数据。')
    ..writeln('2. 按本地规则建议执行最小修复：${finding.rule.suggestion}')
    ..writeln('3. 检查同类代码路径，避免只修当前行而遗漏重复风险。')
    ..writeln('4. 将修复原因、影响范围和验证方式写入提交说明或审计报告。')
    ..writeln()
    ..writeln('## 验证清单')
    ..writeln()
    ..writeln('- [ ] 本地规则扫描不再命中该位置')
    ..writeln('- [ ] 相关单元测试或回归用例已补充')
    ..writeln('- [ ] 配置、凭据或外部依赖的变更已记录')
    ..writeln('- [ ] 需要人工复核的残余风险已写入后续任务');

  return buffer.toString();
}

String _buildEmptyFindingTemplate(CodeAuditProjectReport? projectReport) {
  final buffer = StringBuffer()
    ..writeln('# 通用复核修复模板')
    ..writeln()
    ..writeln('## 风险定位')
    ..writeln()
    ..writeln('- 本地规则暂未命中明确风险');

  if (projectReport != null) {
    buffer
      ..writeln('- 项目根路径：`${projectReport.rootPath}`')
      ..writeln('- 已扫描文件：${projectReport.scannedFileCount}')
      ..writeln('- 已跳过文件：${projectReport.skippedFileCount}');
  }

  buffer
    ..writeln()
    ..writeln('## 复核方向')
    ..writeln()
    ..writeln('1. 检查认证、权限、输入校验、错误处理和数据持久化路径。')
    ..writeln('2. 对关键流程补充最小复现和回归测试。')
    ..writeln('3. 将未覆盖的风险沉淀为新的本地审计规则。')
    ..writeln()
    ..writeln('## 验证清单')
    ..writeln()
    ..writeln('- [ ] 已确认本地规则覆盖范围')
    ..writeln('- [ ] 已补充人工复核结论')
    ..writeln('- [ ] 已记录需要新增的规则或测试');

  return buffer.toString();
}
