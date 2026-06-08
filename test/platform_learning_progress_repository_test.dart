import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';
import 'package:kazumi/pages/platform/platform_learning_progress_repository.dart';
import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/utils/platform_storage.dart';

void main() {
  test('learning progress repository saves completed resource ids', () async {
    final storage = _MemoryPlatformStorage();
    final repository = PlatformLearningProgressRepository(storage: storage);

    await repository.saveCompletedResourceIds({'b', 'a'});
    final loaded = await repository.loadCompletedResourceIds();

    expect(
      storage.values.containsKey(
        PlatformSettingKey.platformCompletedLearningResources,
      ),
      isTrue,
    );
    expect(loaded.length, 2);
    expect(loaded.containsAll({'a', 'b'}), isTrue);
  });

  test('learning progress repository ignores invalid values', () async {
    final storage = _MemoryPlatformStorage()
      ..values[PlatformSettingKey.platformCompletedLearningResources] =
          'invalid';
    final repository = PlatformLearningProgressRepository(storage: storage);

    final loaded = await repository.loadCompletedResourceIds();

    expect(loaded, isEmpty);
  });

  test('learning progress markdown summarizes completed resources', () {
    final completed = {
      allPlatformLearningResources[0].id,
      allPlatformLearningResources[5].id,
    };

    final markdown = buildLearningProgressMarkdown(
      completedResourceIds: completed,
      resources: allPlatformLearningResources,
      generatedAt: DateTime(2026, 6, 8, 9, 30),
    );

    expect(markdown, startsWith('# 学习进度复盘'));
    expect(markdown, contains('- 生成时间：2026-06-08 09:30'));
    expect(
        markdown, contains('- 已完成：2/${allPlatformLearningResources.length}'));
    expect(markdown, contains('- 类型分布：'));
    expect(markdown, contains('## 已完成资源'));
    expect(markdown, contains('1. ${allPlatformLearningResources[0].title}'));
    expect(markdown, contains('2. ${allPlatformLearningResources[5].title}'));
    expect(
        markdown, contains('   - 入口：${allPlatformLearningResources[0].url}'));
  });

  test('learning progress markdown handles empty progress', () {
    final markdown = buildLearningProgressMarkdown(
      completedResourceIds: const {},
      resources: const [],
      generatedAt: DateTime(2026, 6, 8, 9, 30),
    );

    expect(markdown, contains('- 已完成：0/0'));
    expect(markdown, contains('- 完成度：0%'));
    expect(markdown, contains('- 类型分布：无'));
    expect(markdown, contains('暂无已完成的学习资源。'));
  });
}

class _MemoryPlatformStorage implements PlatformRagStorage {
  final Map<String, Object?> values = {};

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values[key] ?? defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }
}
