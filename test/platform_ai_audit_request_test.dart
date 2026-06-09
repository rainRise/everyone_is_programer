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
    expect(draft.riskDigest, '风险分布：高危 1 / 中危 1 / 低危 0。');
    expect(draft.ruleDigest, contains('规则覆盖：命中 2 条规则，最高频：'));
    expect(draft.prompt, contains('# AI 代码审计请求'));
    expect(draft.prompt, contains(draft.ruleDigest));
    expect(draft.prompt, contains('## 复核优先级'));
    expect(draft.prompt, contains('`lib/main.dart:1`'));
    expect(draft.prompt, contains('风险是否成立及原因'));
    expect(draft.prompt, contains('可以沉淀到本地 RAG 的知识片段'));
    expect(
      draft.prompt.indexOf('高危 · 疑似硬编码密钥'),
      lessThan(draft.prompt.indexOf('中危 · 明文 HTTP 地址')),
    );
  });

  test('AI audit request draft handles empty findings with manual review task',
      () {
    final draft = buildCodeAuditAiRequestDraft(
      findings: const [],
      enabledRules: localCodeAuditRules.take(1),
    );

    expect(draft.contextSummary, contains('本地规则命中 0 个风险'));
    expect(draft.riskDigest, '风险分布：高危 0 / 中危 0 / 低危 0。');
    expect(draft.ruleDigest, '规则覆盖：命中 0 条规则，最高频：无。');
    expect(draft.prompt, contains(draft.ruleDigest));
    expect(draft.prompt, contains('请优先做架构、鉴权、数据流和异常路径审计'));
  });
  test('AI audit request draft summarizes finding locations', () {
    final findings = scanCodeSnippet(
      '''
const token = "abcdef123456";
final endpoint = "http://example.com";
''',
      filePath: 'lib/main.dart',
    );

    final draft = buildCodeAuditAiRequestDraft(findings: findings);

    expect(
      draft.locationDigest,
      '\u547d\u4e2d\u6587\u4ef6\uff1a1 \u4e2a\uff0c'
      '\u6700\u9ad8\u96c6\u4e2d\uff1alib/main.dart 2 \u4e2a\uff0c'
      '\u884c\u53f7\u8303\u56f4\uff1a1-2\u3002',
    );
    expect(draft.prompt, contains(draft.locationDigest));
  });

  test('AI audit request draft summarizes empty finding locations', () {
    final draft = buildCodeAuditAiRequestDraft(findings: const []);

    expect(
      draft.locationDigest,
      '\u547d\u4e2d\u6587\u4ef6\uff1a0 \u4e2a\uff0c'
      '\u884c\u53f7\u8303\u56f4\uff1a\u65e0\u3002',
    );
    expect(draft.prompt, contains(draft.locationDigest));
  });
}
