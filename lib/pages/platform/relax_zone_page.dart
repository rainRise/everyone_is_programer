import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/platform_page_header.dart';
import 'package:kazumi/pages/platform/platform_relax_session_repository.dart';
import 'package:kazumi/pages/platform/platform_relax_toolkit.dart';
import 'package:kazumi/pages/platform/relax_toolkit_preview.dart';

class RelaxZonePage extends StatefulWidget {
  const RelaxZonePage({
    super.key,
    this.sessionRepository = const PlatformRelaxSessionRepository(),
  });

  final PlatformRelaxSessionRepository sessionRepository;

  @override
  State<RelaxZonePage> createState() => _RelaxZonePageState();
}

enum _RelaxHistoryFilter {
  all('全部'),
  focus('专注'),
  rest('休息');

  const _RelaxHistoryFilter(this.label);

  final String label;

  bool matches(RelaxSessionRecord session) {
    return switch (this) {
      _RelaxHistoryFilter.all => true,
      _RelaxHistoryFilter.focus => session.title.contains('专注'),
      _RelaxHistoryFilter.rest => session.title.contains('休息'),
    };
  }
}

class _RelaxZonePageState extends State<RelaxZonePage> {
  int _selectedToolIndex = 0;
  _RelaxHistoryFilter _historyFilter = _RelaxHistoryFilter.all;
  late int _remainingSeconds = relaxTools.first.minutes * 60;
  final List<RelaxSessionRecord> _sessions = [];
  Timer? _timer;

  RelaxTool get _selectedTool => relaxTools[_selectedToolIndex];

  bool get _isRunning => _timer?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectTool(int index) {
    _timer?.cancel();
    setState(() {
      _selectedToolIndex = index;
      _remainingSeconds = relaxTools[index].minutes * 60;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {});
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _selectedTool.minutes * 60;
    });
  }

  Future<void> _loadSessions() async {
    final sessions = await widget.sessionRepository.loadSessions();
    if (!mounted) return;
    setState(() {
      _sessions
        ..clear()
        ..addAll(sessions);
    });
  }

  Future<void> _saveSessions() async {
    await widget.sessionRepository.saveSessions(_sessions);
  }

  Future<void> _recordSession() async {
    _timer?.cancel();
    setState(() {
      _sessions.insert(
        0,
        RelaxSessionRecord(
          title: _selectedTool.title,
          minutes: _selectedTool.minutes,
          completedAt: DateTime.now(),
        ),
      );
      _remainingSeconds = _selectedTool.minutes * 60;
    });
    await _saveSessions();
  }

  Future<void> _clearSessions() async {
    final removedSessions = List<RelaxSessionRecord>.from(_sessions);
    setState(_sessions.clear);
    await _saveSessions();
    if (!mounted || removedSessions.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('节奏记录已清空'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () => _restoreClearedSessions(removedSessions),
          ),
        ),
      );
  }

  Future<void> _deleteSession(int index) async {
    if (index < 0 || index >= _sessions.length) return;
    final removedSession = _sessions[index];
    setState(() {
      _sessions.removeAt(index);
    });
    await _saveSessions();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removedSession.title} 已删除'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () {
              unawaited(_restoreDeletedSession(removedSession, index));
            },
          ),
        ),
      );
  }

  Future<void> _restoreDeletedSession(
    RelaxSessionRecord removedSession,
    int index,
  ) async {
    final insertIndex = index.clamp(0, _sessions.length).toInt();
    setState(() {
      _sessions.insert(insertIndex, removedSession);
    });
    await _saveSessions();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${removedSession.title} 已恢复')),
      );
  }

  Future<void> _restoreClearedSessions(
    List<RelaxSessionRecord> removedSessions,
  ) async {
    setState(() {
      _sessions
        ..clear()
        ..addAll(removedSessions);
    });
    await _saveSessions();
  }

  Future<void> _copySessionSummary(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: formatRelaxSessionSummary(_sessions)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('节奏总结已复制')),
    );
  }

  Future<void> _copyFilteredSessionSummary(
    BuildContext context,
    List<RelaxSessionRecord> sessions,
    _RelaxHistoryFilter filter,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: formatRelaxSessionFilteredSummary(
          sessions,
          filterLabel: filter.label,
        ),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${filter.label} 节奏总结已复制')),
    );
  }

  Future<void> _copySessionRecord(
    BuildContext context,
    RelaxSessionRecord session,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: formatRelaxSessionRecordMarkdown(session)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${session.title} 记录已复制')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformPageHeader(
                title: '放松区',
                subtitle: '给长时间学习和编码后的恢复空间，避免效率透支。',
                onOpenSettings: () {
                  Modular.to.pushNamed('/settings/');
                },
              ),
              const SizedBox(height: 24),
              _FocusTimerPanel(
                selectedToolIndex: _selectedToolIndex,
                remainingSeconds: _remainingSeconds,
                isRunning: _isRunning,
                onToolSelected: _selectTool,
                onToggle: _toggleTimer,
                onReset: _resetTimer,
                onRecord: _recordSession,
              ),
              const SizedBox(height: 16),
              _RelaxSessionHistoryPanel(
                sessions: _sessions,
                selectedFilter: _historyFilter,
                onClear: _clearSessions,
                onCopySummary: () => _copySessionSummary(context),
                onCopyFilteredSummary: (sessions) {
                  unawaited(
                    _copyFilteredSessionSummary(
                      context,
                      sessions,
                      _historyFilter,
                    ),
                  );
                },
                onCopyRecord: (session) {
                  unawaited(_copySessionRecord(context, session));
                },
                onFilterChanged: (filter) {
                  setState(() {
                    _historyFilter = filter;
                  });
                },
                onDelete: (index) {
                  unawaited(_deleteSession(index));
                },
              ),
              const SizedBox(height: 16),
              const _RelaxItem(
                icon: Icons.timer_outlined,
                title: '番茄钟',
                description: '提供专注、短休息和长休息三种节奏计时。',
              ),
              const _RelaxItem(
                icon: Icons.spa_outlined,
                title: '休息资源',
                description: '放置伸展、冥想、白噪音和短休息资源。',
              ),
              const _RelaxItem(
                icon: Icons.extension_outlined,
                title: '轻量工具',
                description: '沉淀不打断心流的小工具和快捷入口。',
              ),
              const SizedBox(height: 12),
              const RelaxToolkitPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusTimerPanel extends StatelessWidget {
  const _FocusTimerPanel({
    required this.selectedToolIndex,
    required this.remainingSeconds,
    required this.isRunning,
    required this.onToolSelected,
    required this.onToggle,
    required this.onReset,
    required this.onRecord,
  });

  final int selectedToolIndex;
  final int remainingSeconds;
  final bool isRunning;
  final ValueChanged<int> onToolSelected;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onRecord;

  String get _timeLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTool = relaxTools[selectedToolIndex];
    final totalSeconds = selectedTool.minutes * 60;
    final progress = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '专注节奏',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < relaxTools.length; i++)
                  ChoiceChip(
                    avatar: Icon(relaxTools[i].icon, size: 18),
                    label: Text(relaxTools[i].title),
                    selected: selectedToolIndex == i,
                    onSelected: (_) => onToolSelected(i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeLabel,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(selectedTool.title),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onToggle,
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isRunning ? '暂停' : '开始'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: '重置',
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: '记录完成',
                  onPressed: onRecord,
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RelaxSessionHistoryPanel extends StatelessWidget {
  const _RelaxSessionHistoryPanel({
    required this.sessions,
    required this.selectedFilter,
    required this.onClear,
    required this.onCopySummary,
    required this.onCopyFilteredSummary,
    required this.onCopyRecord,
    required this.onFilterChanged,
    required this.onDelete,
  });

  final List<RelaxSessionRecord> sessions;
  final _RelaxHistoryFilter selectedFilter;
  final VoidCallback onClear;
  final VoidCallback onCopySummary;
  final ValueChanged<List<RelaxSessionRecord>> onCopyFilteredSummary;
  final ValueChanged<RelaxSessionRecord> onCopyRecord;
  final ValueChanged<_RelaxHistoryFilter> onFilterChanged;
  final ValueChanged<int> onDelete;

  int get totalMinutes {
    return sessions.fold(0, (sum, session) => sum + session.minutes);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredEntries = sessions.indexed
        .where((entry) => selectedFilter.matches(entry.$2))
        .toList();
    final filteredSessions =
        filteredEntries.map((entry) => entry.$2).toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '节奏记录',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (sessions.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: '复制总结',
                        onPressed: onCopySummary,
                        icon: const Icon(Icons.copy_outlined),
                      ),
                      TextButton.icon(
                        onPressed: onClear,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('清空'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('已记录 ${sessions.length} 次，共 $totalMinutes 分钟。'),
            const SizedBox(height: 4),
            Text('节奏分布：${formatRelaxSessionDistribution(sessions)}'),
            const SizedBox(height: 4),
            Text(
              formatRelaxSessionHighlightSummary(sessions),
              key: const ValueKey('relax-session-highlight-summary'),
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Text('完成专注或休息后点击对勾记录一次。')
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in _RelaxHistoryFilter.values)
                    FilterChip(
                      label: Text('${filter.label} ${_countFor(filter)}'),
                      selected: selectedFilter == filter,
                      onSelected: (_) => onFilterChanged(filter),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatRelaxSessionFilterSummary(filteredSessions),
                      key: const ValueKey('relax-session-filter-summary'),
                    ),
                  ),
                  IconButton(
                    tooltip: '复制当前筛选总结',
                    onPressed: () => onCopyFilteredSummary(filteredSessions),
                    icon: const Icon(Icons.copy_all_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (filteredEntries.isEmpty)
                const Text('当前筛选暂无节奏记录。')
              else
                for (final entry in filteredEntries.take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(entry.$2.title),
                    subtitle: Text('${entry.$2.minutes} 分钟'),
                    trailing: Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_formatCompletedAt(entry.$2.completedAt)),
                        IconButton(
                          tooltip: '复制节奏记录',
                          onPressed: () => onCopyRecord(entry.$2),
                          icon: const Icon(Icons.copy_outlined),
                        ),
                        IconButton(
                          tooltip: '删除节奏记录',
                          onPressed: () => onDelete(entry.$1),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCompletedAt(DateTime completedAt) {
    final month = completedAt.month.toString().padLeft(2, '0');
    final day = completedAt.day.toString().padLeft(2, '0');
    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  int _countFor(_RelaxHistoryFilter filter) {
    return sessions.where(filter.matches).length;
  }
}

class _RelaxItem extends StatelessWidget {
  const _RelaxItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        tileColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
