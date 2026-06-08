import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';
import 'package:kazumi/pages/platform/platform_fix_suggestion_template.dart';

void main() {
  test('fix suggestion templates are generated from audit findings', () {
    final findings = scanCodeSnippet(
      'const token = "abcdef123456";',
      filePath: 'lib/config.dart',
    );

    final templates = buildCodeAuditFixSuggestionTemplates(
      findings: findings,
    );
    final markdown = formatFixSuggestionTemplates(templates);

    expect(templates, hasLength(1));
    expect(templates.single.title, contains('修复'));
    expect(templates.single.location, 'lib/config.dart:1');
    expect(markdown, contains('# 疑似硬编码密钥 修复建议模板'));
    expect(markdown, contains('`lib/config.dart:1`'));
    expect(markdown, contains('本地规则扫描不再命中该位置'));
  });

  test('fix suggestion templates include a fallback review template', () {
    final templates = buildCodeAuditFixSuggestionTemplates(
      findings: const [],
    );

    expect(templates, hasLength(1));
    expect(templates.single.title, '通用复核修复模板');
    expect(templates.single.markdown, contains('本地规则暂未命中明确风险'));
    expect(templates.single.markdown, contains('将未覆盖的风险沉淀为新的本地审计规则'));
  });
}
