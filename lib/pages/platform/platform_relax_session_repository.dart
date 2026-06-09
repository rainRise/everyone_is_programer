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

class RelaxSessionHighlightSummary {
  const RelaxSessionHighlightSummary({
    required this.averageMinutes,
    required this.longestRecord,
    required this.shortestRecord,
    required this.latestRecord,
  });

  final String averageMinutes;
  final String longestRecord;
  final String shortestRecord;
  final String latestRecord;
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
  final highlightSummary = summarizeRelaxSessionHighlights(sortedSessions);
  final generatedTime = generatedAt ?? DateTime.now();
  final buffer = StringBuffer()
    ..writeln('# 放松节奏总结')
    ..writeln()
    ..writeln('- 生成时间：${_formatDateTime(generatedTime)}')
    ..writeln('- 记录次数：${sortedSessions.length}')
    ..writeln('- 累计分钟：$totalMinutes')
    ..writeln('- 节奏分布：${formatRelaxSessionDistribution(sortedSessions)}')
    ..writeln();

  buffer
    ..writeln(
        '- \u5e73\u5747\u5206\u949f\uff1a${highlightSummary.averageMinutes}')
    ..writeln(
        '- \u6700\u957f\u8bb0\u5f55\uff1a${highlightSummary.longestRecord}')
    ..writeln(
        '- \u6700\u77ed\u8bb0\u5f55\uff1a${highlightSummary.shortestRecord}')
    ..writeln(
        '- \u6700\u8fd1\u8bb0\u5f55\uff1a${highlightSummary.latestRecord}')
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

RelaxSessionHighlightSummary summarizeRelaxSessionHighlights(
  List<RelaxSessionRecord> sessions,
) {
  final sortedSessions = [...sessions]
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  final totalMinutes = sortedSessions.fold<int>(
    0,
    (sum, session) => sum + session.minutes,
  );
  final longestSession = sortedSessions.isEmpty
      ? null
      : sortedSessions.reduce(
          (current, next) => next.minutes > current.minutes ? next : current,
        );
  final shortestSession = sortedSessions.isEmpty
      ? null
      : sortedSessions.reduce(
          (current, next) => next.minutes < current.minutes ? next : current,
        );
  final latestSession = sortedSessions.isEmpty ? null : sortedSessions.first;

  return RelaxSessionHighlightSummary(
    averageMinutes: sortedSessions.isEmpty
        ? '0.0'
        : (totalMinutes / sortedSessions.length).toStringAsFixed(1),
    longestRecord: longestSession == null
        ? '\u65e0'
        : '${longestSession.title} / ${longestSession.minutes} \u5206\u949f',
    shortestRecord: shortestSession == null
        ? '\u65e0'
        : '${shortestSession.title} / ${shortestSession.minutes} \u5206\u949f',
    latestRecord: latestSession == null
        ? '\u65e0'
        : '${latestSession.title} / ${latestSession.minutes} \u5206\u949f / '
            '${_formatDateTime(latestSession.completedAt)}',
  );
}

String formatRelaxSessionHighlightSummary(List<RelaxSessionRecord> sessions) {
  final summary = summarizeRelaxSessionHighlights(sessions);
  return '\u5e73\u5747\u5206\u949f\uff1a${summary.averageMinutes} / '
      '\u6700\u957f\u8bb0\u5f55\uff1a${summary.longestRecord} / '
      '\u6700\u77ed\u8bb0\u5f55\uff1a${summary.shortestRecord} / '
      '\u6700\u8fd1\u8bb0\u5f55\uff1a${summary.latestRecord}';
}

String formatRelaxSessionFilterSummary(List<RelaxSessionRecord> sessions) {
  final totalMinutes = sessions.fold<int>(
    0,
    (sum, session) => sum + session.minutes,
  );
  return '\u5f53\u524d\u7b5b\u9009 ${sessions.length} \u6b21\uff0c'
      '\u5171 $totalMinutes \u5206\u949f\u3002';
}

String formatRelaxSessionFilteredSummary(
  List<RelaxSessionRecord> sessions, {
  required String filterLabel,
  DateTime? generatedAt,
}) {
  final sortedSessions = [...sessions]
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  final highlightSummary = summarizeRelaxSessionHighlights(sortedSessions);
  final generatedTime = generatedAt ?? DateTime.now();
  final buffer = StringBuffer()
    ..writeln('# \u653e\u677e\u8282\u594f\u7b5b\u9009\u603b\u7ed3')
    ..writeln()
    ..writeln(
        '- \u751f\u6210\u65f6\u95f4\uff1a${_formatDateTime(generatedTime)}')
    ..writeln('- \u7b5b\u9009\u8303\u56f4\uff1a$filterLabel')
    ..writeln('- ${formatRelaxSessionFilterSummary(sortedSessions)}')
    ..writeln(
        '- \u8282\u594f\u5206\u5e03\uff1a${formatRelaxSessionDistribution(sortedSessions)}')
    ..writeln()
    ..writeln(
        '- \u5e73\u5747\u5206\u949f\uff1a${highlightSummary.averageMinutes}')
    ..writeln(
        '- \u6700\u957f\u8bb0\u5f55\uff1a${highlightSummary.longestRecord}')
    ..writeln(
        '- \u6700\u77ed\u8bb0\u5f55\uff1a${highlightSummary.shortestRecord}')
    ..writeln(
        '- \u6700\u8fd1\u8bb0\u5f55\uff1a${highlightSummary.latestRecord}')
    ..writeln();

  if (sortedSessions.isEmpty) {
    buffer.writeln(
        '\u6682\u65e0\u5f53\u524d\u7b5b\u9009\u7684\u8282\u594f\u8bb0\u5f55\u3002');
    return buffer.toString();
  }

  buffer
    ..writeln('## \u5f53\u524d\u7b5b\u9009\u8bb0\u5f55')
    ..writeln();
  for (final session in sortedSessions) {
    buffer.writeln(
      '- ${_formatDateTime(session.completedAt)} / '
      '${session.title} / ${session.minutes} \u5206\u949f',
    );
  }

  return buffer.toString();
}

String formatRelaxSessionRecordMarkdown(
  RelaxSessionRecord session, {
  DateTime? generatedAt,
}) {
  final generatedTime = generatedAt ?? DateTime.now();
  final buffer = StringBuffer()
    ..writeln('# 放松节奏记录')
    ..writeln()
    ..writeln('- 生成时间：${_formatDateTime(generatedTime)}')
    ..writeln('- 完成时间：${_formatDateTime(session.completedAt)}')
    ..writeln('- 节奏：${session.title}')
    ..writeln('- 分钟：${session.minutes}');
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
