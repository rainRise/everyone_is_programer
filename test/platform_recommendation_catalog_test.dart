import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';
import 'package:kazumi/pages/platform/platform_recommendation_catalog.dart';

void main() {
  test('recommendation goal ranks model resources for recommendation learning',
      () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
    );

    expect(recommendations, isNotEmpty);
    expect(recommendations.first.resource.type, PlatformResourceType.model);
    expect(
      recommendations.map((item) => item.resource.title),
      contains('推荐排序模型'),
    );
    expect(recommendations.first.reason, contains('排序分'));
    expect(recommendations.first.reason, contains('类型'));
  });

  test('RAG learning goal includes local RAG and embedding resources', () {
    final recommendations =
        recommendPlatformResources(PlatformLearningGoal.rag);
    final titles = recommendations.map((item) => item.resource.title).toList();

    expect(titles, contains('Markdown 笔记'));
    expect(titles, contains('Embedding 模型'));
  });

  test('recommendations skip completed learning resources', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
    );
    final completedTopResource = recommendations.first.resource;

    final nextRecommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      completedResourceIds: {completedTopResource.id},
    );

    expect(nextRecommendations, isNotEmpty);
    expect(
      nextRecommendations.map((item) => item.resource.id),
      isNot(contains(completedTopResource.id)),
    );
    expect(
      nextRecommendations.first.resource.id,
      isNot(completedTopResource.id),
    );
  });

  test('recommendations return empty when all matching resources are completed',
      () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: allPlatformLearningResources.length,
    );

    final nextRecommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      completedResourceIds: recommendations
          .map((recommendation) => recommendation.resource.id)
          .toSet(),
      limit: allPlatformLearningResources.length,
    );

    expect(recommendations, isNotEmpty);
    expect(nextRecommendations, isEmpty);
  });

  test('recommendation markdown summarizes next-step resources', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );

    final markdown = buildLearningRecommendationMarkdown(
      goal: PlatformLearningGoal.recommendation,
      recommendations: recommendations,
      completedResourceIds: {'done-a', 'done-b'},
      generatedAt: DateTime(2026, 6, 8, 10, 15),
    );

    expect(markdown, startsWith('# 学习推荐清单'));
    expect(markdown, contains('- 生成时间：2026-06-08 10:15'));
    expect(markdown, contains('- 学习目标：'));
    expect(markdown, contains('- 已完成资源：2'));
    expect(markdown, contains('- 推荐数量：2'));
    expect(
      markdown,
      contains(
        '- \u6e05\u5355\u72b6\u6001\uff1a'
        '\u5df2\u5b8c\u6210\u8d44\u6e90\uff1a2 / '
        '\u5f53\u524d\u63a8\u8350\uff1a2',
      ),
    );
    expect(
      markdown,
      contains(
        '- \u9996\u63a8\u8d44\u6e90\uff1a'
        '${recommendations.first.resource.title} / '
        '\u6392\u5e8f\u5206\uff1a${recommendations.first.score}',
      ),
    );
    expect(markdown, contains('## 下一步推荐'));
    expect(
        markdown,
        contains(
            '- \u6700\u9ad8\u6392\u5e8f\u5206\uff1a${recommendations.first.score}'));
    expect(
      markdown,
      contains(
          '- \u6700\u4f4e\u6392\u5e8f\u5206\uff1a${recommendations.last.score}'),
    );
    expect(
      markdown,
      contains(
        '- \u5e73\u5747\u6392\u5e8f\u5206\uff1a'
        '${((recommendations[0].score + recommendations[1].score) / 2).toStringAsFixed(1)}',
      ),
    );
    expect(markdown, contains('- \u7c7b\u578b\u5206\u5e03\uff1a'));
    expect(markdown, contains('- \u96be\u5ea6\u5206\u5e03\uff1a'));
    expect(markdown, contains('- \u4e3b\u9898\u5206\u5e03\uff1a'));
    expect(markdown, contains('- \u63a8\u8350\u6d41\u7a0b\uff1a'));
    expect(markdown, contains('\u9636\u6bb5\u6570\uff1a4'));
    expect(markdown, contains('1. ${recommendations.first.resource.title}'));
    expect(markdown, contains('   - 排序分：${recommendations.first.score}'));
    expect(markdown, contains('   - 推荐理由：'));
    expect(markdown, contains('   - 入口：${recommendations.first.resource.url}'));
  });

  test('recommendation markdown handles empty recommendations', () {
    final markdown = buildLearningRecommendationMarkdown(
      goal: PlatformLearningGoal.foundation,
      recommendations: const [],
      generatedAt: DateTime(2026, 6, 8, 10, 15),
    );

    expect(markdown, contains('- 推荐数量：0'));
    expect(
      markdown,
      contains(
        '- \u6e05\u5355\u72b6\u6001\uff1a'
        '\u5df2\u5b8c\u6210\u8d44\u6e90\uff1a0 / '
        '\u5f53\u524d\u63a8\u8350\uff1a0',
      ),
    );
    expect(markdown, contains('- \u9996\u63a8\u8d44\u6e90\uff1a\u65e0'));
    expect(markdown, contains('暂无可推荐的下一步资源。'));
    expect(markdown, contains('- \u6700\u9ad8\u6392\u5e8f\u5206\uff1a0'));
    expect(markdown, contains('- \u6700\u4f4e\u6392\u5e8f\u5206\uff1a0'));
    expect(markdown, contains('- \u5e73\u5747\u6392\u5e8f\u5206\uff1a0.0'));
    expect(markdown, contains('- \u7c7b\u578b\u5206\u5e03\uff1a\u65e0'));
    expect(markdown, contains('- \u96be\u5ea6\u5206\u5e03\uff1a\u65e0'));
    expect(markdown, contains('- \u4e3b\u9898\u5206\u5e03\uff1a\u65e0'));
  });

  test('recommendation topic distribution summarizes resource tags', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );
    final firstTag = recommendations.first.resource.tags.first;

    expect(
      formatLearningRecommendationTopicDistribution(recommendations),
      contains(firstTag),
    );
    expect(
      formatLearningRecommendationTopicDistribution(const []),
      '\u65e0',
    );
  });

  test('recommendation resource structure summarizes type and difficulty', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );
    final firstType = recommendations.first.resource.type.label;
    final firstLevel = recommendations.first.resource.level;

    expect(
      formatLearningRecommendationTypeDistribution(recommendations),
      contains(firstType),
    );
    expect(
      formatLearningRecommendationDifficultyDistribution(recommendations),
      contains(firstLevel),
    );
    expect(
      formatLearningRecommendationResourceStructure(recommendations),
      contains('\u7c7b\u578b\u5206\u5e03\uff1a'),
    );
    expect(
      formatLearningRecommendationResourceStructure(recommendations),
      contains('\u96be\u5ea6\u5206\u5e03\uff1a'),
    );
    expect(
      formatLearningRecommendationResourceStructure(const []),
      '\u7c7b\u578b\u5206\u5e03\uff1a\u65e0 / '
      '\u96be\u5ea6\u5206\u5e03\uff1a\u65e0',
    );
  });

  test('recommendation list status formats progress and list size', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );

    expect(
      formatLearningRecommendationListStatus(
        recommendations: recommendations,
        completedResourceIds: {'video-foundation', 'rag-local'},
      ),
      '\u5df2\u5b8c\u6210\u8d44\u6e90\uff1a2 / '
      '\u5f53\u524d\u63a8\u8350\uff1a2',
    );
    expect(
      formatLearningRecommendationListStatus(recommendations: const []),
      '\u5df2\u5b8c\u6210\u8d44\u6e90\uff1a0 / '
      '\u5f53\u524d\u63a8\u8350\uff1a0',
    );
  });

  test('recommendation top resource formats first ranked item', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );

    expect(
      formatLearningRecommendationTopResource(recommendations),
      '${recommendations.first.resource.title} / '
      '\u6392\u5e8f\u5206\uff1a${recommendations.first.score}',
    );
    expect(
      formatLearningRecommendationTopResource(const []),
      '\u65e0',
    );
  });

  test('recommendation score summary formats score range and average', () {
    final recommendations = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: 2,
    );
    final summary = summarizeLearningRecommendationScores(recommendations);

    expect(summary.topScore, recommendations.first.score);
    expect(summary.lowestScore, recommendations.last.score);
    expect(
      summary.averageScore,
      ((recommendations[0].score + recommendations[1].score) / 2)
          .toStringAsFixed(1),
    );
    expect(
      formatLearningRecommendationScoreSummary(recommendations),
      contains('\u5e73\u5747\u6392\u5e8f\u5206\uff1a${summary.averageScore}'),
    );
    expect(
      formatLearningRecommendationScoreSummary(const []),
      '\u6700\u9ad8\u6392\u5e8f\u5206\uff1a0 / '
      '\u6700\u4f4e\u6392\u5e8f\u5206\uff1a0 / '
      '\u5e73\u5747\u6392\u5e8f\u5206\uff1a0.0',
    );
  });

  test('recommendation pipeline explains model stages', () {
    expect(recommendationPipelineStages, [
      '候选召回',
      '粗排过滤',
      '精排打分',
      '重排解释',
    ]);
    expect(
      recommendationPipelineDescriptions['候选召回'],
      contains('候选资源'),
    );
    expect(
      PlatformLearningGoal.recommendation.preferredTypes,
      contains(PlatformResourceType.model),
    );
  });

  test('recommendation pipeline summary formats stages and count', () {
    expect(
      formatLearningRecommendationPipelineSummary(),
      '\u63a8\u8350\u6d41\u7a0b\uff1a'
      '${recommendationPipelineStages.join(' -> ')} / '
      '\u9636\u6bb5\u6570\uff1a${recommendationPipelineStages.length}',
    );
  });
}
