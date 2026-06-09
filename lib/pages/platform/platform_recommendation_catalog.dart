import 'package:flutter/material.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';

enum PlatformLearningGoal {
  foundation,
  rag,
  codeAudit,
  recommendation,
}

extension PlatformLearningGoalLabel on PlatformLearningGoal {
  String get label {
    return switch (this) {
      PlatformLearningGoal.foundation => '编程基础',
      PlatformLearningGoal.rag => '本地 RAG',
      PlatformLearningGoal.codeAudit => '代码审计',
      PlatformLearningGoal.recommendation => '推荐算法',
    };
  }

  IconData get icon {
    return switch (this) {
      PlatformLearningGoal.foundation => Icons.school_outlined,
      PlatformLearningGoal.rag => Icons.travel_explore_outlined,
      PlatformLearningGoal.codeAudit => Icons.security_outlined,
      PlatformLearningGoal.recommendation => Icons.recommend_outlined,
    };
  }

  List<String> get keywords {
    return switch (this) {
      PlatformLearningGoal.foundation => ['基础', '计算机科学', '前端', '后端', '项目实战'],
      PlatformLearningGoal.rag => ['RAG', '向量', '语义', '知识库', '文档', 'Embedding'],
      PlatformLearningGoal.codeAudit => ['审计', '安全', '漏洞', '测试', '质量'],
      PlatformLearningGoal.recommendation => [
          '推荐算法',
          '排序',
          '搜索',
          '召回',
          'BM25',
          '重排',
        ],
    };
  }

  Set<PlatformResourceType> get preferredTypes {
    return switch (this) {
      PlatformLearningGoal.foundation => {
          PlatformResourceType.video,
          PlatformResourceType.skill,
        },
      PlatformLearningGoal.rag => {
          PlatformResourceType.rag,
          PlatformResourceType.model,
          PlatformResourceType.mcp,
        },
      PlatformLearningGoal.codeAudit => {
          PlatformResourceType.skill,
          PlatformResourceType.rag,
          PlatformResourceType.mcp,
        },
      PlatformLearningGoal.recommendation => {
          PlatformResourceType.model,
          PlatformResourceType.rag,
        },
    };
  }
}

class RecommendedLearningResource {
  const RecommendedLearningResource({
    required this.resource,
    required this.score,
    required this.reason,
  });

  final PlatformLearningResource resource;
  final int score;
  final String reason;
}

class LearningRecommendationScoreSummary {
  const LearningRecommendationScoreSummary({
    required this.topScore,
    required this.lowestScore,
    required this.averageScore,
  });

  final int topScore;
  final int lowestScore;
  final String averageScore;
}

const recommendationPipelineStages = [
  '候选召回',
  '粗排过滤',
  '精排打分',
  '重排解释',
];

const recommendationPipelineDescriptions = {
  '候选召回': '用目标关键词、资源类型和标签从目录中找出候选资源。',
  '粗排过滤': '优先保留目标相关、难度合适且可行动的资料。',
  '精排打分': '按标题、标签、描述、资源类型和学习阶段加权打分。',
  '重排解释': '输出匹配原因，避免只给黑盒推荐结果。',
};

List<RecommendedLearningResource> recommendPlatformResources(
  PlatformLearningGoal goal, {
  int limit = 4,
  Set<String> completedResourceIds = const {},
}) {
  final recommendations = <RecommendedLearningResource>[];

  for (final resource in allPlatformLearningResources) {
    if (completedResourceIds.contains(resource.id)) continue;
    final score = _scoreResourceForGoal(resource, goal);
    if (score == 0) continue;
    recommendations.add(
      RecommendedLearningResource(
        resource: resource,
        score: score,
        reason: _buildReason(resource, goal, score),
      ),
    );
  }

  recommendations.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    return a.resource.title.compareTo(b.resource.title);
  });

  return recommendations.take(limit).toList();
}

String buildLearningRecommendationMarkdown({
  required PlatformLearningGoal goal,
  required Iterable<RecommendedLearningResource> recommendations,
  Set<String> completedResourceIds = const {},
  DateTime? generatedAt,
}) {
  final recommendationList = recommendations.toList(growable: false);
  final generatedTime = generatedAt ?? DateTime.now();
  final scoreSummary =
      summarizeLearningRecommendationScores(recommendationList);

  final buffer = StringBuffer()
    ..writeln('# 学习推荐清单')
    ..writeln()
    ..writeln('- 生成时间：${_formatRecommendationTimestamp(generatedTime)}')
    ..writeln('- 学习目标：${goal.label}')
    ..writeln('- 已完成资源：${completedResourceIds.length}')
    ..writeln('- 推荐数量：${recommendationList.length}')
    ..writeln(
        '- \u6e05\u5355\u72b6\u6001\uff1a${formatLearningRecommendationListStatus(
      recommendations: recommendationList,
      completedResourceIds: completedResourceIds,
    )}')
    ..writeln(
        '- \u9996\u63a8\u8d44\u6e90\uff1a${formatLearningRecommendationTopResource(recommendationList)}');

  buffer
    ..writeln('- \u6700\u9ad8\u6392\u5e8f\u5206\uff1a${scoreSummary.topScore}')
    ..writeln(
        '- \u6700\u4f4e\u6392\u5e8f\u5206\uff1a${scoreSummary.lowestScore}')
    ..writeln(
        '- \u5e73\u5747\u6392\u5e8f\u5206\uff1a${scoreSummary.averageScore}')
    ..writeln(
        '- \u7c7b\u578b\u5206\u5e03\uff1a${formatLearningRecommendationTypeDistribution(recommendationList)}')
    ..writeln(
        '- \u96be\u5ea6\u5206\u5e03\uff1a${formatLearningRecommendationDifficultyDistribution(recommendationList)}')
    ..writeln(
        '- \u4e3b\u9898\u5206\u5e03\uff1a${formatLearningRecommendationTopicDistribution(recommendationList)}')
    ..writeln('- ${formatLearningRecommendationPipelineSummary()}');

  if (recommendationList.isEmpty) {
    buffer
      ..writeln()
      ..writeln('暂无可推荐的下一步资源。');
    return buffer.toString().trimRight();
  }

  buffer
    ..writeln()
    ..writeln('## 下一步推荐');

  for (var index = 0; index < recommendationList.length; index++) {
    final recommendation = recommendationList[index];
    final resource = recommendation.resource;
    buffer
      ..writeln()
      ..writeln('${index + 1}. ${resource.title}')
      ..writeln('   - 类型：${resource.type.label}')
      ..writeln('   - 难度：${resource.level}')
      ..writeln('   - 排序分：${recommendation.score}')
      ..writeln('   - 推荐理由：${recommendation.reason}')
      ..writeln('   - 标签：${resource.tags.join('、')}')
      ..writeln('   - 入口：${resource.url}');
  }

  return buffer.toString().trimRight();
}

LearningRecommendationScoreSummary summarizeLearningRecommendationScores(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final recommendationList = recommendations.toList(growable: false);
  var totalScore = 0;
  var topScore = 0;
  int? lowestScore;

  for (final recommendation in recommendationList) {
    final score = recommendation.score;
    totalScore += score;
    if (score > topScore) topScore = score;
    if (lowestScore == null || score < lowestScore) lowestScore = score;
  }

  return LearningRecommendationScoreSummary(
    topScore: topScore,
    lowestScore: lowestScore ?? 0,
    averageScore: recommendationList.isEmpty
        ? '0.0'
        : (totalScore / recommendationList.length).toStringAsFixed(1),
  );
}

String formatLearningRecommendationScoreSummary(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final summary = summarizeLearningRecommendationScores(recommendations);
  return '\u6700\u9ad8\u6392\u5e8f\u5206\uff1a${summary.topScore} / '
      '\u6700\u4f4e\u6392\u5e8f\u5206\uff1a${summary.lowestScore} / '
      '\u5e73\u5747\u6392\u5e8f\u5206\uff1a${summary.averageScore}';
}

String formatLearningRecommendationListStatus({
  required Iterable<RecommendedLearningResource> recommendations,
  Set<String> completedResourceIds = const {},
}) {
  return '\u5df2\u5b8c\u6210\u8d44\u6e90\uff1a${completedResourceIds.length} / '
      '\u5f53\u524d\u63a8\u8350\uff1a${recommendations.length}';
}

String formatLearningRecommendationTopResource(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final recommendationList = recommendations.toList(growable: false);
  if (recommendationList.isEmpty) return '\u65e0';
  final topRecommendation = recommendationList.first;
  return '${topRecommendation.resource.title} / '
      '\u6392\u5e8f\u5206\uff1a${topRecommendation.score}';
}

String formatLearningRecommendationTypeDistribution(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final typeCounts = <String, int>{};
  for (final recommendation in recommendations) {
    typeCounts.update(
      recommendation.resource.type.label,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  return _formatRecommendationCounts(typeCounts);
}

String formatLearningRecommendationDifficultyDistribution(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final levelCounts = <String, int>{};
  for (final recommendation in recommendations) {
    levelCounts.update(
      recommendation.resource.level,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  return _formatRecommendationCounts(levelCounts);
}

String formatLearningRecommendationResourceStructure(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final recommendationList = recommendations.toList(growable: false);
  return '\u7c7b\u578b\u5206\u5e03\uff1a'
      '${formatLearningRecommendationTypeDistribution(recommendationList)} / '
      '\u96be\u5ea6\u5206\u5e03\uff1a'
      '${formatLearningRecommendationDifficultyDistribution(recommendationList)}';
}

String formatLearningRecommendationPipelineSummary() {
  return '\u63a8\u8350\u6d41\u7a0b\uff1a'
      '${recommendationPipelineStages.join(' -> ')} / '
      '\u9636\u6bb5\u6570\uff1a${recommendationPipelineStages.length}';
}

String formatLearningRecommendationTopicDistribution(
  Iterable<RecommendedLearningResource> recommendations,
) {
  final tagCounts = <String, int>{};
  for (final recommendation in recommendations) {
    for (final tag in recommendation.resource.tags) {
      tagCounts.update(
        tag,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }
  return _formatRecommendationCounts(tagCounts);
}

String _formatRecommendationTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatRecommendationCounts(Map<String, int> counts) {
  if (counts.isEmpty) return '\u65e0';
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return entries.map((entry) => '${entry.key} ${entry.value}').join('\u3001');
}

int _scoreResourceForGoal(
  PlatformLearningResource resource,
  PlatformLearningGoal goal,
) {
  var score = 0;
  final title = resource.title.toLowerCase();
  final description = resource.description.toLowerCase();
  final tags = resource.tags.map((tag) => tag.toLowerCase()).toList();

  for (final keyword in goal.keywords) {
    final normalizedKeyword = keyword.toLowerCase();
    if (title.contains(normalizedKeyword)) score += 5;
    if (tags.any((tag) => tag.contains(normalizedKeyword))) score += 4;
    if (description.contains(normalizedKeyword)) score += 2;
  }

  if (goal == PlatformLearningGoal.rag &&
      resource.type == PlatformResourceType.rag) {
    score += 3;
  }
  if (goal == PlatformLearningGoal.recommendation &&
      resource.type == PlatformResourceType.model) {
    score += 3;
  }
  if (goal == PlatformLearningGoal.codeAudit &&
      resource.type == PlatformResourceType.skill) {
    score += 2;
  }
  if (goal.preferredTypes.contains(resource.type)) {
    score += 2;
  }
  score += _levelScore(resource.level, goal);

  return score;
}

int _levelScore(String level, PlatformLearningGoal goal) {
  return switch ((goal, level)) {
    (PlatformLearningGoal.foundation, '入门') => 3,
    (PlatformLearningGoal.foundation, '基础') => 3,
    (PlatformLearningGoal.rag, '本地') => 3,
    (PlatformLearningGoal.codeAudit, '实战') => 3,
    (PlatformLearningGoal.recommendation, '进阶') => 3,
    (PlatformLearningGoal.recommendation, '高级') => 2,
    _ => 0,
  };
}

String _buildReason(
  PlatformLearningResource resource,
  PlatformLearningGoal goal,
  int score,
) {
  final matchedTags = resource.tags.where((tag) {
    final normalizedTag = tag.toLowerCase();
    return goal.keywords.any(
      (keyword) => normalizedTag.contains(keyword.toLowerCase()),
    );
  }).toList();

  if (matchedTags.isNotEmpty) {
    return '匹配 ${goal.label} 目标：${matchedTags.join('、')}；${resource.type.label} 类型适合当前阶段，排序分 $score。';
  }
  return '资源描述与 ${goal.label} 目标相关；按类型、难度和目标关键词综合排序，排序分 $score。';
}
