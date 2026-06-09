import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';
import 'package:kazumi/utils/platform_storage.dart';

class PlatformLearningProgressRepository {
  const PlatformLearningProgressRepository({
    this.storage = const HivePlatformRagStorage(),
  });

  final PlatformRagStorage storage;

  Future<Set<String>> loadCompletedResourceIds() async {
    try {
      final raw = storage.get(
        PlatformSettingKey.platformCompletedLearningResources,
        defaultValue: const [],
      );
      if (raw is! List) return const {};
      return raw
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  Future<void> saveCompletedResourceIds(Set<String> resourceIds) async {
    try {
      await storage.put(
        PlatformSettingKey.platformCompletedLearningResources,
        resourceIds.toList()..sort(),
      );
    } catch (_) {}
  }
}

String buildLearningProgressMarkdown({
  required Set<String> completedResourceIds,
  required Iterable<PlatformLearningResource> resources,
  DateTime? generatedAt,
}) {
  final resourceList = resources.toList(growable: false);
  final completedResources = resourceList
      .where((resource) => completedResourceIds.contains(resource.id))
      .toList(growable: false);
  final nextResource = formatLearningProgressNextResource(
    completedResourceIds: completedResourceIds,
    resources: resourceList,
  );
  final generatedTime = generatedAt ?? DateTime.now();
  final typeCounts = <String, int>{};
  final levelCounts = <String, int>{};

  for (final resource in completedResources) {
    typeCounts.update(
      resource.type.label,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    levelCounts.update(
      resource.level,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  final buffer = StringBuffer()
    ..writeln('# 学习进度复盘')
    ..writeln()
    ..writeln('- 生成时间：${_formatLearningProgressTimestamp(generatedTime)}')
    ..writeln('- 已完成：${completedResources.length}/${resourceList.length}')
    ..writeln(
      '- 剩余资源：${_remainingLearningResourceCount(
        completedResources.length,
        resourceList.length,
      )}',
    )
    ..writeln('- \u4e0b\u4e00\u8d44\u6e90\uff1a$nextResource')
    ..writeln(
      '- 完成度：${_formatLearningProgressRatio(
        completedResources.length,
        resourceList.length,
      )}',
    )
    ..writeln('- 类型分布：${_formatLearningProgressCounts(typeCounts)}');

  buffer.writeln(
    '- \u96be\u5ea6\u5206\u5e03\uff1a${_formatLearningProgressCounts(levelCounts)}',
  );

  if (completedResources.isEmpty) {
    buffer
      ..writeln()
      ..writeln('暂无已完成的学习资源。');
    return buffer.toString().trimRight();
  }

  buffer
    ..writeln()
    ..writeln('## 已完成资源');

  for (var index = 0; index < completedResources.length; index++) {
    final resource = completedResources[index];
    buffer
      ..writeln()
      ..writeln('${index + 1}. ${resource.title}')
      ..writeln('   - 类型：${resource.type.label}')
      ..writeln('   - 难度：${resource.level}')
      ..writeln('   - 标签：${resource.tags.join('、')}')
      ..writeln('   - 入口：${resource.url}');
  }

  return buffer.toString().trimRight();
}

String formatLearningProgressSummary({
  required int completedCount,
  required int totalCount,
  String nextResource = '\u65e0',
}) {
  return '\u5df2\u5b8c\u6210\uff1a$completedCount/$totalCount / '
      '\u5269\u4f59\u8d44\u6e90\uff1a${_remainingLearningResourceCount(
    completedCount,
    totalCount,
  )} / '
      '\u4e0b\u4e00\u8d44\u6e90\uff1a$nextResource / '
      '\u5b8c\u6210\u5ea6\uff1a${_formatLearningProgressRatio(
    completedCount,
    totalCount,
  )}';
}

String formatLearningProgressNextResource({
  required Set<String> completedResourceIds,
  required Iterable<PlatformLearningResource> resources,
}) {
  for (final resource in resources) {
    if (!completedResourceIds.contains(resource.id)) {
      return resource.title;
    }
  }
  return '\u65e0';
}

String _formatLearningProgressTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatLearningProgressRatio(int completedCount, int totalCount) {
  if (totalCount <= 0) return '0%';
  final ratio = completedCount * 100 / totalCount;
  if (ratio == ratio.roundToDouble()) {
    return '${ratio.toStringAsFixed(0)}%';
  }
  return '${ratio.toStringAsFixed(1)}%';
}

int _remainingLearningResourceCount(int completedCount, int totalCount) {
  if (totalCount <= completedCount) return 0;
  return totalCount - completedCount;
}

String _formatLearningProgressCounts(Map<String, int> counts) {
  if (counts.isEmpty) return '无';
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return entries.map((entry) => '${entry.key} ${entry.value}').join('、');
}
