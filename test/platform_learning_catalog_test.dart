import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';

void main() {
  test('learning catalog exposes the five core resource groups', () {
    expect(platformLearningSections.length, 5);
    expect(platformLearningSections.map((e) => e.title).toList(), [
      '视频资源',
      '常用 Skill',
      'MCP 工具',
      '本地 RAG 资料',
      '算法与模型',
    ]);

    expect(
      platformLearningSections
          .every((section) => section.resources.length >= 2),
      isTrue,
    );
    expect(
      platformLearningSections.first.resources.map((e) => e.title),
      containsAll([
        'CS50',
        'MIT 6.006',
        'FreeCodeCamp',
        'The Missing Semester',
      ]),
    );
    expect(
      platformLearningSections[2].resources.map((e) => e.title),
      containsAll([
        'Context7',
        'Filesystem MCP',
        'GitHub MCP',
        'Playwright MCP',
      ]),
    );
  });

  test('learning resources expose metadata for platform workflows', () {
    final resources = allPlatformLearningResources;

    expect(resources.length, greaterThanOrEqualTo(25));
    expect(resources.every((resource) => resource.url.isNotEmpty), isTrue);
    expect(resources.every((resource) => resource.tags.isNotEmpty), isTrue);
    final resourceTypes = resources.map((resource) => resource.type).toSet();
    expect(resourceTypes.length, PlatformResourceType.values.length);
    expect(resourceTypes.containsAll(PlatformResourceType.values), isTrue);

    final recommendationModel = resources.singleWhere(
      (resource) => resource.title == '推荐排序模型',
    );
    expect(recommendationModel.type, PlatformResourceType.model);
    expect(recommendationModel.matches('推荐算法', null), isTrue);
    expect(
      recommendationModel.matches('', PlatformResourceType.video),
      isFalse,
    );
  });

  test('learning resources distinguish external links from local entries', () {
    final resources = allPlatformLearningResources;
    final cs50 = resources.singleWhere((resource) => resource.title == 'CS50');
    final markdown = resources.singleWhere(
      (resource) => resource.title == 'Markdown 笔记',
    );

    expect(cs50.isExternalUrl, isTrue);
    expect(markdown.isExternalUrl, isFalse);
  });

  test('local learning resources include actionable built-in guides', () {
    final localResources = allPlatformLearningResources.where(
      (resource) => !resource.isExternalUrl,
    );

    expect(localResources.length, greaterThanOrEqualTo(20));
    expect(localResources.every((resource) => resource.guide != null), isTrue);

    final context7 = localResources.singleWhere(
      (resource) => resource.title == 'Context7',
    );
    final guideText = context7.guide!.toClipboardText(context7);

    expect(guideText, contains('# Context7'));
    expect(guideText, contains('## 步骤'));
    expect(guideText, contains('## 产出'));
    expect(context7.guide!.steps.length, greaterThanOrEqualTo(3));
    expect(context7.guide!.outputs, isNotEmpty);
  });

  test('learning resource catalog markdown summarizes filtered resources', () {
    final resources = allPlatformLearningResources
        .where((resource) => resource.title == 'Context7')
        .toList(growable: false);

    final markdown = buildLearningResourceCatalogMarkdown(
      resources: resources,
      completedResourceIds: {resources.single.id},
      keyword: ' rag ',
      selectedType: PlatformResourceType.mcp,
      completionFilterLabel: '已完成',
      generatedAt: DateTime(2026, 1, 3, 9, 30),
    );

    expect(markdown, startsWith('# 学习资源清单'));
    expect(markdown, contains('- 生成时间：2026-01-03 09:30'));
    expect(markdown, contains('- 筛选关键词：rag'));
    expect(markdown, contains('- 资源类型：MCP'));
    expect(markdown, contains('- 完成状态：已完成'));
    expect(markdown, contains('- 匹配资源：1'));
    expect(markdown, contains('- 已完成：1'));
    expect(markdown, contains('- 难度分布：常用 1'));
    expect(markdown, contains('## 资源列表'));
    expect(markdown, contains('- \u672a\u5b8c\u6210\uff1a0'));
    expect(markdown, contains('- \u5b8c\u6210\u7387\uff1a100%'));
    expect(markdown, contains('1. Context7'));
    expect(markdown, contains('- 状态：已完成'));
    expect(markdown, contains('- 入口：local://mcp/context7'));
  });

  test('learning resource catalog markdown summarizes empty level counts', () {
    final markdown = buildLearningResourceCatalogMarkdown(
      resources: const [],
      completedResourceIds: const {},
      completionFilterLabel: '未完成',
      generatedAt: DateTime(2026, 1, 3, 9, 30),
    );

    expect(markdown, contains('- 匹配资源：0'));
    expect(markdown, contains('- 类型分布：无'));
    expect(markdown, contains('- 难度分布：无'));
    expect(markdown, contains('暂无匹配的学习资源。'));
  });

  test('learning catalog includes expanded platform resource coverage', () {
    final titles = allPlatformLearningResources.map((e) => e.title).toSet();

    expect(titles, contains('The Missing Semester'));
    expect(titles, contains('需求拆解'));
    expect(titles, contains('Playwright MCP'));
    expect(titles, contains('课程字幕与摘录'));
    expect(titles, contains('Learning to Rank'));
    expect(titles, contains('Bandit 与 A/B 实验'));
  });
}
