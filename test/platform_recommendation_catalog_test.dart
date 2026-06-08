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
    expect(markdown, contains('## 下一步推荐'));
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
    expect(markdown, contains('暂无可推荐的下一步资源。'));
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
}
