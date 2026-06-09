import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_rag_catalog.dart';

void main() {
  test('local RAG search retrieves documents by keyword', () {
    final results = searchLocalRagDocuments('BM25 Embedding');

    expect(results, isNotEmpty);
    expect(results.first.score, greaterThan(0));
    expect(results.first.matchedTags, contains('BM25'));
    expect(results.first.matchedTags, contains('Embedding'));
    expect(results.first.excerpt.toLowerCase(), contains('bm25'));
  });

  test('local RAG search explains ranking reasons', () {
    final results = searchLocalRagDocuments('BM25 Embedding');

    expect(results, isNotEmpty);
    expect(results.first.rankingReason, contains('匹配标签'));
    expect(results.first.rankingReason, contains(results.first.chunk.label));
    expect(results.first.rankingReason, contains('综合排序分'));
  });

  test('local RAG query tokens are deduplicated before scoring', () {
    final singleTokenResults = searchLocalRagDocuments('BM25');
    final repeatedTokenResults = searchLocalRagDocuments('BM25 BM25');
    final plan = buildLocalRagRetrievalPlan('BM25 BM25 Embedding Embedding');

    expect(repeatedTokenResults.first.score, singleTokenResults.first.score);
    expect(plan.tokens, ['bm25', 'embedding']);
  });

  test('local RAG query tokens split common punctuation separators', () {
    final results = searchLocalRagDocuments('BM25, Embedding、BM25；Embedding');
    final plan = buildLocalRagRetrievalPlan('BM25, Embedding、BM25；Embedding');

    expect(results, isNotEmpty);
    expect(results.first.matchedTags, contains('BM25'));
    expect(results.first.matchedTags, contains('Embedding'));
    expect(plan.tokens, ['bm25', 'embedding']);
  });

  test('local RAG query tokens split technical separators', () {
    final results = searchLocalRagDocuments('BM25/Embedding|RAG');
    final plan = buildLocalRagRetrievalPlan('BM25/Embedding|RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split plus separators', () {
    final results = searchLocalRagDocuments('BM25+Embedding+RAG');
    final plan = buildLocalRagRetrievalPlan('BM25+Embedding+RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split hyphen separators', () {
    final results = searchLocalRagDocuments('BM25-Embedding-RAG');
    final plan = buildLocalRagRetrievalPlan('BM25-Embedding-RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split ampersand separators', () {
    final results = searchLocalRagDocuments('BM25&Embedding&RAG');
    final plan = buildLocalRagRetrievalPlan('BM25&Embedding&RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split parenthesis separators', () {
    final results = searchLocalRagDocuments('RAG(BM25)Embedding');
    final plan = buildLocalRagRetrievalPlan('RAG(BM25)Embedding');
    final fullWidthPlan = buildLocalRagRetrievalPlan('RAG（BM25）Embedding');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['rag', 'bm25', 'embedding']);
    expect(fullWidthPlan.tokens, ['rag', 'bm25', 'embedding']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split bracket separators', () {
    final results = searchLocalRagDocuments('[BM25]Embedding');
    final plan = buildLocalRagRetrievalPlan('[BM25]Embedding');
    final labelPlan = buildLocalRagRetrievalPlan('【RAG】BM25');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding']);
    expect(labelPlan.tokens, ['rag', 'bm25']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
  });

  test('local RAG query tokens split quote angle separators', () {
    final results = searchLocalRagDocuments('《BM25》Embedding');
    final plan = buildLocalRagRetrievalPlan('《BM25》Embedding');
    final anglePlan = buildLocalRagRetrievalPlan('<RAG>BM25');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding']);
    expect(anglePlan.tokens, ['rag', 'bm25']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
  });

  test('local RAG query tokens split underscore separators', () {
    final results = searchLocalRagDocuments('BM25_Embedding_RAG');
    final plan = buildLocalRagRetrievalPlan('BM25_Embedding_RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split dot separators', () {
    final results = searchLocalRagDocuments('BM25.Embedding.RAG');
    final plan = buildLocalRagRetrievalPlan('BM25.Embedding.RAG');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split backslash path separators', () {
    final results = searchLocalRagDocuments(r'RAG\BM25\Embedding');
    final plan = buildLocalRagRetrievalPlan(r'RAG\BM25\Embedding');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['rag', 'bm25', 'embedding']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split hash tag separators', () {
    final results = searchLocalRagDocuments('RAG#BM25#Embedding');
    final plan = buildLocalRagRetrievalPlan('RAG#BM25#Embedding');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['rag', 'bm25', 'embedding']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split flow arrow separators', () {
    final results = searchLocalRagDocuments('BM25=>Embedding→RAG');
    final plan = buildLocalRagRetrievalPlan('BM25=>Embedding→RAG');
    final doubleArrowPlan = buildLocalRagRetrievalPlan('BM25⇒Embedding');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['bm25', 'embedding', 'rag']);
    expect(doubleArrowPlan.tokens, ['bm25', 'embedding']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('RAG')),
      isTrue,
    );
  });

  test('local RAG query tokens split title separators', () {
    final results = searchLocalRagDocuments('RAG 学习笔记：BM25:Embedding');
    final plan = buildLocalRagRetrievalPlan('RAG 学习笔记：BM25:Embedding');

    expect(results, isNotEmpty);
    expect(plan.tokens, ['rag', '学习笔记', 'bm25', 'embedding']);
    expect(
      results.any((result) => result.matchedTags.contains('BM25')),
      isTrue,
    );
    expect(
      results.any((result) => result.matchedTags.contains('Embedding')),
      isTrue,
    );
  });

  test('local RAG search returns default documents for empty query', () {
    final results = searchLocalRagDocuments('');

    expect(results.length, 5);
    expect(results.every((result) => result.score == 0), isTrue);
  });

  test('local RAG search returns empty results for non-positive limits', () {
    expect(searchLocalRagDocuments('BM25', limit: 0), isEmpty);
    expect(searchLocalRagDocuments('', limit: -1), isEmpty);
  });

  test('local RAG catalog includes platform learning source packs', () {
    final sourceIcons = localRagSources.map((source) => source.icon).toSet();
    final allTags = localRagDocuments.expand((document) => document.tags);

    expect(localRagSources.length, greaterThanOrEqualTo(5));
    expect(sourceIcons.length, greaterThanOrEqualTo(5));
    expect(allTags, contains('MCP'));
    expect(allTags, contains('Playwright'));
    expect(allTags, contains('Skill'));
  });

  test('local RAG search retrieves expanded platform materials', () {
    final results = searchLocalRagDocuments('Playwright MCP');

    expect(results, isNotEmpty);
    expect(results.first.matchedTags, contains('MCP'));
    expect(results.first.matchedTags, contains('Playwright'));
  });

  test('local RAG search includes imported documents', () {
    const imported = LocalRagDocument(
      title: 'Custom Flutter learning note',
      source: 'User import',
      summary: 'Records Flutter state management and testing methods.',
      content:
          'Flutter pages can be verified with widget tests for text and actions.',
      tags: ['Flutter', 'testing'],
    );

    final results = searchLocalRagDocuments(
      'Flutter',
      extraDocuments: [imported],
    );

    expect(results.first.document.title, imported.title);
    expect(results.first.matchedTags, contains('Flutter'));
  });

  test('local RAG builds searchable chunks from document content', () {
    const document = LocalRagDocument(
      title: 'Sync algorithm note',
      source: 'User import',
      summary: 'Records multi-device sync ideas.',
      content:
          'First paragraph introduces local cache. Second paragraph explains conflict merge and timestamp comparison. Third paragraph records rollback strategy.',
      tags: ['sync'],
    );

    final chunks = buildLocalRagChunks(document, maxChunkLength: 48);

    expect(chunks.length, greaterThanOrEqualTo(2));
    expect(chunks.first.field, isNotEmpty);
    expect(
        chunks.any((chunk) => chunk.text.contains('conflict merge')), isTrue);
  });

  test('local RAG chunks split English sentence boundaries', () {
    const document = LocalRagDocument(
      title: 'Sync boundary note',
      source: 'User import',
      summary: 'Records sentence boundary behavior.',
      content:
          'Cache warmup explains local storage. Conflict merge explains vector clocks. Rollback captures last safe snapshot.',
      tags: ['sync'],
    );

    final chunks = buildLocalRagChunks(document, maxChunkLength: 48);
    final bodyChunks = chunks.skip(1).toList();

    expect(bodyChunks.length, greaterThanOrEqualTo(3));
    expect(
      chunks.any(
          (chunk) => chunk.text == 'Conflict merge explains vector clocks'),
      isTrue,
    );
    expect(
      chunks.any((chunk) => chunk.text.contains('local storage Conflict')),
      isFalse,
    );
  });

  test('local RAG chunks preserve markdown heading and list boundaries', () {
    const document = LocalRagDocument(
      title: 'Markdown chunk note',
      source: 'User import',
      summary: 'Records Markdown chunk boundary behavior.',
      content: '''
Intro paragraph explains retrieval setup.
# Retrieval Plan
- Collect BM25 evidence
1. Compare embedding recall
Closing paragraph records rerank checks.
''',
      tags: ['RAG'],
    );

    final chunks = buildLocalRagChunks(document, maxChunkLength: 160);

    expect(chunks.any((chunk) => chunk.text == '# Retrieval Plan'), isTrue);
    expect(
        chunks.any((chunk) => chunk.text == '- Collect BM25 evidence'), isTrue);
    expect(
      chunks.any((chunk) => chunk.text == '1. Compare embedding recall'),
      isTrue,
    );
    expect(
      chunks.any((chunk) => chunk.text.contains('setup # Retrieval Plan')),
      isFalse,
    );
  });

  test('local RAG search returns the best matching chunk as evidence', () {
    const imported = LocalRagDocument(
      title: 'Sync algorithm note',
      source: 'User import',
      summary: 'Records multi-device sync ideas.',
      content:
          'First paragraph introduces local cache. Second paragraph explains conflict merge and timestamp comparison. Third paragraph records rollback strategy.',
      tags: ['sync'],
    );

    final results = searchLocalRagDocuments(
      'conflict merge',
      extraDocuments: [imported],
    );

    expect(results.first.document.title, imported.title);
    expect(results.first.excerpt, contains('conflict merge'));
    expect(results.first.matchedFields, isNotEmpty);
  });

  test('local RAG search boosts exact multi-token phrases', () {
    const looseMatch = LocalRagDocument(
      title: 'Loose sync note',
      source: 'User import',
      summary: 'Sync note.',
      content:
          'Conflict appears in cache design. Merge appears in rollback planning.',
      tags: [],
    );
    const phraseMatch = LocalRagDocument(
      title: 'Phrase sync note',
      source: 'User import',
      summary: 'Sync note.',
      content: 'Conflict merge appears in vector clock reconciliation.',
      tags: [],
    );

    final results = searchLocalRagDocuments(
      'conflict merge',
      extraDocuments: [looseMatch, phraseMatch],
    );

    expect(results.first.document.title, phraseMatch.title);
    expect(results.first.excerpt.toLowerCase(), contains('conflict merge'));
    expect(
      results.first.score,
      greaterThan(
        results
            .firstWhere((result) => result.document.title == looseMatch.title)
            .score,
      ),
    );
  });

  test('local RAG phrase scoring tolerates technical separators', () {
    const looseMatch = LocalRagDocument(
      title: 'Loose sync note',
      source: 'User import',
      summary: 'Sync note.',
      content:
          'Conflict appears in cache design. Merge appears in rollback planning.',
      tags: [],
    );
    const separatedPhraseMatch = LocalRagDocument(
      title: 'Separated phrase note',
      source: 'User import',
      summary: 'Merge note.',
      content: 'Conflict-merge strategy keeps vector clocks readable.',
      tags: [],
    );

    final results = searchLocalRagDocuments(
      'conflict merge',
      extraDocuments: [looseMatch, separatedPhraseMatch],
    );

    expect(results.first.document.title, separatedPhraseMatch.title);
    expect(results.first.score, greaterThan(6));
    expect(
      results.first.score,
      greaterThan(
        results
            .firstWhere((result) => result.document.title == looseMatch.title)
            .score,
      ),
    );
  });

  test('local RAG answer draft cites retrieved context', () {
    final draft = buildLocalRagAnswer('BM25 Embedding');

    expect(draft.hasContext, isTrue);
    expect(draft.contexts.length, lessThanOrEqualTo(3));
    expect(draft.answer, contains('BM25 Embedding'));
    expect(draft.contexts.first.matchedTags, contains('BM25'));
  });

  test('local RAG answer draft handles empty queries', () {
    final draft = buildLocalRagAnswer('  ');

    expect(draft.hasContext, isFalse);
    expect(draft.contexts, isEmpty);
  });

  test('local RAG answer draft explains zero context budget', () {
    final draft = buildLocalRagAnswer('BM25', contextLimit: 0);

    expect(draft.query, 'BM25');
    expect(draft.hasContext, isFalse);
    expect(draft.contexts, isEmpty);
    expect(draft.answer, contains('上下文证据预算为 0'));
    expect(draft.answer, contains('跳过本地资料检索'));
  });

  test('local RAG retrieval plan explains hybrid search intent', () {
    final plan = buildLocalRagRetrievalPlan('BM25 Embedding');

    expect(plan.canRetrieve, isTrue);
    expect(plan.tokens, contains('bm25'));
    expect(plan.tokens, contains('embedding'));
    expect(plan.candidateLimit, 8);
    expect(plan.contextLimit, 3);
    expect(plan.retrievalStrategy, contains('BM25'));
    expect(plan.retrievalStrategy, contains('Embedding'));
    expect(plan.evidenceBudget, contains('8'));
    expect(plan.evidenceBudget, contains('3'));
  });

  test('local RAG retrieval plan handles empty queries', () {
    final plan = buildLocalRagRetrievalPlan('  ');

    expect(plan.canRetrieve, isFalse);
    expect(plan.tokens, isEmpty);
    expect(plan.candidateLimit, 8);
    expect(plan.contextLimit, 3);
  });

  test('local RAG retrieval plan clamps negative limits', () {
    final plan = buildLocalRagRetrievalPlan(
      'BM25',
      candidateLimit: -2,
      contextLimit: -1,
    );
    final emptyPlan = buildLocalRagRetrievalPlan(
      '  ',
      candidateLimit: -2,
      contextLimit: -1,
    );

    expect(plan.candidateLimit, 0);
    expect(plan.contextLimit, 0);
    expect(plan.evidenceBudget, contains('0'));
    expect(plan.evidenceBudget, isNot(contains('-')));
    expect(emptyPlan.candidateLimit, 0);
    expect(emptyPlan.contextLimit, 0);
  });

  test('local RAG study note combines plan answer and evidence', () {
    const query = 'BM25 Embedding';
    final plan = buildLocalRagRetrievalPlan(query);
    final draft = buildLocalRagAnswer(query);
    final note = buildLocalRagStudyNote(plan: plan, draft: draft);

    expect(note, startsWith('# RAG'));
    expect(note, contains(query));
    expect(note, contains(plan.intentLabel));
    expect(note, contains(plan.evidenceBudget));
    expect(note, contains(draft.answer));
    expect(note, contains('score'));
  });

  test('local RAG citation score summary handles populated and empty contexts',
      () {
    final draft = buildLocalRagAnswer('BM25 Embedding');
    final summary = summarizeLocalRagCitationScores(draft.contexts);
    final emptySummary = summarizeLocalRagCitationScores(const []);
    final lowestScore = draft.contexts
        .map((context) => context.score)
        .reduce((value, element) => value < element ? value : element);

    expect(summary.topScore, draft.contexts.first.score);
    expect(summary.lowestScore, lowestScore);
    expect(summary.averageScore, isNotEmpty);
    expect(emptySummary.topScore, 0);
    expect(emptySummary.lowestScore, 0);
    expect(emptySummary.averageScore, '0.0');
  });

  test('local RAG study note includes citation score summary', () {
    const query = 'BM25 Embedding';
    final plan = buildLocalRagRetrievalPlan(query);
    final draft = buildLocalRagAnswer(query);
    final summary = summarizeLocalRagCitationScores(draft.contexts);
    final note = buildLocalRagStudyNote(plan: plan, draft: draft);

    expect(
      note,
      contains(
        '\u6700\u9ad8\u5f15\u7528\u5206\uff1a${summary.topScore}',
      ),
    );
    expect(
      note,
      contains(
        '\u6700\u4f4e\u5f15\u7528\u5206\uff1a${summary.lowestScore}',
      ),
    );
    expect(
      note,
      contains(
        '\u5e73\u5747\u5f15\u7528\u5206\uff1a${summary.averageScore}',
      ),
    );
  });

  test('local RAG study note can be converted into a document', () {
    const query = 'BM25 Embedding';
    final plan = buildLocalRagRetrievalPlan(query);
    final draft = buildLocalRagAnswer(query);
    final summary = summarizeLocalRagCitationScores(draft.contexts);
    final document = buildLocalRagStudyNoteDocument(
      plan: plan,
      draft: draft,
    );

    expect(document.title, contains(query));
    expect(document.source, 'RAG 学习笔记');
    expect(document.summary, contains('${draft.contexts.length}'));
    expect(document.summary, contains('最高引用分 ${summary.topScore}'));
    expect(document.summary, contains('最低引用分 ${summary.lowestScore}'));
    expect(document.summary, contains('平均引用分 ${summary.averageScore}'));
    expect(document.content, contains(draft.answer));
    expect(document.tags, contains('RAG'));
    expect(document.tags, contains('学习笔记'));

    final results = searchLocalRagDocuments(
      query,
      extraDocuments: [document],
    );
    expect(results.any((result) => result.document.title == document.title),
        isTrue);
  });

  test('local RAG study note document title is idempotent', () {
    const title = 'RAG 学习笔记：BM25 Embedding';
    final plan = buildLocalRagRetrievalPlan(title);
    final draft = buildLocalRagAnswer(title);
    final document = buildLocalRagStudyNoteDocument(
      plan: plan,
      draft: draft,
    );

    expect(document.title, title);
    expect(document.title, isNot(contains('RAG 学习笔记：RAG 学习笔记')));
  });
}
