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
  final generatedTime = generatedAt ?? DateTime.now();
  final typeCounts = <String, int>{};

  for (final resource in completedResources) {
    typeCounts.update(
      resource.type.label,
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
      '- 完成度：${_formatLearningProgressRatio(
        completedResources.length,
        resourceList.length,
      )}',
    )
    ..writeln('- 类型分布：${_formatLearningProgressCounts(typeCounts)}');

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
