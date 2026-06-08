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
