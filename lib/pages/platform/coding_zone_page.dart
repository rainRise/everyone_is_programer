import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/code_audit_preview.dart';
import 'package:kazumi/pages/platform/platform_ai_audit_request.dart';
import 'package:kazumi/pages/platform/platform_code_audit_catalog.dart';
import 'package:kazumi/pages/platform/platform_code_audit_repository.dart';
import 'package:kazumi/pages/platform/platform_page_header.dart';
import 'package:kazumi/pages/platform/platform_code_audit_rules.dart';
import 'package:kazumi/pages/platform/platform_fix_suggestion_template.dart';

typedef CodeAuditReportHistoryLoader = Future<List<CodeAuditSavedReport>>
    Function({CodeAuditReportType? reportType});
typedef CodeAuditReportHistoryDeleter = Future<void> Function(
  CodeAuditSavedReport report,
);
typedef CodeAuditReportMarkdownReader = Future<String> Function(
  CodeAuditSavedReport report,
);
typedef CodeAuditReportHistoryRestorer = Future<void> Function(
  CodeAuditSavedReport report,
  String markdown,
);

Future<List<CodeAuditSavedReport>> _defaultReportHistoryLoader({
  CodeAuditReportType? reportType,
}) {
  return listCodeAuditReports(reportType: reportType);
}

Future<void> _defaultReportHistoryDeleter(CodeAuditSavedReport report) {
  return deleteCodeAuditReport(report);
}

Future<String> _defaultReportMarkdownReader(CodeAuditSavedReport report) {
  return readCodeAuditReportMarkdown(report);
}

Future<void> _defaultReportHistoryRestorer(
  CodeAuditSavedReport report,
  String markdown,
) async {
  await restoreCodeAuditReportMarkdown(report, markdown);
}

enum _ReportHistoryFilter {
  all,
  snippet,
  project,
}

extension _ReportHistoryFilterLabel on _ReportHistoryFilter {
  String get label {
    return switch (this) {
      _ReportHistoryFilter.all => '全部',
      _ReportHistoryFilter.snippet => '片段',
      _ReportHistoryFilter.project => '项目',
    };
  }

  CodeAuditReportType? get reportType {
    return switch (this) {
      _ReportHistoryFilter.all => null,
      _ReportHistoryFilter.snippet => CodeAuditReportType.snippet,
      _ReportHistoryFilter.project => CodeAuditReportType.project,
    };
  }

  String get emptyMessage {
    return switch (this) {
      _ReportHistoryFilter.all => '保存报告后会在这里显示最近的 Markdown 记录。',
      _ReportHistoryFilter.snippet => '没有片段审计 Markdown 记录。',
      _ReportHistoryFilter.project => '没有项目审计 Markdown 记录。',
    };
  }
}

class CodingZonePage extends StatefulWidget {
  const CodingZonePage({
    super.key,
    this.reportHistoryLoader,
    this.reportHistoryDeleter,
    this.reportMarkdownReader,
    this.reportHistoryRestorer,
  });

  final CodeAuditReportHistoryLoader? reportHistoryLoader;
  final CodeAuditReportHistoryDeleter? reportHistoryDeleter;
  final CodeAuditReportMarkdownReader? reportMarkdownReader;
  final CodeAuditReportHistoryRestorer? reportHistoryRestorer;

  @override
  State<CodingZonePage> createState() => _CodingZonePageState();
}

class _CodingZonePageState extends State<CodingZonePage> {
  final Set<String> _completedSteps = {};
  final TextEditingController _projectPathController = TextEditingController();
  final TextEditingController _codeSnippetController = TextEditingController(
    text: '''
const apiKey = "demo-secret-token";
final endpoint = "http://example.com/api";
print(endpoint);
''',
  );
  List<CodeAuditFinding> _findings = [];
  CodeAuditProjectReport? _projectReport;
  List<CodeAuditSavedReport> _savedReports = [];
  _ReportHistoryFilter _reportHistoryFilter = _ReportHistoryFilter.all;
  Set<String> _enabledRuleIds =
      localCodeAuditRules.map((rule) => rule.id).toSet();
  bool _isProjectScanning = false;
  String? _projectScanError;
  String? _lastSavedReportPath;
  int _selectedTemplateIndex = 0;

  static const _promptTemplates = [
    _PromptTemplate(
      title: '安全审计 Prompt',
      description: '用于发现敏感信息、危险调用、权限边界和输入校验问题。',
      prompt: '请以代码审计员身份审查当前项目。优先列出高风险问题，包含文件位置、触发条件、影响范围、复现思路和最小修复建议。',
    ),
    _PromptTemplate(
      title: '学习复盘 Prompt',
      description: '用于把项目实践沉淀成可放入本地 RAG 的知识片段。',
      prompt: '请把本次编程实践整理成学习笔记：背景、关键概念、踩坑点、修复过程、可复用代码片段和后续练习题。',
    ),
    _PromptTemplate(
      title: '推荐模型 Prompt',
      description: '用于分析资源推荐、召回、排序和重排方案。',
      prompt: '请设计一个学习资源推荐方案，说明用户画像、候选召回、BM25/Embedding 混合检索、粗排、精排、重排和评估指标。',
    ),
  ];

  double get _progress {
    if (codeAuditSteps.isEmpty) return 0;
    return _completedSteps.length / codeAuditSteps.length;
  }

  List<CodeAuditRule> get _enabledRules {
    return localCodeAuditRules
        .where((rule) => _enabledRuleIds.contains(rule.id))
        .toList(growable: false);
  }

  List<CodeAuditFinding> get _currentFindings {
    return _projectReport?.findings ?? _findings;
  }

  CodeAuditAiRequestDraft get _aiRequestDraft {
    final projectReport = _projectReport;
    return buildCodeAuditAiRequestDraft(
      findings: _currentFindings,
      projectReport: projectReport,
      enabledRules: _enabledRules,
    );
  }

  List<CodeAuditFixSuggestionTemplate> get _fixSuggestionTemplates {
    return buildCodeAuditFixSuggestionTemplates(
      findings: _currentFindings,
      projectReport: _projectReport,
    );
  }

  @override
  void initState() {
    super.initState();
    _findings = scanCodeSnippet(
      _codeSnippetController.text,
      filePath: 'local_snippet.dart',
      enabledRuleIds: _enabledRuleIds,
    );
    _loadReportHistory();
  }

  @override
  void dispose() {
    _projectPathController.dispose();
    _codeSnippetController.dispose();
    super.dispose();
  }

  void _toggleStep(String title, bool? checked) {
    setState(() {
      if (checked ?? false) {
        _completedSteps.add(title);
      } else {
        _completedSteps.remove(title);
      }
    });
  }

  void _toggleRule(String ruleId, bool? enabled) {
    setState(() {
      if (enabled ?? false) {
        _enabledRuleIds = {..._enabledRuleIds, ruleId};
      } else if (_enabledRuleIds.length > 1) {
        _enabledRuleIds = _enabledRuleIds.difference({ruleId});
      }
      _findings = scanCodeSnippet(
        _codeSnippetController.text,
        filePath: 'local_snippet.dart',
        enabledRuleIds: _enabledRuleIds,
      );
    });
  }

  Future<void> _copyPrompt(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _promptTemplates[_selectedTemplateIndex].prompt),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt 已复制')),
    );
  }

  Future<void> _copyAuditReport(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: formatCodeAuditReport(_findings)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('审计报告已复制')),
    );
  }

  Future<void> _copyAiRequestDraft(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _aiRequestDraft.prompt),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 审计请求草稿已复制')),
    );
  }

  Future<void> _copyFixSuggestionTemplates(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: formatFixSuggestionTemplates(_fixSuggestionTemplates),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('修复建议模板已复制')),
    );
  }

  Future<void> _copySavedReportMarkdown(
    BuildContext context,
    CodeAuditSavedReport report,
  ) async {
    try {
      final markdown = await readCodeAuditReportMarkdown(report);
      await Clipboard.setData(ClipboardData(text: markdown));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${report.fileName} 已复制')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('读取报告失败：$error')),
      );
    }
  }

  Future<void> _copySavedReportPath(
    BuildContext context,
    CodeAuditSavedReport report,
  ) async {
    await Clipboard.setData(ClipboardData(text: report.path));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${report.fileName} 路径已复制')),
    );
  }

  Future<void> _copyReportHistorySummary(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: formatCodeAuditReportHistorySummary(
          _savedReports,
          filterLabel: _reportHistoryFilter.label,
        ),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('审计报告历史总览已复制')),
    );
  }

  Future<void> _deleteSavedReport(
    BuildContext context,
    CodeAuditSavedReport report,
  ) async {
    try {
      String? deletedMarkdown;
      try {
        final reader =
            widget.reportMarkdownReader ?? _defaultReportMarkdownReader;
        deletedMarkdown = await reader(report);
      } catch (_) {
        deletedMarkdown = null;
      }

      final deleter =
          widget.reportHistoryDeleter ?? _defaultReportHistoryDeleter;
      await deleter(report);
      await _loadReportHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${report.fileName} 已删除'),
          action: deletedMarkdown == null
              ? null
              : SnackBarAction(
                  label: '撤销',
                  onPressed: () {
                    unawaited(
                      _restoreDeletedReport(
                        context,
                        report,
                        deletedMarkdown!,
                      ),
                    );
                  },
                ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除报告失败：$error')),
      );
    }
  }

  Future<void> _restoreDeletedReport(
    BuildContext context,
    CodeAuditSavedReport report,
    String markdown,
  ) async {
    try {
      final restorer =
          widget.reportHistoryRestorer ?? _defaultReportHistoryRestorer;
      await restorer(report, markdown);
      await _loadReportHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${report.fileName} 已恢复')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('恢复报告失败：$error')),
      );
    }
  }

  Future<void> _saveAuditReport(BuildContext context) async {
    final file = await saveCodeAuditReport(_findings);
    if (!context.mounted) return;
    setState(() {
      _lastSavedReportPath = file.path;
    });
    await _loadReportHistory();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('审计报告已保存到 ${file.path}')),
    );
  }

  Future<void> _saveProjectAuditReport(BuildContext context) async {
    final report = _projectReport;
    if (report == null) return;
    final file = await saveCodeAuditProjectReport(
      report,
      enabledRules: _enabledRules,
    );
    if (!context.mounted) return;
    setState(() {
      _lastSavedReportPath = file.path;
    });
    await _loadReportHistory();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('项目审计报告已保存到 ${file.path}')),
    );
  }

  Future<void> _loadReportHistory() async {
    try {
      final loader = widget.reportHistoryLoader ?? _defaultReportHistoryLoader;
      final reports = await loader(
        reportType: _reportHistoryFilter.reportType,
      );
      if (!mounted) return;
      setState(() {
        _savedReports = reports;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savedReports = [];
      });
    }
  }

  Future<void> _changeReportHistoryFilter(_ReportHistoryFilter filter) async {
    if (_reportHistoryFilter == filter) return;
    setState(() {
      _reportHistoryFilter = filter;
    });
    await _loadReportHistory();
  }

  void _runLocalScan() {
    setState(() {
      _findings = scanCodeSnippet(
        _codeSnippetController.text,
        filePath: 'local_snippet.dart',
        enabledRuleIds: _enabledRuleIds,
      );
    });
  }

  Future<void> _runProjectScan(BuildContext context) async {
    final projectPath = _projectPathController.text.trim();
    if (projectPath.isEmpty) {
      setState(() {
        _projectScanError = '请输入本地项目路径';
      });
      return;
    }

    setState(() {
      _isProjectScanning = true;
      _projectScanError = null;
    });

    try {
      final report = await scanCodeProject(
        projectPath,
        enabledRuleIds: _enabledRuleIds,
      );
      if (!context.mounted) return;
      setState(() {
        _projectReport = report;
      });
    } catch (error) {
      if (!context.mounted) return;
      setState(() {
        _projectScanError = error.toString();
      });
    } finally {
      if (context.mounted) {
        setState(() {
          _isProjectScanning = false;
        });
      }
    }
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
                title: '编程区',
                subtitle: '面向项目实践、AI 代码审计和修复建议的工作区。',
                onOpenSettings: () {
                  Modular.to.pushNamed('/settings/');
                },
              ),
              const SizedBox(height: 24),
              _AuditProgressPanel(
                progress: _progress,
                completedCount: _completedSteps.length,
                totalCount: codeAuditSteps.length,
              ),
              const SizedBox(height: 16),
              const _CodingAction(
                icon: Icons.account_tree_outlined,
                title: '代码工作区',
                description: '输入本地项目路径后执行多文件规则扫描，形成可交给 AI 复核的上下文。',
              ),
              const _CodingAction(
                icon: Icons.security_outlined,
                title: 'AI 代码审计',
                description: '先用确定性规则找出高风险线索，再用 Prompt 模板补充逻辑审计。',
              ),
              const _CodingAction(
                icon: Icons.fact_check_outlined,
                title: '审计报告',
                description: '按严重级别、文件位置和修复建议展示审计结果。',
              ),
              const SizedBox(height: 12),
              _AuditChecklist(
                completedSteps: _completedSteps,
                onChanged: _toggleStep,
              ),
              const SizedBox(height: 16),
              _RuleConfigPanel(
                enabledRuleIds: _enabledRuleIds,
                onChanged: _toggleRule,
              ),
              const SizedBox(height: 16),
              _ProjectScanPanel(
                controller: _projectPathController,
                report: _projectReport,
                isScanning: _isProjectScanning,
                error: _projectScanError,
                onScan: () => _runProjectScan(context),
                onSaveReport: () => _saveProjectAuditReport(context),
              ),
              const SizedBox(height: 16),
              _LocalCodeScanPanel(
                controller: _codeSnippetController,
                findings: _findings,
                onScan: _runLocalScan,
                onCopyReport: () => _copyAuditReport(context),
                onSaveReport: () => _saveAuditReport(context),
                savedReportPath: _lastSavedReportPath,
              ),
              const SizedBox(height: 16),
              _AiAuditRequestPanel(
                draft: _aiRequestDraft,
                onCopy: () => _copyAiRequestDraft(context),
              ),
              const SizedBox(height: 16),
              _FixSuggestionTemplatePanel(
                templates: _fixSuggestionTemplates,
                onCopy: () => _copyFixSuggestionTemplates(context),
              ),
              const SizedBox(height: 16),
              _ReportHistoryPanel(
                reports: _savedReports,
                selectedFilter: _reportHistoryFilter,
                onFilterChanged: _changeReportHistoryFilter,
                onCopyMarkdown: (report) =>
                    _copySavedReportMarkdown(context, report),
                onCopyPath: (report) => _copySavedReportPath(context, report),
                onCopySummary: () => _copyReportHistorySummary(context),
                onDelete: (report) => _deleteSavedReport(context, report),
              ),
              const SizedBox(height: 16),
              _PromptTemplatePanel(
                templates: _promptTemplates,
                selectedIndex: _selectedTemplateIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedTemplateIndex = index;
                  });
                },
                onCopy: () => _copyPrompt(context),
              ),
              const SizedBox(height: 16),
              const CodeAuditPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectScanPanel extends StatelessWidget {
  const _ProjectScanPanel({
    required this.controller,
    required this.report,
    required this.isScanning,
    required this.error,
    required this.onScan,
    required this.onSaveReport,
  });

  final TextEditingController controller;
  final CodeAuditProjectReport? report;
  final bool isScanning;
  final String? error;
  final VoidCallback onScan;
  final VoidCallback onSaveReport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentReport = report;
    final previewFindings = currentReport == null
        ? <CodeAuditFinding>[]
        : currentReport.findings.take(3).toList();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.folder_open_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        '本地项目审计',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed:
                                currentReport == null ? null : onSaveReport,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('保存项目报告'),
                          ),
                          FilledButton.icon(
                            onPressed: isScanning ? null : onScan,
                            icon: isScanning
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.manage_search),
                            label: Text(isScanning ? '扫描中' : '扫描项目'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '本地项目路径',
                hintText: r'D:\SelfStudy\everyone_is_programer\Kazumi',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => onScan(),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
            if (currentReport != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AuditMetricChip(
                    icon: Icons.description_outlined,
                    label: '已扫描 ${currentReport.scannedFileCount} 个文件',
                  ),
                  _AuditMetricChip(
                    icon: Icons.report_problem_outlined,
                    label: '发现 ${currentReport.findings.length} 个风险',
                  ),
                  _AuditMetricChip(
                    icon: Icons.block_outlined,
                    label: '跳过 ${currentReport.skippedFileCount} 个文件',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (previewFindings.isEmpty)
                const Text('当前项目未命中本地规则。')
              else ...[
                Text(
                  '高优先级发现',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                for (final finding in previewFindings)
                  _FindingTile(finding: finding),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RuleConfigPanel extends StatelessWidget {
  const _RuleConfigPanel({
    required this.enabledRuleIds,
    required this.onChanged,
  });

  final Set<String> enabledRuleIds;
  final void Function(String ruleId, bool? enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                const Icon(Icons.tune_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '规则配置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                    '${enabledRuleIds.length} / ${localCodeAuditRules.length}'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('选择本次片段扫描和项目扫描要启用的本地规则。'),
            const SizedBox(height: 8),
            for (final rule in localCodeAuditRules)
              CheckboxListTile(
                value: enabledRuleIds.contains(rule.id),
                onChanged: (value) => onChanged(rule.id, value),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(rule.title),
                subtitle: Text('${rule.severity.label} · ${rule.suggestion}'),
                secondary: Icon(
                  Icons.rule_outlined,
                  color: rule.severity.color(colorScheme),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuditMetricChip extends StatelessWidget {
  const _AuditMetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _LocalCodeScanPanel extends StatelessWidget {
  const _LocalCodeScanPanel({
    required this.controller,
    required this.findings,
    required this.onScan,
    required this.onCopyReport,
    required this.onSaveReport,
    required this.savedReportPath,
  });

  final TextEditingController controller;
  final List<CodeAuditFinding> findings;
  final VoidCallback onScan;
  final VoidCallback onCopyReport;
  final VoidCallback onSaveReport;
  final String? savedReportPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.rule_folder_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        '本地规则扫描',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onCopyReport,
                            icon: const Icon(Icons.copy),
                            label: const Text('复制报告'),
                          ),
                          OutlinedButton.icon(
                            onPressed: onSaveReport,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('保存报告'),
                          ),
                          FilledButton.icon(
                            onPressed: onScan,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('运行扫描'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: '粘贴要检查的代码片段',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('发现 ${findings.length} 个风险'),
            const SizedBox(height: 8),
            if (findings.isEmpty)
              const Text('未命中本地规则。')
            else
              for (final finding in findings) _FindingTile(finding: finding),
            if (savedReportPath != null) ...[
              const SizedBox(height: 12),
              Text(
                '最近保存：$savedReportPath',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportHistoryPanel extends StatelessWidget {
  const _ReportHistoryPanel({
    required this.reports,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onCopyMarkdown,
    required this.onCopyPath,
    required this.onCopySummary,
    required this.onDelete,
  });

  final List<CodeAuditSavedReport> reports;
  final _ReportHistoryFilter selectedFilter;
  final ValueChanged<_ReportHistoryFilter> onFilterChanged;
  final ValueChanged<CodeAuditSavedReport> onCopyMarkdown;
  final ValueChanged<CodeAuditSavedReport> onCopyPath;
  final VoidCallback onCopySummary;
  final ValueChanged<CodeAuditSavedReport> onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    '审计报告历史',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: '复制历史总览',
                  onPressed: onCopySummary,
                  icon: const Icon(Icons.summarize_outlined),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<_ReportHistoryFilter>(
                showSelectedIcon: false,
                segments: [
                  for (final filter in _ReportHistoryFilter.values)
                    ButtonSegment<_ReportHistoryFilter>(
                      value: filter,
                      label: Text(filter.label),
                    ),
                ],
                selected: {selectedFilter},
                onSelectionChanged: (selection) {
                  onFilterChanged(selection.single);
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatCodeAuditReportHistoryFilterSummary(reports),
              key: const ValueKey('code-audit-report-history-filter-summary'),
            ),
            const SizedBox(height: 10),
            if (reports.isEmpty)
              Text(selectedFilter.emptyMessage)
            else
              for (final report in reports)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(report.fileName),
                  subtitle: Text(
                    '${report.reportType.label} · '
                    '${_formatReportTimestamp(report.modifiedAt)} · '
                    '${_formatReportSize(report.sizeBytes)} · ${report.path}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: '复制报告',
                        onPressed: () => onCopyMarkdown(report),
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        tooltip: '复制路径',
                        onPressed: () => onCopyPath(report),
                        icon: const Icon(Icons.link_outlined),
                      ),
                      IconButton(
                        tooltip: '删除报告',
                        onPressed: () => onDelete(report),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AiAuditRequestPanel extends StatelessWidget {
  const _AiAuditRequestPanel({
    required this.draft,
    required this.onCopy,
  });

  final CodeAuditAiRequestDraft draft;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.hub_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        'AI 审计接口占位',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy),
                        label: const Text('复制 AI 请求草稿'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(draft.contextSummary),
            const SizedBox(height: 4),
            Text(draft.riskDigest),
            const SizedBox(height: 4),
            Text(draft.locationDigest),
            const SizedBox(height: 4),
            Text(draft.ruleDigest),
            const SizedBox(height: 10),
            Text(
              '当前不会调用远程模型；复制草稿后可交给外部 AI 复核，后续可替换为真实接口。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SelectableText(
              draft.prompt,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _FixSuggestionTemplatePanel extends StatelessWidget {
  const _FixSuggestionTemplatePanel({
    required this.templates,
    required this.onCopy,
  });

  final List<CodeAuditFixSuggestionTemplate> templates;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstTemplate = templates.first;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.build_circle_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        '修复建议模板',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy),
                        label: const Text('复制修复模板'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('已生成 ${templates.length} 份模板，优先处理：${firstTemplate.location}'),
            const SizedBox(height: 10),
            Text(
              '模板包含风险定位、触发证据、最小修复步骤和验证清单，可直接放入报告或任务说明。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SelectableText(
              firstTemplate.markdown,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatReportTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatReportSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}

class _FindingTile extends StatelessWidget {
  const _FindingTile({required this.finding});

  final CodeAuditFinding finding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = finding.rule.severity.color(colorScheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      finding.rule.severity.label,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding.rule.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('${finding.filePath}:${finding.lineNumber}'),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(finding.lineText),
              const SizedBox(height: 8),
              Text(finding.rule.description),
              const SizedBox(height: 4),
              Text('建议：${finding.rule.suggestion}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptTemplate {
  const _PromptTemplate({
    required this.title,
    required this.description,
    required this.prompt,
  });

  final String title;
  final String description;
  final String prompt;
}

class _AuditProgressPanel extends StatelessWidget {
  const _AuditProgressPanel({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '审计准备进度',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text('$completedCount / $totalCount'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            const Text('先完成确定性检查，再把上下文交给 AI 复核。'),
          ],
        ),
      ),
    );
  }
}

class _AuditChecklist extends StatelessWidget {
  const _AuditChecklist({
    required this.completedSteps,
    required this.onChanged,
  });

  final Set<String> completedSteps;
  final void Function(String title, bool? checked) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '审计清单',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (final step in codeAuditSteps)
          CheckboxListTile(
            value: completedSteps.contains(step.title),
            onChanged: (value) => onChanged(step.title, value),
            secondary: Icon(step.icon),
            title: Text(step.title),
            subtitle: Text(step.description),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
      ],
    );
  }
}

class _PromptTemplatePanel extends StatelessWidget {
  const _PromptTemplatePanel({
    required this.templates,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCopy,
  });

  final List<_PromptTemplate> templates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final selected = templates[selectedIndex];
    final colorScheme = Theme.of(context).colorScheme;

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
            Text(
              'Prompt 模板',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                segments: [
                  for (var i = 0; i < templates.length; i++)
                    ButtonSegment<int>(
                      value: i,
                      label: Text(templates[i].title),
                    ),
                ],
                selected: {selectedIndex},
                onSelectionChanged: (selection) => onSelected(selection.first),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              selected.description,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            SelectableText(selected.prompt),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              label: const Text('复制 Prompt'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodingAction extends StatelessWidget {
  const _CodingAction({
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
