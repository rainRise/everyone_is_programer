import 'package:flutter/material.dart';

class LocalRagSource {
  const LocalRagSource({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class LocalRagDocument {
  const LocalRagDocument({
    required this.title,
    required this.source,
    required this.summary,
    required this.content,
    required this.tags,
  });

  final String title;
  final String source;
  final String summary;
  final String content;
  final List<String> tags;

  factory LocalRagDocument.fromJson(Map<dynamic, dynamic> json) {
    return LocalRagDocument(
      title: json['title']?.toString() ?? '',
      source: json['source']?.toString() ?? '用户导入',
      summary: json['summary']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      tags: switch (json['tags']) {
        final List<dynamic> values => values
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty)
            .toList(),
        _ => const ['本地资料'],
      },
    ).normalized();
  }

  Map<String, Object> toJson() {
    final document = normalized();
    return {
      'title': document.title,
      'source': document.source,
      'summary': document.summary,
      'content': document.content,
      'tags': document.tags,
    };
  }

  LocalRagDocument normalized() {
    final normalizedTags = <String>[];
    for (final tag in tags) {
      final normalizedTag = tag.trim();
      if (normalizedTag.isEmpty) continue;
      if (normalizedTags.contains(normalizedTag)) continue;
      normalizedTags.add(normalizedTag);
    }

    return LocalRagDocument(
      title: title.trim(),
      source: source.trim().isEmpty ? '用户导入' : source.trim(),
      summary: summary.trim(),
      content: content.trim(),
      tags: normalizedTags.isEmpty ? const ['本地资料'] : normalizedTags,
    );
  }
}

class RagSearchResult {
  const RagSearchResult({
    required this.document,
    required this.chunk,
    required this.score,
    required this.matchedTags,
    required this.matchedFields,
    required this.rankingReason,
    required this.excerpt,
  });

  final LocalRagDocument document;
  final RagDocumentChunk chunk;
  final int score;
  final List<String> matchedTags;
  final List<String> matchedFields;
  final String rankingReason;
  final String excerpt;
}

class RagDocumentChunk {
  const RagDocumentChunk({
    required this.document,
    required this.index,
    required this.field,
    required this.text,
  });

  final LocalRagDocument document;
  final int index;
  final String field;
  final String text;

  String get label => '$field ${index + 1}';
}

class _RagContentSegment {
  const _RagContentSegment(
    this.text, {
    this.forceBoundary = false,
  });

  final String text;
  final bool forceBoundary;
}

class LocalRagAnswerDraft {
  const LocalRagAnswerDraft({
    required this.query,
    required this.answer,
    required this.contexts,
  });

  final String query;
  final String answer;
  final List<RagSearchResult> contexts;

  bool get hasContext => contexts.isNotEmpty;
}

class LocalRagRetrievalPlan {
  const LocalRagRetrievalPlan({
    required this.query,
    required this.tokens,
    required this.intentLabel,
    required this.retrievalStrategy,
    required this.candidateLimit,
    required this.contextLimit,
    required this.evidenceBudget,
  });

  final String query;
  final List<String> tokens;
  final String intentLabel;
  final String retrievalStrategy;
  final int candidateLimit;
  final int contextLimit;
  final String evidenceBudget;

  bool get canRetrieve => query.isNotEmpty && tokens.isNotEmpty;
}

const localRagSources = [
  LocalRagSource(
    title: 'Markdown 知识库',
    description: '适合沉淀课程笔记、项目总结和 Prompt 模板。',
    icon: Icons.article_outlined,
  ),
  LocalRagSource(
    title: 'PDF / 文档资料',
    description: '预留论文、官方文档和电子书导入入口。',
    icon: Icons.picture_as_pdf_outlined,
  ),
  LocalRagSource(
    title: '代码知识片段',
    description: '沉淀代码审计规则、漏洞案例和可复用片段。',
    icon: Icons.data_object_outlined,
  ),
  LocalRagSource(
    title: '视频课程摘录',
    description: '把课程字幕、时间戳和关键例子整理成可复习资料。',
    icon: Icons.subscriptions_outlined,
  ),
  LocalRagSource(
    title: '项目设计文档',
    description: '保存 README、ADR、接口约定和架构复盘。',
    icon: Icons.account_tree_outlined,
  ),
];

const localRagDocuments = [
  LocalRagDocument(
    title: 'RAG 学习路线',
    source: 'Markdown 知识库',
    summary: '从文档切分、Embedding、向量检索、重排到答案生成的完整路线。',
    content: 'RAG 的核心流程是资料清洗、切分、向量化、召回、重排和基于上下文生成答案。',
    tags: ['RAG', 'Embedding', '向量检索', '重排'],
  ),
  LocalRagDocument(
    title: 'MCP 工具配置笔记',
    source: 'Markdown 知识库',
    summary: '整理 Context7、Filesystem、GitHub MCP 的适用场景。',
    content: 'MCP 适合把文档、文件系统、GitHub 仓库、CI 和外部工具接入 Agent 工作流。',
    tags: ['MCP', 'Context7', 'Filesystem', 'GitHub'],
  ),
  LocalRagDocument(
    title: '推荐算法入门',
    source: 'PDF / 文档资料',
    summary: '解释召回、粗排、精排、重排，以及离线和在线指标。',
    content: '推荐系统通常包含用户画像、候选召回、特征工程、排序模型和 A/B 实验评估。',
    tags: ['推荐算法', '召回', '排序', 'A/B 实验'],
  ),
  LocalRagDocument(
    title: 'BM25 与混合检索',
    source: '代码知识片段',
    summary: '用 BM25 处理关键词匹配，用 Embedding 处理语义召回。',
    content: '混合检索可以把 BM25 的精确匹配和向量检索的语义召回合并，再用重排模型排序。',
    tags: ['BM25', 'Embedding', '混合检索'],
  ),
  LocalRagDocument(
    title: 'AI 代码审计清单',
    source: '代码知识片段',
    summary: '把敏感信息、危险调用、输入校验、权限边界作为审计重点。',
    content: '代码审计应先做确定性规则扫描，再把关键上下文交给 AI 复核并输出修复建议。',
    tags: ['代码审计', '安全', 'Prompt'],
  ),
  LocalRagDocument(
    title: '专注节奏复盘',
    source: 'Markdown 知识库',
    summary: '用 25 分钟专注、5 分钟短休息、15 分钟长休息保持学习节奏。',
    content: '长时间学习需要固定休息节奏，避免连续疲劳影响代码质量和知识吸收。',
    tags: ['番茄钟', '放松区', '学习效率'],
  ),
  LocalRagDocument(
    title: '视频课程摘录模板',
    source: '视频课程摘录',
    summary: '记录课程链接、章节、时间戳、核心概念和练习任务。',
    content: '视频资源进入 RAG 时要保留课程来源和时间戳，并把演示代码、概念解释、课后练习拆成独立片段。',
    tags: ['视频', '字幕', '课程', 'RAG'],
  ),
  LocalRagDocument(
    title: 'Agent Skill 使用索引',
    source: 'Markdown 知识库',
    summary: '按 TDD、系统化调试、代码审查、需求拆解和学习复盘组织 Skill。',
    content: '常用 Skill 适合沉淀成可复制流程：先明确输入，再执行步骤，最后产出测试、报告、复盘或 RAG 片段。',
    tags: ['Skill', 'TDD', '调试', '复盘'],
  ),
  LocalRagDocument(
    title: 'MCP 能力边界清单',
    source: '项目设计文档',
    summary: '为 Filesystem、GitHub、Playwright、Database MCP 记录权限边界。',
    content: 'MCP 配置需要先定义允许访问的资源、只读或写入权限、验证命令和失败回滚方式。',
    tags: ['MCP', 'Filesystem', 'GitHub', 'Playwright', 'Database'],
  ),
  LocalRagDocument(
    title: '学习资源推荐特征',
    source: '项目设计文档',
    summary: '用目标、资源类型、标签、难度、学习阶段和完成状态构建推荐特征。',
    content: '学习平台推荐可以先用规则召回，再按目标匹配、难度递进、多样性和最近完成状态重排。',
    tags: ['推荐算法', '排序模型', '学习路径', '特征工程'],
  ),
];

const _queryTokenSeparatorPattern =
    r'[\s,，、;；:：/\\|+\-&#_.=→⇒()（）\[\]［］【】<>《》]+';

List<RagSearchResult> searchLocalRagDocuments(
  String query, {
  int limit = 5,
  Iterable<LocalRagDocument> extraDocuments = const [],
}) {
  if (limit <= 0) return const [];

  final tokens = _queryTokens(query);
  final results = <RagSearchResult>[];

  for (final document in [...localRagDocuments, ...extraDocuments]) {
    final chunks = buildLocalRagChunks(document);
    final bestChunk = _bestChunk(chunks, tokens);
    final score = _scoreDocumentMetadata(document, tokens) +
        _scoreChunk(bestChunk, tokens);
    if (tokens.isEmpty || score > 0) {
      final matchedTags = _matchedTags(document, tokens);
      final matchedFields = _matchedFields(document, tokens, bestChunk);
      results.add(
        RagSearchResult(
          document: document,
          chunk: bestChunk,
          score: score,
          matchedTags: matchedTags,
          matchedFields: matchedFields,
          rankingReason: _buildRankingReason(
            score: score,
            matchedFields: matchedFields,
            matchedTags: matchedTags,
            chunk: bestChunk,
          ),
          excerpt: _excerptFor(bestChunk, tokens),
        ),
      );
    }
  }

  results.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    return a.document.title.compareTo(b.document.title);
  });

  return results.take(limit).toList();
}

List<RagDocumentChunk> buildLocalRagChunks(
  LocalRagDocument document, {
  int maxChunkLength = 96,
}) {
  final chunks = <RagDocumentChunk>[];

  void addChunk(String field, String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    chunks.add(
      RagDocumentChunk(
        document: document,
        index: chunks.length,
        field: field,
        text: normalized,
      ),
    );
  }

  addChunk('摘要', document.summary);

  final segments = _splitRagContentSegments(document.content);
  var buffer = '';
  for (final segment in segments) {
    if (segment.forceBoundary) {
      addChunk('正文', buffer);
      addChunk('正文', segment.text);
      buffer = '';
      continue;
    }

    final candidate = buffer.isEmpty ? segment.text : '$buffer ${segment.text}';
    if (buffer.isNotEmpty && candidate.length > maxChunkLength) {
      addChunk('正文', buffer);
      buffer = segment.text;
    } else {
      buffer = candidate;
    }
  }
  addChunk('正文', buffer.isEmpty ? document.content : buffer);

  return chunks.isEmpty
      ? [
          RagDocumentChunk(
            document: document,
            index: 0,
            field: '资料',
            text: document.title,
          ),
        ]
      : chunks;
}

List<_RagContentSegment> _splitRagContentSegments(String content) {
  final segments = <_RagContentSegment>[];
  final lines = content.split(RegExp(r'[\r\n]+'));

  for (final line in lines) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) continue;
    if (_isMarkdownBoundaryLine(trimmedLine)) {
      segments.add(_RagContentSegment(trimmedLine, forceBoundary: true));
      continue;
    }

    final sentences = trimmedLine
        .split(RegExp(r'[。！？!?；;.]'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.isNotEmpty);
    for (final sentence in sentences) {
      segments.add(_RagContentSegment(sentence, forceBoundary: true));
    }
  }

  return segments;
}

bool _isMarkdownBoundaryLine(String line) {
  return RegExp(r'^(#{1,6}\s+|[-*+]\s+|\d+[.)]\s+|>\s+)').hasMatch(line);
}

LocalRagAnswerDraft buildLocalRagAnswer(
  String query, {
  int contextLimit = 3,
  Iterable<LocalRagDocument> extraDocuments = const [],
}) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const LocalRagAnswerDraft(
      query: '',
      answer: '输入一个学习问题后，会基于本地资料生成可追溯回答草稿。',
      contexts: [],
    );
  }

  if (contextLimit <= 0) {
    return LocalRagAnswerDraft(
      query: normalizedQuery,
      answer: '当前上下文证据预算为 0，已跳过本地资料检索。可以提高上下文数量后重新生成回答草稿。',
      contexts: const [],
    );
  }

  final contexts = searchLocalRagDocuments(
    normalizedQuery,
    limit: contextLimit,
    extraDocuments: extraDocuments,
  );

  if (contexts.isEmpty) {
    return LocalRagAnswerDraft(
      query: normalizedQuery,
      answer: '本地资料库暂时没有命中相关内容。可以先添加课程笔记、代码片段或文档摘要，再重新检索。',
      contexts: const [],
    );
  }

  final primary = contexts.first.document;
  final evidence = contexts
      .map((result) => '《${result.document.title}》：${result.excerpt}')
      .join('\n');
  final citations = contexts
      .map((result) => '《${result.document.title}》(${result.document.source})')
      .join('、');

  return LocalRagAnswerDraft(
    query: normalizedQuery,
    answer: '围绕“$normalizedQuery”，建议先从《${primary.title}》开始。'
        '${primary.summary} 相关资料还包括：$citations。\n\n'
        '检索依据：\n$evidence',
    contexts: contexts,
  );
}

LocalRagRetrievalPlan buildLocalRagRetrievalPlan(
  String query, {
  int candidateLimit = 8,
  int contextLimit = 3,
}) {
  final normalizedQuery = query.trim();
  final normalizedCandidateLimit = candidateLimit < 0 ? 0 : candidateLimit;
  final normalizedContextLimit = contextLimit < 0 ? 0 : contextLimit;
  final tokens = _queryTokens(normalizedQuery);
  if (normalizedQuery.isEmpty || tokens.isEmpty) {
    return LocalRagRetrievalPlan(
      query: normalizedQuery,
      tokens: const [],
      intentLabel: '等待问题输入',
      retrievalStrategy: '输入问题后生成关键词召回计划',
      candidateLimit: normalizedCandidateLimit,
      contextLimit: normalizedContextLimit,
      evidenceBudget: '暂无证据预算',
    );
  }

  final tokenSet = tokens.toSet();
  final hasHybridSignal = tokenSet.any(
    (token) =>
        token.contains('bm25') ||
        token.contains('embedding') ||
        token.contains('向量') ||
        token.contains('混合') ||
        token.contains('重排'),
  );
  final hasAuditSignal = tokenSet.any(
    (token) => token.contains('审计') || token.contains('安全'),
  );
  final hasToolSignal = tokenSet.any(
    (token) =>
        token.contains('mcp') ||
        token.contains('skill') ||
        token.contains('工具'),
  );

  final intentLabel = hasAuditSignal
      ? '代码审计学习'
      : hasHybridSignal
          ? '检索架构学习'
          : hasToolSignal
              ? '工具链学习'
              : '学习资料问答';

  final retrievalStrategy = hasHybridSignal
      ? 'BM25 关键词召回 + Embedding 语义扩展 + 分块重排'
      : tokens.length == 1
          ? '关键词精确召回 + 最佳分块证据'
          : '多关键词召回 + 标签/标题加权 + 分块证据重排';

  return LocalRagRetrievalPlan(
    query: normalizedQuery,
    tokens: tokens,
    intentLabel: intentLabel,
    retrievalStrategy: retrievalStrategy,
    candidateLimit: normalizedCandidateLimit,
    contextLimit: normalizedContextLimit,
    evidenceBudget:
        '先召回 $normalizedCandidateLimit 条候选，再保留 $normalizedContextLimit 条上下文证据',
  );
}

String buildLocalRagStudyNote({
  required LocalRagRetrievalPlan plan,
  required LocalRagAnswerDraft draft,
}) {
  final buffer = StringBuffer()
    ..writeln('# RAG 学习笔记')
    ..writeln()
    ..writeln('## 问题')
    ..writeln(plan.query.isEmpty ? draft.query : plan.query)
    ..writeln()
    ..writeln('## 检索计划')
    ..writeln('- 意图：${plan.intentLabel}')
    ..writeln('- 策略：${plan.retrievalStrategy}')
    ..writeln('- 证据预算：${plan.evidenceBudget}');

  if (plan.tokens.isNotEmpty) {
    buffer.writeln('- 关键词：${plan.tokens.join('、')}');
  }

  buffer
    ..writeln()
    ..writeln('## 回答草稿')
    ..writeln(draft.answer);

  if (draft.contexts.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## 引用证据');
    for (final result in draft.contexts) {
      buffer.writeln(
        '- ${result.document.title}｜${result.document.source}｜${result.chunk.label}｜score ${result.score}：${result.excerpt}',
      );
    }
  }

  return buffer.toString().trimRight();
}

LocalRagDocument buildLocalRagStudyNoteDocument({
  required LocalRagRetrievalPlan plan,
  required LocalRagAnswerDraft draft,
}) {
  final query = plan.query.isEmpty ? draft.query : plan.query;
  final title = _buildLocalRagStudyNoteTitle(query);
  final content = buildLocalRagStudyNote(plan: plan, draft: draft);
  final summary = draft.hasContext
      ? '由本地 RAG 检索计划、回答草稿和 ${draft.contexts.length} 条引用证据生成。'
      : '由本地 RAG 检索计划和回答草稿生成。';

  return LocalRagDocument(
    title: title,
    source: 'RAG 学习笔记',
    summary: summary,
    content: content,
    tags: [
      'RAG',
      '学习笔记',
      plan.intentLabel,
    ],
  );
}

String _buildLocalRagStudyNoteTitle(String query) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) return 'RAG 学习笔记';
  if (normalizedQuery == 'RAG 学习笔记' ||
      normalizedQuery.startsWith('RAG 学习笔记：')) {
    return normalizedQuery;
  }
  return 'RAG 学习笔记：$normalizedQuery';
}

List<String> _queryTokens(String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return const [];
  final tokens = <String>[];
  final seenTokens = <String>{};
  for (final token in normalized
      .split(RegExp(_queryTokenSeparatorPattern))
      .where((token) => token.isNotEmpty)) {
    if (seenTokens.add(token)) {
      tokens.add(token);
    }
  }
  return tokens;
}

int _scoreDocumentMetadata(LocalRagDocument document, List<String> tokens) {
  if (tokens.isEmpty) return 0;

  var score = 0;
  final title = document.title.toLowerCase();
  final source = document.source.toLowerCase();
  final tags = document.tags.map((tag) => tag.toLowerCase()).toList();

  for (final token in tokens) {
    if (title.contains(token)) score += 5;
    if (source.contains(token)) score += 2;
    if (tags.any((tag) => tag.contains(token) || token.contains(tag))) {
      score += 4;
    }
  }

  return score;
}

RagDocumentChunk _bestChunk(
  List<RagDocumentChunk> chunks,
  List<String> tokens,
) {
  if (tokens.isEmpty) return chunks.first;

  var best = chunks.first;
  var bestScore = _scoreChunk(best, tokens);
  for (final chunk in chunks.skip(1)) {
    final score = _scoreChunk(chunk, tokens);
    if (score > bestScore) {
      best = chunk;
      bestScore = score;
    }
  }
  return best;
}

int _scoreChunk(RagDocumentChunk chunk, List<String> tokens) {
  if (tokens.isEmpty) return 0;

  var score = 0;
  final text = chunk.text.toLowerCase();
  for (final token in tokens) {
    final frequency = _termFrequency(text, token);
    if (frequency == 0) continue;
    final fieldWeight = chunk.field == '摘要' ? 3 : 2;
    score += fieldWeight + frequency;
  }
  if (_containsTokenPhrase(text, tokens)) {
    score += tokens.length + 2;
  }
  return score;
}

bool _containsTokenPhrase(String text, List<String> tokens) {
  if (tokens.length <= 1) return false;
  final textTokens = text
      .split(RegExp(_queryTokenSeparatorPattern))
      .where((token) => token.isNotEmpty)
      .toList();
  if (textTokens.length < tokens.length) return false;

  for (var start = 0; start <= textTokens.length - tokens.length; start++) {
    var matched = true;
    for (var offset = 0; offset < tokens.length; offset++) {
      if (textTokens[start + offset] != tokens[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) return true;
  }
  return false;
}

List<String> _matchedTags(LocalRagDocument document, List<String> tokens) {
  if (tokens.isEmpty) return const [];
  return document.tags.where((tag) {
    final normalizedTag = tag.toLowerCase();
    return tokens.any(
      (token) => normalizedTag.contains(token) || token.contains(normalizedTag),
    );
  }).toList();
}

List<String> _matchedFields(
  LocalRagDocument document,
  List<String> tokens,
  RagDocumentChunk chunk,
) {
  if (tokens.isEmpty) return const [];

  final fields = <String>[];
  final title = document.title.toLowerCase();
  final source = document.source.toLowerCase();
  final chunkText = chunk.text.toLowerCase();
  final tags = document.tags.map((tag) => tag.toLowerCase()).toList();

  for (final token in tokens) {
    if (title.contains(token)) fields.add('标题');
    if (source.contains(token)) fields.add('来源');
    if (tags.any((tag) => tag.contains(token) || token.contains(tag))) {
      fields.add('标签');
    }
    if (chunkText.contains(token)) fields.add(chunk.field);
  }

  return _dedupe(fields);
}

String _buildRankingReason({
  required int score,
  required List<String> matchedFields,
  required List<String> matchedTags,
  required RagDocumentChunk chunk,
}) {
  if (score == 0 && matchedFields.isEmpty && matchedTags.isEmpty) {
    return '默认展示：当前查询为空，按资料目录顺序展示。';
  }

  final reasons = <String>[];
  if (matchedFields.isNotEmpty) {
    reasons.add('命中${matchedFields.join('、')}');
  }
  if (matchedTags.isNotEmpty) {
    reasons.add('匹配标签 ${matchedTags.join('、')}');
  }
  reasons.add('最佳证据片段 ${chunk.label}');
  reasons.add('综合排序分 $score');
  return reasons.join('；');
}

String _excerptFor(RagDocumentChunk chunk, List<String> tokens) {
  if (tokens.isEmpty) return chunk.text;

  final lowerText = chunk.text.toLowerCase();
  for (final token in tokens) {
    final index = lowerText.indexOf(token);
    if (index < 0) continue;
    final start = index > 18 ? index - 18 : 0;
    final rawEnd = index + token.length + 42;
    final end = rawEnd > chunk.text.length ? chunk.text.length : rawEnd;
    final prefix = start > 0 ? '...' : '';
    final suffix = end < chunk.text.length ? '...' : '';
    return '$prefix${chunk.text.substring(start, end)}$suffix';
  }

  return chunk.text;
}

int _termFrequency(String text, String token) {
  var frequency = 0;
  var start = 0;
  while (start < text.length) {
    final index = text.indexOf(token, start);
    if (index < 0) break;
    frequency++;
    start = index + token.length;
  }
  return frequency;
}

List<String> _dedupe(List<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    if (seen.add(value)) result.add(value);
  }
  return result;
}
