import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/pages/platform/platform_relax_session_repository.dart';
import 'package:kazumi/utils/storage.dart';

void main() {
  test('relax session serializes and deserializes', () {
    final completedAt = DateTime(2026, 5, 30, 10, 30);
    final session = RelaxSessionRecord(
      title: '专注 25 分钟',
      minutes: 25,
      completedAt: completedAt,
    );

    final restored = RelaxSessionRecord.fromJson(session.toJson());

    expect(restored.title, session.title);
    expect(restored.minutes, session.minutes);
    expect(restored.completedAt, session.completedAt);
  });

  test('relax repository saves sessions sorted by completion time', () async {
    final storage = _MemoryPlatformStorage();
    final repository = PlatformRelaxSessionRepository(storage: storage);
    final older = RelaxSessionRecord(
      title: '短休息 5 分钟',
      minutes: 5,
      completedAt: DateTime(2026, 5, 30, 9),
    );
    final newer = RelaxSessionRecord(
      title: '专注 25 分钟',
      minutes: 25,
      completedAt: DateTime(2026, 5, 30, 10),
    );

    await repository.saveSessions([older, newer]);
    final loaded = await repository.loadSessions();

    expect(storage.values.containsKey(SettingBoxKey.platformRelaxSessions),
        isTrue);
    expect(loaded.map((session) => session.title), [
      '专注 25 分钟',
      '短休息 5 分钟',
    ]);
  });

  test('relax session summary formats records as markdown', () {
    final summary = formatRelaxSessionSummary(
      [
        RelaxSessionRecord(
          title: '短休息 5 分钟',
          minutes: 5,
          completedAt: DateTime(2026, 5, 30, 9),
        ),
        RelaxSessionRecord(
          title: '专注 25 分钟',
          minutes: 25,
          completedAt: DateTime(2026, 5, 30, 10),
        ),
      ],
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(summary, contains('# 放松节奏总结'));
    expect(summary, contains('- 生成时间：2026-05-30 11:00'));
    expect(summary, contains('- 记录次数：2'));
    expect(summary, contains('- 累计分钟：30'));
    expect(summary, contains('- 节奏分布：'));
    expect(summary, contains('专注 25 分钟 1 次/25 分钟'));
    expect(summary, contains('短休息 5 分钟 1 次/5 分钟'));
    expect(summary, contains('2026-05-30 10:00 · 专注 25 分钟 · 25 分钟'));
    expect(summary, contains('2026-05-30 09:00 · 短休息 5 分钟 · 5 分钟'));
  });

  test('relax session record formats one entry as markdown', () {
    final markdown = formatRelaxSessionRecordMarkdown(
      RelaxSessionRecord(
        title: '专注 25 分钟',
        minutes: 25,
        completedAt: DateTime(2026, 5, 30, 10),
      ),
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(markdown, contains('# 放松节奏记录'));
    expect(markdown, contains('- 生成时间：2026-05-30 11:00'));
    expect(markdown, contains('- 完成时间：2026-05-30 10:00'));
    expect(markdown, contains('- 节奏：专注 25 分钟'));
    expect(markdown, contains('- 分钟：25'));
  });

  test('relax session summary handles empty session distribution', () {
    final summary = formatRelaxSessionSummary(
      const [],
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(summary, contains('- 记录次数：0'));
    expect(summary, contains('- 累计分钟：0'));
    expect(summary, contains('- 节奏分布：无'));
    expect(summary, contains('暂无节奏记录。'));
  });

  test('relax session distribution groups records by rhythm', () {
    final distribution = formatRelaxSessionDistribution([
      RelaxSessionRecord(
        title: '专注 25 分钟',
        minutes: 25,
        completedAt: DateTime(2026, 5, 30, 10),
      ),
      RelaxSessionRecord(
        title: '专注 25 分钟',
        minutes: 25,
        completedAt: DateTime(2026, 5, 30, 11),
      ),
      RelaxSessionRecord(
        title: '短休息 5 分钟',
        minutes: 5,
        completedAt: DateTime(2026, 5, 30, 12),
      ),
    ]);

    expect(distribution, contains('专注 25 分钟 2 次/50 分钟'));
    expect(distribution, contains('短休息 5 分钟 1 次/5 分钟'));
  });

  test('relax session summary includes average longest and shortest records',
      () {
    final summary = formatRelaxSessionSummary(
      [
        RelaxSessionRecord(
          title: '\u77ed\u4f11\u606f 5 \u5206\u949f',
          minutes: 5,
          completedAt: DateTime(2026, 5, 30, 9),
        ),
        RelaxSessionRecord(
          title: '\u4e13\u6ce8 25 \u5206\u949f',
          minutes: 25,
          completedAt: DateTime(2026, 5, 30, 10),
        ),
      ],
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(summary, contains('- \u5e73\u5747\u5206\u949f\uff1a15.0'));
    expect(
      summary,
      contains(
          '- \u6700\u957f\u8bb0\u5f55\uff1a\u4e13\u6ce8 25 \u5206\u949f / 25 \u5206\u949f'),
    );
    expect(
      summary,
      contains(
          '- \u6700\u77ed\u8bb0\u5f55\uff1a\u77ed\u4f11\u606f 5 \u5206\u949f / 5 \u5206\u949f'),
    );
    expect(
      summary,
      contains(
          '- \u6700\u8fd1\u8bb0\u5f55\uff1a\u4e13\u6ce8 25 \u5206\u949f / 25 \u5206\u949f / 2026-05-30 10:00'),
    );
  });

  test('relax session highlight summary formats average and records', () {
    final sessions = [
      RelaxSessionRecord(
        title: '\u77ed\u4f11\u606f 5 \u5206\u949f',
        minutes: 5,
        completedAt: DateTime(2026, 5, 30, 9),
      ),
      RelaxSessionRecord(
        title: '\u4e13\u6ce8 25 \u5206\u949f',
        minutes: 25,
        completedAt: DateTime(2026, 5, 30, 10),
      ),
    ];
    final summary = summarizeRelaxSessionHighlights(sessions);

    expect(summary.averageMinutes, '15.0');
    expect(
      summary.longestRecord,
      '\u4e13\u6ce8 25 \u5206\u949f / 25 \u5206\u949f',
    );
    expect(
      summary.shortestRecord,
      '\u77ed\u4f11\u606f 5 \u5206\u949f / 5 \u5206\u949f',
    );
    expect(
      summary.latestRecord,
      '\u4e13\u6ce8 25 \u5206\u949f / 25 \u5206\u949f / 2026-05-30 10:00',
    );
    expect(
      formatRelaxSessionHighlightSummary(sessions),
      contains('\u5e73\u5747\u5206\u949f\uff1a15.0'),
    );
  });

  test('relax session filter summary formats count and minutes', () {
    final sessions = [
      RelaxSessionRecord(
        title: '\u77ed\u4f11\u606f 5 \u5206\u949f',
        minutes: 5,
        completedAt: DateTime(2026, 5, 30, 9),
      ),
      RelaxSessionRecord(
        title: '\u957f\u4f11\u606f 15 \u5206\u949f',
        minutes: 15,
        completedAt: DateTime(2026, 5, 30, 10),
      ),
    ];

    expect(
      formatRelaxSessionFilterSummary(sessions),
      '\u5f53\u524d\u7b5b\u9009 2 \u6b21\uff0c\u5171 20 \u5206\u949f\u3002',
    );
    expect(
      formatRelaxSessionFilterSummary(const []),
      '\u5f53\u524d\u7b5b\u9009 0 \u6b21\uff0c\u5171 0 \u5206\u949f\u3002',
    );
  });

  test('relax session filtered summary formats selected records', () {
    final markdown = formatRelaxSessionFilteredSummary(
      [
        RelaxSessionRecord(
          title: '\u77ed\u4f11\u606f 5 \u5206\u949f',
          minutes: 5,
          completedAt: DateTime(2026, 5, 30, 9),
        ),
        RelaxSessionRecord(
          title: '\u957f\u4f11\u606f 15 \u5206\u949f',
          minutes: 15,
          completedAt: DateTime(2026, 5, 30, 10),
        ),
      ],
      filterLabel: '\u4f11\u606f',
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(markdown,
        contains('# \u653e\u677e\u8282\u594f\u7b5b\u9009\u603b\u7ed3'));
    expect(markdown, contains('- \u7b5b\u9009\u8303\u56f4\uff1a\u4f11\u606f'));
    expect(
      markdown,
      contains(
          '- \u5f53\u524d\u7b5b\u9009 2 \u6b21\uff0c\u5171 20 \u5206\u949f\u3002'),
    );
    expect(markdown, contains('- \u5e73\u5747\u5206\u949f\uff1a10.0'));
    expect(markdown, contains('## \u5f53\u524d\u7b5b\u9009\u8bb0\u5f55'));
    expect(
      markdown,
      contains(
          '2026-05-30 10:00 / \u957f\u4f11\u606f 15 \u5206\u949f / 15 \u5206\u949f'),
    );
  });

  test('relax session filtered summary handles empty records', () {
    final markdown = formatRelaxSessionFilteredSummary(
      const [],
      filterLabel: '\u4f11\u606f',
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(
      markdown,
      contains(
          '- \u5f53\u524d\u7b5b\u9009 0 \u6b21\uff0c\u5171 0 \u5206\u949f\u3002'),
    );
    expect(
      markdown,
      contains(
          '\u6682\u65e0\u5f53\u524d\u7b5b\u9009\u7684\u8282\u594f\u8bb0\u5f55\u3002'),
    );
  });

  test('relax session summary includes empty average and record highlights',
      () {
    final summary = formatRelaxSessionSummary(
      const [],
      generatedAt: DateTime(2026, 5, 30, 11),
    );

    expect(summary, contains('- \u5e73\u5747\u5206\u949f\uff1a0.0'));
    expect(summary, contains('- \u6700\u957f\u8bb0\u5f55\uff1a\u65e0'));
    expect(summary, contains('- \u6700\u77ed\u8bb0\u5f55\uff1a\u65e0'));
    expect(summary, contains('- \u6700\u8fd1\u8bb0\u5f55\uff1a\u65e0'));
    expect(
      formatRelaxSessionHighlightSummary(const []),
      '\u5e73\u5747\u5206\u949f\uff1a0.0 / '
      '\u6700\u957f\u8bb0\u5f55\uff1a\u65e0 / '
      '\u6700\u77ed\u8bb0\u5f55\uff1a\u65e0 / '
      '\u6700\u8fd1\u8bb0\u5f55\uff1a\u65e0',
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
