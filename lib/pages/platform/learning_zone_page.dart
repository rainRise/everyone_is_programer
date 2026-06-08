import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';
import 'package:kazumi/pages/platform/platform_learning_progress_repository.dart';
import 'package:kazumi/pages/platform/platform_page_header.dart';
import 'package:kazumi/pages/platform/platform_recommendation_catalog.dart';
import 'package:kazumi/pages/platform/platform_zone_workflow.dart';
import 'package:kazumi/pages/platform/rag_library_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class LearningZonePage extends StatefulWidget {
  const LearningZonePage({
    super.key,
    this.progressRepository = const PlatformLearningProgressRepository(),
  });

  final PlatformLearningProgressRepository progressRepository;

  @override
  State<LearningZonePage> createState() => _LearningZonePageState();
}

class _LearningZonePageState extends State<LearningZonePage> {
  String _keyword = '';
  PlatformResourceType? _selectedType;
  PlatformLearningGoal _selectedGoal = PlatformLearningGoal.rag;
  final Set<String> _completedResourceIds = {};

  List<PlatformLearningResource> get _filteredResources {
    return allPlatformLearningResources
        .where((resource) => resource.matches(_keyword, _selectedType))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLearningProgress();
  }

  void _selectType(PlatformResourceType? type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _updateKeyword(String value) {
    setState(() {
      _keyword = value;
    });
  }

  void _selectGoal(PlatformLearningGoal goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  Future<void> _loadLearningProgress() async {
    final completedIds =
        await widget.progressRepository.loadCompletedResourceIds();
    if (!mounted) return;
    setState(() {
      _completedResourceIds
        ..clear()
        ..addAll(completedIds);
    });
  }

  Future<void> _toggleResourceCompleted(
    PlatformLearningResource resource,
    bool completed,
  ) async {
    setState(() {
      if (completed) {
        _completedResourceIds.add(resource.id);
      } else {
        _completedResourceIds.remove(resource.id);
      }
    });
    await widget.progressRepository.saveCompletedResourceIds(
      _completedResourceIds,
    );
  }

  Future<void> _copyLearningProgressSummary() async {
    await Clipboard.setData(
      ClipboardData(
        text: buildLearningProgressMarkdown(
          completedResourceIds: _completedResourceIds,
          resources: allPlatformLearningResources,
        ),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('学习进度复盘已复制')),
      );
  }

  Future<void> _clearLearningProgress() async {
    if (_completedResourceIds.isEmpty) return;
    final snapshot = Set<String>.of(_completedResourceIds);
    setState(_completedResourceIds.clear);
    await widget.progressRepository.saveCompletedResourceIds(
      _completedResourceIds,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('学习进度已清空'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () {
              unawaited(_restoreLearningProgress(snapshot));
            },
          ),
        ),
      );
  }

  Future<void> _restoreLearningProgress(
      Set<String> completedResourceIds) async {
    setState(() {
      _completedResourceIds
        ..clear()
        ..addAll(completedResourceIds);
    });
    await widget.progressRepository.saveCompletedResourceIds(
      _completedResourceIds,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('学习进度已恢复')),
      );
  }

  Future<void> _copyFilteredResourceCatalog(
    List<PlatformLearningResource> resources,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: buildLearningResourceCatalogMarkdown(
          resources: resources,
          completedResourceIds: _completedResourceIds,
          keyword: _keyword,
          selectedType: _selectedType,
        ),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('学习资源清单已复制')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredResources = _filteredResources;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformPageHeader(
                title: '资料学习区',
                subtitle: '集中管理程序员学习资料、免费资源、本地 RAG 和算法模型知识。',
                onOpenSettings: () {
                  Modular.to.pushNamed('/settings/');
                },
              ),
              const SizedBox(height: 24),
              const _PlatformWorkflowPanel(),
              const SizedBox(height: 16),
              const _LearningPathPanel(),
              const SizedBox(height: 16),
              _LearningProgressPanel(
                completedCount: _completedResourceIds.length,
                totalCount: allPlatformLearningResources.length,
                onCopyProgress: _copyLearningProgressSummary,
                onClearProgress: _completedResourceIds.isEmpty
                    ? null
                    : _clearLearningProgress,
              ),
              const SizedBox(height: 16),
              _LearningSearchBar(
                selectedType: _selectedType,
                onKeywordChanged: _updateKeyword,
                onTypeSelected: _selectType,
              ),
              const SizedBox(height: 16),
              _RecommendationPanel(
                selectedGoal: _selectedGoal,
                completedResourceIds: _completedResourceIds,
                onGoalSelected: _selectGoal,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '资源目录',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: '复制当前资源清单',
                    onPressed: () => _copyFilteredResourceCatalog(
                      filteredResources,
                    ),
                    icon: const Icon(Icons.copy_all_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (filteredResources.isEmpty)
                const _EmptyResourceResult()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 2 : 1;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final resource in filteredResources)
                          SizedBox(
                            width: columns == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 12) / 2,
                            child: _ResourceCard(
                              key: ValueKey('resource-${resource.id}'),
                              resource: resource,
                              isCompleted:
                                  _completedResourceIds.contains(resource.id),
                              onCompletedChanged: (completed) =>
                                  _toggleResourceCompleted(
                                resource,
                                completed,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 28),
              Text(
                '能力地图',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              for (final section in platformLearningSections)
                _LearningItem(
                  icon: section.icon,
                  title: section.title,
                  description: section.description,
                  resources: section.resources,
                ),
              const SizedBox(height: 12),
              const RagLibraryPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformWorkflowPanel extends StatelessWidget {
  const _PlatformWorkflowPanel();

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
                const Icon(Icons.route_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '三大区协作流',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '把资料输入、编码实践和节奏恢复连成一轮可复盘的学习循环。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 840 ? 3 : 1;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final stage in platformZoneWorkflow)
                      SizedBox(
                        width: columns == 1
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 24) / 3,
                        child: _WorkflowStageCard(stage: stage),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowStageCard extends StatelessWidget {
  const _WorkflowStageCard({required this.stage});

  final PlatformZoneWorkflowStage stage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(stage.icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              stage.zoneLabel,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(stage.description),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final output in stage.outputs)
                  Chip(
                    label: Text(output),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningProgressPanel extends StatelessWidget {
  const _LearningProgressPanel({
    required this.completedCount,
    required this.totalCount,
    required this.onCopyProgress,
    required this.onClearProgress,
  });

  final int completedCount;
  final int totalCount;
  final VoidCallback onCopyProgress;
  final VoidCallback? onClearProgress;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '学习进度',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text('$completedCount / $totalCount'),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '复制学习进度复盘',
                  onPressed: onCopyProgress,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: '清空学习进度',
                  onPressed: onClearProgress,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({
    required this.selectedGoal,
    required this.completedResourceIds,
    required this.onGoalSelected,
  });

  final PlatformLearningGoal selectedGoal;
  final Set<String> completedResourceIds;
  final ValueChanged<PlatformLearningGoal> onGoalSelected;

  Future<void> _copyRecommendations(
    BuildContext context,
    List<RecommendedLearningResource> recommendations,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: buildLearningRecommendationMarkdown(
          goal: selectedGoal,
          recommendations: recommendations,
          completedResourceIds: completedResourceIds,
        ),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('学习推荐清单已复制')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recommendations = recommendPlatformResources(
      selectedGoal,
      completedResourceIds: completedResourceIds,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recommend_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '推荐算法原型',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: '复制学习推荐清单',
                  onPressed: () => _copyRecommendations(
                    context,
                    recommendations,
                  ),
                  icon: const Icon(Icons.copy_all_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '用本地标签和资源类型做候选召回与排序，后续可替换为真实推荐模型。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final goal in PlatformLearningGoal.values)
                  ChoiceChip(
                    key: ValueKey('learning-goal-${goal.name}'),
                    avatar: Icon(goal.icon, size: 18),
                    label: Text(goal.label),
                    selected: selectedGoal == goal,
                    onSelected: (_) => onGoalSelected(goal),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stage in recommendationPipelineStages)
                  Chip(
                    label: Text(stage),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final stage in recommendationPipelineStages)
              _RecommendationStageTile(
                title: stage,
                description: recommendationPipelineDescriptions[stage] ?? '',
              ),
            const SizedBox(height: 4),
            if (recommendations.isEmpty)
              const _RecommendationEmptyState()
            else
              for (final recommendation in recommendations)
                _RecommendationTile(
                  key: ValueKey(
                    'recommendation-${recommendation.resource.id}',
                  ),
                  recommendation: recommendation,
                ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationEmptyState extends StatelessWidget {
  const _RecommendationEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.task_alt_outlined, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '当前目标下的推荐资源已完成，可以切换学习目标或复制推荐清单做复盘。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationStageTile extends StatelessWidget {
  const _RecommendationStageTile({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right_alt,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title：',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({super.key, required this.recommendation});

  final RecommendedLearningResource recommendation;

  @override
  Widget build(BuildContext context) {
    final resource = recommendation.resource;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(resource.type.icon, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(recommendation.reason),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathPanel extends StatelessWidget {
  const _LearningPathPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日建议路径',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const _PathStep(
              index: '1',
              title: '看一节视频',
              detail: '用 CS50 或 FreeCodeCamp 建立基础概念。',
            ),
            const _PathStep(
              index: '2',
              title: '沉淀到本地 RAG',
              detail: '把课程笔记、PDF 和代码片段整理成可检索资料。',
            ),
            const _PathStep(
              index: '3',
              title: '学习推荐与排序',
              detail: '从 BM25 到 Embedding，再进入推荐排序模型。',
            ),
          ],
        ),
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.index,
    required this.title,
    required this.detail,
  });

  final String index;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: colorScheme.primary,
            child: Text(
              index,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningSearchBar extends StatelessWidget {
  const _LearningSearchBar({
    required this.selectedType,
    required this.onKeywordChanged,
    required this.onTypeSelected,
  });

  final PlatformResourceType? selectedType;
  final ValueChanged<String> onKeywordChanged;
  final ValueChanged<PlatformResourceType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onKeywordChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: '搜索学习资料、RAG、Skill、MCP 或模型',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('全部'),
              selected: selectedType == null,
              onSelected: (_) => onTypeSelected(null),
            ),
            for (final type in PlatformResourceType.values)
              ChoiceChip(
                avatar: Icon(type.icon, size: 18),
                label: Text(type.label),
                selected: selectedType == type,
                onSelected: (_) => onTypeSelected(type),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    super.key,
    required this.resource,
    required this.isCompleted,
    required this.onCompletedChanged,
  });

  final PlatformLearningResource resource;
  final bool isCompleted;
  final ValueChanged<bool> onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(resource.type.icon, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    resource.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(
                  label: Text(resource.level),
                  visualDensity: VisualDensity.compact,
                ),
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) => onCompletedChanged(value ?? false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(resource.description),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in resource.tags)
                  Text(
                    '#$tag',
                    style: TextStyle(color: colorScheme.primary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _showResourceAction(context, resource),
              icon: const Icon(Icons.open_in_new),
              label: Text(resource.actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showResourceAction(
    BuildContext context,
    PlatformLearningResource resource,
  ) {
    final guide = resource.guide;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(resource.description),
                if (guide != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    '内置指南',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(guide.overview),
                  const SizedBox(height: 10),
                  for (var i = 0; i < guide.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}.'),
                          const SizedBox(width: 8),
                          Expanded(child: Text(guide.steps[i])),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final output in guide.outputs)
                        Chip(
                          avatar: const Icon(Icons.check_circle_outline),
                          label: Text(output),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SelectableText('入口：${resource.url}'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: resource.isExternalUrl
                          ? () => _openResourceUrl(context, resource)
                          : null,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('打开链接'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyResourceUrl(context, resource),
                      icon: const Icon(Icons.copy),
                      label: const Text('复制入口'),
                    ),
                    if (guide != null)
                      OutlinedButton.icon(
                        onPressed: () => _copyResourceGuide(context, resource),
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text('复制指南'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openResourceUrl(
    BuildContext context,
    PlatformLearningResource resource,
  ) async {
    final uri = Uri.tryParse(resource.url);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开该链接')),
      );
    }
  }

  Future<void> _copyResourceUrl(
    BuildContext context,
    PlatformLearningResource resource,
  ) async {
    await Clipboard.setData(ClipboardData(text: resource.url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('资源入口已复制')),
    );
  }

  Future<void> _copyResourceGuide(
    BuildContext context,
    PlatformLearningResource resource,
  ) async {
    final guide = resource.guide;
    if (guide == null) return;
    await Clipboard.setData(
      ClipboardData(text: guide.toClipboardText(resource)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('学习指南已复制')),
    );
  }
}

class _EmptyResourceResult extends StatelessWidget {
  const _EmptyResourceResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          '没有匹配的学习资源',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _LearningItem extends StatelessWidget {
  const _LearningItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.resources,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<PlatformLearningResource> resources;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title)),
                ],
              ),
              const SizedBox(height: 6),
              Text(description),
              const SizedBox(height: 10),
              for (final resource in resources)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Text('•'),
                      const SizedBox(width: 8),
                      Text(resource.title),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
