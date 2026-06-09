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

    expect(markdown, startsWith('# \u5b66\u4e60\u8fdb\u5ea6\u590d\u76d8'));
    expect(
      markdown,
      contains('- \u751f\u6210\u65f6\u95f4\uff1a2026-06-08 09:30'),
    );
    expect(
      markdown,
      contains('- \u5df2\u5b8c\u6210\uff1a2/'
          '${allPlatformLearningResources.length}'),
    );
    expect(
      markdown,
      contains('- \u5269\u4f59\u8d44\u6e90\uff1a'
          '${allPlatformLearningResources.length - 2}'),
    );
    expect(
      markdown,
      contains(
          '- \u4e0b\u4e00\u8d44\u6e90\uff1a${allPlatformLearningResources[1].title}'),
    );
    expect(markdown, contains('- \u7c7b\u578b\u5206\u5e03\uff1a'));
    expect(markdown, contains('## \u5df2\u5b8c\u6210\u8d44\u6e90'));
    expect(markdown, contains('- \u96be\u5ea6\u5206\u5e03\uff1a'));
    expect(markdown, contains('1. ${allPlatformLearningResources[0].title}'));
    expect(markdown, contains('2. ${allPlatformLearningResources[5].title}'));
    expect(
      markdown,
      contains(
        '   - \u5165\u53e3\uff1a${allPlatformLearningResources[0].url}',
      ),
    );
  });

  test('learning progress markdown handles empty progress', () {
    final markdown = buildLearningProgressMarkdown(
      completedResourceIds: const {},
      resources: const [],
      generatedAt: DateTime(2026, 6, 8, 9, 30),
    );

    expect(markdown, contains('- \u5df2\u5b8c\u6210\uff1a0/0'));
    expect(markdown, contains('- \u5269\u4f59\u8d44\u6e90\uff1a0'));
    expect(markdown, contains('- \u4e0b\u4e00\u8d44\u6e90\uff1a\u65e0'));
    expect(markdown, contains('- \u5b8c\u6210\u5ea6\uff1a0%'));
    expect(markdown, contains('- \u7c7b\u578b\u5206\u5e03\uff1a\u65e0'));
    expect(
      markdown,
      contains(
        '\u6682\u65e0\u5df2\u5b8c\u6210\u7684\u5b66\u4e60\u8d44\u6e90\u3002',
      ),
    );
  });

  test('learning progress markdown includes empty level distribution', () {
    final markdown = buildLearningProgressMarkdown(
      completedResourceIds: const {},
      resources: const [],
      generatedAt: DateTime(2026, 6, 8, 9, 30),
    );

    expect(markdown, contains('- \u96be\u5ea6\u5206\u5e03\uff1a\u65e0'));
  });

  test('learning progress summary formats completion ratio and remaining count',
      () {
    expect(
      formatLearningProgressSummary(
        completedCount: 3,
        nextResource: 'CS50',
        totalCount: 12,
      ),
      '\u5df2\u5b8c\u6210\uff1a3/12 / '
      '\u5269\u4f59\u8d44\u6e90\uff1a9 / '
      '\u4e0b\u4e00\u8d44\u6e90\uff1aCS50 / '
      '\u5b8c\u6210\u5ea6\uff1a25%',
    );
    expect(
      formatLearningProgressSummary(completedCount: 0, totalCount: 0),
      '\u5df2\u5b8c\u6210\uff1a0/0 / '
      '\u5269\u4f59\u8d44\u6e90\uff1a0 / '
      '\u4e0b\u4e00\u8d44\u6e90\uff1a\u65e0 / '
      '\u5b8c\u6210\u5ea6\uff1a0%',
    );
    expect(
      formatLearningProgressSummary(completedCount: 8, totalCount: 6),
      '\u5df2\u5b8c\u6210\uff1a8/6 / '
      '\u5269\u4f59\u8d44\u6e90\uff1a0 / '
      '\u4e0b\u4e00\u8d44\u6e90\uff1a\u65e0 / '
      '\u5b8c\u6210\u5ea6\uff1a133.3%',
    );
  });

  test('learning progress next resource returns first unfinished resource', () {
    expect(
      formatLearningProgressNextResource(
        completedResourceIds: {allPlatformLearningResources.first.id},
        resources: allPlatformLearningResources,
      ),
      allPlatformLearningResources[1].title,
    );
    expect(
      formatLearningProgressNextResource(
        completedResourceIds:
            allPlatformLearningResources.map((resource) => resource.id).toSet(),
        resources: allPlatformLearningResources,
      ),
      '\u65e0',
    );
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
