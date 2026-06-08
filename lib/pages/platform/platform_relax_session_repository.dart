import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/utils/platform_storage.dart';

class RelaxSessionRecord {
  const RelaxSessionRecord({
    required this.title,
    required this.minutes,
    required this.completedAt,
  });

  final String title;
  final int minutes;
  final DateTime completedAt;

  factory RelaxSessionRecord.fromJson(Map<dynamic, dynamic> json) {
    return RelaxSessionRecord(
      title: json['title']?.toString() ?? '',
      minutes: int.tryParse(json['minutes']?.toString() ?? '') ?? 0,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object> toJson() {
    return {
      'title': title,
      'minutes': minutes,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

class PlatformRelaxSessionRepository {
  const PlatformRelaxSessionRepository({
    this.storage = const HivePlatformRagStorage(),
  });

  final PlatformRagStorage storage;

  Future<List<RelaxSessionRecord>> loadSessions() async {
    try {
      final raw = storage.get(
        PlatformSettingKey.platformRelaxSessions,
        defaultValue: const [],
      );
      if (raw is! List) return const [];

      final sessions = raw
          .whereType<Map<dynamic, dynamic>>()
          .map(RelaxSessionRecord.fromJson)
          .where((session) => session.title.isNotEmpty)
          .where((session) => session.minutes > 0)
          .toList();
      sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return sessions;
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSessions(List<RelaxSessionRecord> sessions) async {
    try {
      await storage.put(
        PlatformSettingKey.platformRelaxSessions,
        sessions.map((session) => session.toJson()).toList(),
      );
    } catch (_) {}
  }
}

String formatRelaxSessionSummary(
  List<RelaxSessionRecord> sessions, {
  DateTime? generatedAt,
}) {
  final sortedSessions = [...sessions]
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  final totalMinutes = sortedSessions.fold<int>(
    0,
    (sum, session) => sum + session.minutes,
  );
  final generatedTime = generatedAt ?? DateTime.now();
  final buffer = StringBuffer()
    ..writeln('# 放松节奏总结')
    ..writeln()
    ..writeln('- 生成时间：${_formatDateTime(generatedTime)}')
    ..writeln('- 记录次数：${sortedSessions.length}')
    ..writeln('- 累计分钟：$totalMinutes')
    ..writeln('- 节奏分布：${formatRelaxSessionDistribution(sortedSessions)}')
    ..writeln();

  if (sortedSessions.isEmpty) {
    buffer.writeln('暂无节奏记录。');
    return buffer.toString();
  }

  buffer
    ..writeln('## 最近记录')
    ..writeln();
  for (final session in sortedSessions) {
    buffer.writeln(
      '- ${_formatDateTime(session.completedAt)} · '
      '${session.title} · ${session.minutes} 分钟',
    );
  }

  return buffer.toString();
}

String formatRelaxSessionDistribution(List<RelaxSessionRecord> sessions) {
  if (sessions.isEmpty) return '无';

  final counts = <String, int>{};
  final minutes = <String, int>{};
  for (final session in sessions) {
    counts.update(session.title, (count) => count + 1, ifAbsent: () => 1);
    minutes.update(
      session.title,
      (totalMinutes) => totalMinutes + session.minutes,
      ifAbsent: () => session.minutes,
    );
  }

  final titles = counts.keys.toList()..sort();
  return titles
      .map((title) => '$title ${counts[title]} 次/${minutes[title]} 分钟')
      .join('；');
}

String _formatDateTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}
