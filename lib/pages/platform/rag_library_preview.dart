import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/pages/platform/platform_rag_catalog.dart';
import 'package:kazumi/pages/platform/platform_rag_repository.dart';

class RagLibraryPreview extends StatefulWidget {
  const RagLibraryPreview({
    super.key,
    this.repository = const PlatformRagRepository(),
  });

  final PlatformRagRepository repository;

  @override
  State<RagLibraryPreview> createState() => _RagLibraryPreviewState();
}

class _RagLibraryPreviewState extends State<RagLibraryPreview> {
  String _query = 'RAG 推荐';
  late final TextEditingController _queryController;
  final List<LocalRagDocument> _customDocuments = [];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: _query);
    _loadImportedDocuments();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = searchLocalRagDocuments(
      _query,
      extraDocuments: _customDocuments,
    );
    final answerDraft = buildLocalRagAnswer(
      _query,
      extraDocuments: _customDocuments,
    );
    final retrievalPlan = buildLocalRagRetrievalPlan(_query);
    final studyNote = buildLocalRagStudyNote(
      plan: retrievalPlan,
      draft: answerDraft,
    );
    final studyNoteDocument = buildLocalRagStudyNoteDocument(
      plan: retrievalPlan,
      draft: answerDraft,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本地 RAG 检索',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _queryController,
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.manage_search_outlined),
            labelText: '输入关键词，例如 RAG、MCP、推荐算法、代码审计',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _RagRetrievalPlanPanel(plan: retrievalPlan),
        const SizedBox(height: 12),
        _RagAnswerDraftPanel(
          draft: answerDraft,
          studyNote: studyNote,
          onSaveStudyNote: () => _saveStudyNote(studyNoteDocument),
        ),
        const SizedBox(height: 12),
        _RagImportPanel(
          importedCount: _customDocuments.length,
          onAddDocument: _showAddDocumentSheet,
          onCopyLibrarySummary:
              _customDocuments.isEmpty ? null : _copyImportedLibrarySummary,
        ),
        if (_customDocuments.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final document in _customDocuments)
            _ImportedDocumentTile(
              document: document,
              onFocus: () => _focusImportedDocument(document),
              onCopy: () => _copyImportedDocument(document),
              onDelete: () => _removeDocument(document),
            ),
        ],
        const SizedBox(height: 12),
        for (final result in results) _RagSearchResultTile(result: result),
        if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('没有检索到匹配的本地资料'),
          ),
        const SizedBox(height: 16),
        Text(
          'RAG 资料包',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (final source in localRagSources) _RagSourceTile(source: source),
      ],
    );
  }

  Future<void> _showAddDocumentSheet() async {
    final document = await showModalBottomSheet<LocalRagDocument>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _AddRagDocumentSheet(),
    );

    if (document == null) return;
    final importResult = _upsertImportedDocument(document);
    await _saveImportedDocuments();
    if (!mounted) return;
    if (importResult.isDuplicate) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('RAG 资料已存在，已聚焦到资料库')),
        );
    }
  }

  _DocumentImportResult _upsertImportedDocument(
    LocalRagDocument document, {
    bool matchContent = true,
  }) {
    final normalizedDocument = document.normalized();
    final existingDocument = _findExistingDocument(
      normalizedDocument,
      matchContent: matchContent,
    );

    setState(() {
      if (existingDocument == null) {
        _customDocuments.insert(0, normalizedDocument);
        _focusDocument(normalizedDocument);
      } else {
        _customDocuments
          ..remove(existingDocument)
          ..insert(0, existingDocument);
        _focusDocument(existingDocument);
      }
    });
    return _DocumentImportResult(isDuplicate: existingDocument != null);
  }

  Future<void> _loadImportedDocuments() async {
    final documents = await widget.repository.loadDocuments();
    if (!mounted) return;
    setState(() {
      _customDocuments
        ..clear()
        ..addAll(documents);
    });
  }

  Future<void> _saveImportedDocuments() async {
    await widget.repository.saveDocuments(_customDocuments);
  }

  void _focusImportedDocument(LocalRagDocument document) {
    setState(() {
      _focusDocument(document);
    });
  }

  Future<void> _copyImportedDocument(LocalRagDocument document) async {
    await Clipboard.setData(
      ClipboardData(text: _buildImportedDocumentMarkdown(document)),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('已复制 ${document.title}')),
      );
  }

  Future<void> _copyImportedLibrarySummary() async {
    await Clipboard.setData(
      ClipboardData(text: buildImportedRagLibraryMarkdown(_customDocuments)),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('RAG 资料库总览已复制')),
      );
  }

  Future<void> _removeDocument(LocalRagDocument document) async {
    final removedIndex = _customDocuments.indexOf(document);
    if (removedIndex < 0) return;
    setState(() {
      _customDocuments.removeAt(removedIndex);
    });
    await _saveImportedDocuments();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('已删除 ${document.title}'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () => _restoreRemovedDocument(document, removedIndex),
          ),
        ),
      );
  }

  Future<void> _restoreRemovedDocument(
    LocalRagDocument document,
    int removedIndex,
  ) async {
    setState(() {
      final insertIndex = removedIndex > _customDocuments.length
          ? _customDocuments.length
          : removedIndex;
      _customDocuments.insert(insertIndex, document);
      _focusDocument(document);
    });
    await _saveImportedDocuments();
  }

  Future<void> _saveStudyNote(LocalRagDocument document) async {
    final importResult = _upsertImportedDocument(document, matchContent: false);
    await _saveImportedDocuments();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            importResult.isDuplicate
                ? 'RAG 学习笔记已存在，已聚焦到资料库'
                : 'RAG 学习笔记已沉淀到资料库',
          ),
        ),
      );
  }

  LocalRagDocument? _findExistingDocument(
    LocalRagDocument document, {
    required bool matchContent,
  }) {
    for (final existing in _customDocuments) {
      final normalizedExisting = existing.normalized();
      if (normalizedExisting.source != document.source) continue;
      if (normalizedExisting.title != document.title) continue;
      if (!matchContent || normalizedExisting.content == document.content) {
        return existing;
      }
    }
    return null;
  }

  void _focusDocument(LocalRagDocument document) {
    _query = document.title;
    _queryController.text = document.title;
    _queryController.selection = TextSelection.collapsed(
      offset: _queryController.text.length,
    );
  }
}

String buildImportedRagLibraryMarkdown(
  Iterable<LocalRagDocument> documents, {
  DateTime? generatedAt,
}) {
  final normalizedDocuments = documents
      .map((document) => document.normalized())
      .where((document) => document.title.isNotEmpty)
      .where((document) => document.content.isNotEmpty)
      .toList(growable: false);
  final generatedTime = generatedAt ?? DateTime.now();
  final sourceCounts = <String, int>{};
  final tagCounts = <String, int>{};

  for (final document in normalizedDocuments) {
    sourceCounts.update(
      document.source,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    for (final tag in document.tags) {
      tagCounts.update(tag, (count) => count + 1, ifAbsent: () => 1);
    }
  }

  final buffer = StringBuffer()
    ..writeln('# RAG 资料库总览')
    ..writeln()
    ..writeln('- 生成时间：${_formatRagLibraryTimestamp(generatedTime)}')
    ..writeln('- 资料数量：${normalizedDocuments.length}');

  if (normalizedDocuments.isEmpty) {
    buffer
      ..writeln()
      ..writeln('暂无已导入的本地 RAG 资料。');
    return buffer.toString().trimRight();
  }

  buffer
    ..writeln('- 来源分布：${_formatCountMap(sourceCounts)}')
    ..writeln('- 标签分布：${_formatCountMap(tagCounts)}')
    ..writeln()
    ..writeln('## 资料清单');

  for (var index = 0; index < normalizedDocuments.length; index++) {
    final document = normalizedDocuments[index];
    buffer
      ..writeln()
      ..writeln('${index + 1}. ${document.title}')
      ..writeln('   - 来源：${document.source}')
      ..writeln('   - 标签：${document.tags.join(', ')}')
      ..writeln(
          '   - 摘要：${document.summary.isEmpty ? '无摘要' : document.summary}');
  }

  return buffer.toString().trimRight();
}

String _buildImportedDocumentMarkdown(LocalRagDocument document) {
  final normalizedDocument = document.normalized();
  return '''
# ${normalizedDocument.title}

- 来源：${normalizedDocument.source}
- 标签：${normalizedDocument.tags.join(', ')}

## 摘要

${normalizedDocument.summary}

## 正文

${normalizedDocument.content}
'''
      .trim();
}

String _formatRagLibraryTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatCountMap(Map<String, int> counts) {
  if (counts.isEmpty) return '无';
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return entries.map((entry) => '${entry.key} ${entry.value}').join('，');
}

String _buildSearchResultMarkdown(RagSearchResult result) {
  final document = result.document.normalized();
  final matchedFields =
      result.matchedFields.isEmpty ? '无' : result.matchedFields.join(', ');
  final matchedTags =
      result.matchedTags.isEmpty ? '无' : result.matchedTags.join(', ');

  return '''
# 检索片段：${document.title}

- 来源：${document.source}
- 分数：${result.score}
- 片段：${result.chunk.label}
- 命中字段：$matchedFields
- 命中标签：$matchedTags
- 排序原因：${result.rankingReason}

## 摘要

${document.summary}

## 证据

${result.excerpt}

## 原文片段

${result.chunk.text}
'''
      .trim();
}

String _buildRetrievalPlanMarkdown(LocalRagRetrievalPlan plan) {
  final query = plan.query.isEmpty ? '未输入' : plan.query;
  final tokens = plan.tokens.isEmpty ? '无' : plan.tokens.join(', ');

  return '''
# RAG 检索计划

- 查询：$query
- 意图：${plan.intentLabel}
- 策略：${plan.retrievalStrategy}
- 候选数量：${plan.candidateLimit}
- 上下文数量：${plan.contextLimit}
- 证据预算：${plan.evidenceBudget}
- 关键词：$tokens
'''
      .trim();
}

String _buildAnswerDraftMarkdown(LocalRagAnswerDraft draft) {
  final query = draft.query.isEmpty ? '未输入' : draft.query;
  final citations = draft.contexts.isEmpty
      ? '无'
      : draft.contexts
          .map(
            (result) =>
                '- ${result.document.title}｜${result.document.source}｜${result.chunk.label}｜score ${result.score}',
          )
          .join('\n');

  return '''
# RAG 回答草稿

- 问题：$query
- 引用数量：${draft.contexts.length}

## 回答

${draft.answer}

## 引用摘要

$citations
'''
      .trim();
}

class _DocumentImportResult {
  const _DocumentImportResult({required this.isDuplicate});

  final bool isDuplicate;
}

class _RagRetrievalPlanPanel extends StatelessWidget {
  const _RagRetrievalPlanPanel({required this.plan});

  final LocalRagRetrievalPlan plan;

  Future<void> _copyRetrievalPlan(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _buildRetrievalPlanMarkdown(plan)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('RAG 检索计划已复制')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schema_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RAG 检索计划',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(
                  label: Text(plan.intentLabel),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '复制检索计划',
                  onPressed: () => _copyRetrievalPlan(context),
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plan.retrievalStrategy),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.manage_search_outlined, size: 18),
                  label: Text('候选 ${plan.candidateLimit}'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: const Icon(Icons.article_outlined, size: 18),
                  label: Text('上下文 ${plan.contextLimit}'),
                  visualDensity: VisualDensity.compact,
                ),
                for (final token in plan.tokens.take(5))
                  Chip(
                    label: Text(token),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              plan.evidenceBudget,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RagAnswerDraftPanel extends StatelessWidget {
  const _RagAnswerDraftPanel({
    required this.draft,
    required this.studyNote,
    required this.onSaveStudyNote,
  });

  final LocalRagAnswerDraft draft;
  final String studyNote;
  final VoidCallback onSaveStudyNote;

  Future<void> _copyStudyNote(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: studyNote));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RAG 学习笔记已复制')),
    );
  }

  Future<void> _copyAnswerDraft(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _buildAnswerDraftMarkdown(draft)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('RAG 回答草稿已复制')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RAG 回答草稿',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (draft.hasContext)
                  Chip(
                    label: Text('引用 ${draft.contexts.length} 条'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(draft.answer),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onSaveStudyNote,
                  icon: const Icon(Icons.library_add_outlined),
                  label: const Text('沉淀到 RAG 资料库'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _copyAnswerDraft(context),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('复制回答草稿'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _copyStudyNote(context),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('复制 RAG 学习笔记'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RagImportPanel extends StatelessWidget {
  const _RagImportPanel({
    required this.importedCount,
    required this.onAddDocument,
    required this.onCopyLibrarySummary,
  });

  final int importedCount;
  final VoidCallback onAddDocument;
  final VoidCallback? onCopyLibrarySummary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.library_add_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '已导入 $importedCount 条本地资料，导入后会立即参与检索。',
              ),
            ),
            IconButton(
              tooltip: '复制资料库总览',
              onPressed: onCopyLibrarySummary,
              icon: const Icon(Icons.summarize_outlined),
            ),
            FilledButton.tonalIcon(
              onPressed: onAddDocument,
              icon: const Icon(Icons.add),
              label: const Text('添加资料'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportedDocumentTile extends StatelessWidget {
  const _ImportedDocumentTile({
    required this.document,
    required this.onFocus,
    required this.onCopy,
    required this.onDelete,
  });

  final LocalRagDocument document;
  final VoidCallback onFocus;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final visibleTags = document.tags.take(4).toList();
    final hiddenTags = document.tags.skip(visibleTags.length).toList();
    final hiddenTagCount = document.tags.length - visibleTags.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onFocus,
        leading: const Icon(Icons.note_add_outlined),
        title: Text(document.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document.summary),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(document.source),
                  visualDensity: VisualDensity.compact,
                ),
                for (final tag in visibleTags)
                  Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                  ),
                if (hiddenTagCount > 0)
                  Tooltip(
                    message: hiddenTags.join(', '),
                    child: Chip(
                      label: Text('+$hiddenTagCount'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '复制资料',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: '删除资料',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.55),
      ),
    );
  }
}

class _AddRagDocumentSheet extends StatefulWidget {
  const _AddRagDocumentSheet();

  @override
  State<_AddRagDocumentSheet> createState() => _AddRagDocumentSheetState();
}

class _AddRagDocumentSheetState extends State<_AddRagDocumentSheet> {
  final _titleController = TextEditingController();
  final _sourceController = TextEditingController(text: '用户导入');
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController(text: '本地资料');

  @override
  void dispose() {
    _titleController.dispose();
    _sourceController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题和内容不能为空')),
      );
      return;
    }

    final summary = _summaryController.text.trim().isEmpty
        ? (content.length > 48 ? content.substring(0, 48) : content)
        : _summaryController.text.trim();
    final tags = _tagsController.text
        .split(RegExp(r'[，,\s]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    Navigator.of(context).pop(
      LocalRagDocument(
        title: title,
        source: _sourceController.text.trim().isEmpty
            ? '用户导入'
            : _sourceController.text.trim(),
        summary: summary,
        content: content,
        tags: tags.isEmpty ? ['本地资料'] : tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加 RAG 资料',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: '来源',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: '摘要',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: '标签，用逗号或空格分隔',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: '内容',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('加入资料库'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RagSearchResultTile extends StatelessWidget {
  const _RagSearchResultTile({required this.result});

  final RagSearchResult result;

  Future<void> _copyResultExcerpt(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _buildSearchResultMarkdown(result)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('已复制片段 ${result.document.title}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final document = result.document;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text('score ${result.score}'),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: '复制片段',
                    onPressed: () => _copyResultExcerpt(context),
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(document.summary),
              const SizedBox(height: 6),
              Text(
                result.rankingReason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                result.excerpt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(
                    label: Text(document.source),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(result.chunk.label),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  for (final field in result.matchedFields)
                    Chip(
                      label: Text('命中$field'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          colorScheme.secondaryContainer.withValues(alpha: 0.8),
                    ),
                  for (final tag in document.tags)
                    Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: result.matchedTags.contains(tag)
                          ? colorScheme.primaryContainer
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RagSourceTile extends StatelessWidget {
  const _RagSourceTile({required this.source});

  final LocalRagSource source;

  @override
  Widget build(BuildContext context) {
    return _RagSourceCard(source: source);
  }
}

class _RagSourceCard extends StatelessWidget {
  const _RagSourceCard({required this.source});

  final LocalRagSource source;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(source.icon, color: colorScheme.tertiary),
        title: Text(source.title),
        subtitle: Text(source.description),
        tileColor: colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
