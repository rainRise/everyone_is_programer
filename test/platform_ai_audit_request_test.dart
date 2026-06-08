import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_ai_audit_request.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';

void main() {
  test('AI audit request draft includes findings and review tasks', () {
    final findings = scanCodeSnippet(
      '''
const token = "abcdef123456";
final endpoint = "http://example.com";
''',
      filePath: 'lib/main.dart',
    );

    final draft = buildCodeAuditAiRequestDraft(
      findings: findings,
      enabledRules: localCodeAuditRules.take(2),
    );

    expect(draft.title, 'AI 审计请求草稿');
    expect(draft.contextSummary, contains('本地规则命中 2 个风险'));
    expect(draft.prompt, contains('# AI 代码审计请求'));
    expect(draft.prompt, contains('`lib/main.dart:1`'));
    expect(draft.prompt, contains('风险是否成立及原因'));
    expect(draft.prompt, contains('可以沉淀到本地 RAG 的知识片段'));
  });
}
