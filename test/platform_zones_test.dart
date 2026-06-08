import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/coding_zone_page.dart';
import 'package:kazumi/pages/platform/learning_zone_page.dart';
import 'package:kazumi/pages/platform/platform_code_audit_repository.dart';
import 'package:kazumi/pages/platform/platform_learning_catalog.dart';
import 'package:kazumi/pages/platform/platform_learning_progress_repository.dart';
import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/pages/platform/platform_recommendation_catalog.dart';
import 'package:kazumi/pages/platform/platform_relax_session_repository.dart';
import 'package:kazumi/pages/platform/rag_library_preview.dart';
import 'package:kazumi/pages/settings/platform_settings_page.dart';
import 'package:kazumi/pages/platform/platform_zone_workflow.dart';
import 'package:kazumi/pages/platform/relax_zone_page.dart';
import 'package:kazumi/pages/router.dart';
import 'package:kazumi/utils/platform_storage.dart';

void main() {
  test('platform menu routes expose the three primary zones', () {
    expect(menu.size, 3);
    expect(menu.getPath(0), '/learning');
    expect(menu.getPath(1), '/coding');
    expect(menu.getPath(2), '/relax');
  });

  test('platform startup path opens the learning zone by default', () {
    expect(defaultPlatformStartupPath, '/tab/learning/');
  });

  test('legacy startup paths normalize to the learning zone', () {
    const legacyPaths = [
      '/tab/popular/',
      '/tab/timeline/',
      '/tab/collect/',
      '/tab/my/',
    ];

    for (final path in legacyPaths) {
      expect(normalizePlatformStartupPath(path), defaultPlatformStartupPath);
    }

    expect(normalizePlatformStartupPath('/tab/coding/'), '/tab/coding/');
    expect(normalizePlatformStartupPath('/tab/relax/'), '/tab/relax/');
    expect(normalizePlatformStartupPath(null), defaultPlatformStartupPath);
    expect(normalizePlatformStartupPath(1), defaultPlatformStartupPath);
  });

  test('startup page choices match platform menu routes', () {
    expect(defaultPlatformPageLabels.keys.toList(), [
      '/tab/learning/',
      '/tab/coding/',
      '/tab/relax/',
    ]);
    expect(defaultPlatformPageLabels.values.toList(), ['资料', '编程', '放松']);
  });

  test('platform workflow connects the three zones into one loop', () {
    expect(platformZoneWorkflow.map((stage) => stage.zoneLabel), [
      '资料学习区',
      '编程区',
      '放松区',
    ]);
    expect(
      platformZoneWorkflow.expand((stage) => stage.outputs),
      containsAll(['RAG 片段', '审计报告', '专注记录']),
    );
  });

  testWidgets('learning zone presents core programmer learning resources',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LearningZonePage()));

    expect(find.text('资料学习区'), findsWidgets);
    expect(find.text('三大区协作流'), findsOneWidget);
    expect(find.text('资料输入'), findsOneWidget);
    expect(find.text('编码实践'), findsOneWidget);
    expect(find.text('节奏恢复'), findsOneWidget);
    expect(find.text('视频资源'), findsOneWidget);
    expect(find.text('常用 Skill'), findsOneWidget);
    expect(find.text('MCP 工具'), findsOneWidget);
    expect(find.text('本地 RAG 资料'), findsOneWidget);
    expect(find.text('算法与模型'), findsOneWidget);
    expect(find.text('今日建议路径'), findsOneWidget);
    expect(find.text('学习进度'), findsOneWidget);
    expect(find.byTooltip('平台设置'), findsOneWidget);
    expect(
      find.text('0 / ${allPlatformLearningResources.length}'),
      findsOneWidget,
    );
    expect(find.text('推荐算法原型'), findsOneWidget);
    expect(find.text('候选召回'), findsOneWidget);
    expect(find.textContaining('用目标关键词、资源类型和标签'), findsOneWidget);
    expect(find.text('精排打分'), findsOneWidget);
    expect(find.text('资源目录'), findsOneWidget);
    expect(find.text('能力地图'), findsOneWidget);
    expect(find.text('CS50'), findsWidgets);
    expect(find.text('Context7'), findsWidgets);
    expect(find.text('BM25'), findsWidgets);
    expect(find.text('沉淀到 RAG 资料库'), findsOneWidget);
    expect(find.text('复制 RAG 学习笔记'), findsOneWidget);
    expect(find.text('本地 RAG 检索'), findsOneWidget);
    expect(find.text('RAG 检索计划'), findsOneWidget);
    expect(find.text('学习资料问答'), findsOneWidget);
    expect(find.text('候选 8'), findsOneWidget);
    expect(find.text('上下文 3'), findsOneWidget);
    expect(find.text('RAG 回答草稿'), findsOneWidget);
    expect(find.text('添加资料'), findsOneWidget);
    expect(find.text('已导入 0 条本地资料，导入后会立即参与检索。'), findsOneWidget);
    expect(find.text('RAG 学习路线'), findsOneWidget);
    expect(find.text('RAG 资料包'), findsOneWidget);
    expect(find.text('Markdown 知识库'), findsWidgets);
    expect(find.text('PDF / 文档资料'), findsWidgets);
    expect(find.text('代码知识片段'), findsOneWidget);
  });

  testWidgets('learning zone copies progress review markdown', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformLearningProgressRepository(storage: storage);
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = Map<String, Object?>.from(call.arguments as Map);
          clipboardText = data['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LearningZonePage(progressRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    final firstCheckbox = find.byType(Checkbox).first;
    await tester.ensureVisible(firstCheckbox);
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    final copyProgressButton = find.byTooltip('复制学习进度复盘');
    await tester.ensureVisible(copyProgressButton);
    await tester.tap(copyProgressButton);
    await tester.pumpAndSettle();

    expect(find.text('学习进度复盘已复制'), findsOneWidget);
    expect(clipboardText, contains('# 学习进度复盘'));
    expect(
      clipboardText,
      contains('- 已完成：1/${allPlatformLearningResources.length}'),
    );
    expect(clipboardText, contains('## 已完成资源'));
    expect(
      clipboardText,
      contains('1. ${allPlatformLearningResources.first.title}'),
    );
    expect(
      storage.values[PlatformSettingKey.platformCompletedLearningResources],
      [allPlatformLearningResources.first.id],
    );
  });

  testWidgets('learning zone can undo clearing progress', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformLearningProgressRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(
        home: LearningZonePage(progressRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    final firstCheckbox = find.byType(Checkbox).first;
    await tester.ensureVisible(firstCheckbox);
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(find.text('1 / ${allPlatformLearningResources.length}'),
        findsOneWidget);
    expect(
      storage.values[PlatformSettingKey.platformCompletedLearningResources],
      [allPlatformLearningResources.first.id],
    );

    final clearProgressButton = find.byTooltip('清空学习进度');
    await tester.ensureVisible(clearProgressButton);
    await tester.tap(clearProgressButton);
    await tester.pumpAndSettle();

    expect(find.text('学习进度已清空'), findsOneWidget);
    expect(find.text('0 / ${allPlatformLearningResources.length}'),
        findsOneWidget);
    expect(
      storage.values[PlatformSettingKey.platformCompletedLearningResources],
      isEmpty,
    );

    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();

    expect(find.text('学习进度已恢复'), findsOneWidget);
    expect(find.text('1 / ${allPlatformLearningResources.length}'),
        findsOneWidget);
    expect(
      storage.values[PlatformSettingKey.platformCompletedLearningResources],
      [allPlatformLearningResources.first.id],
    );
  });

  testWidgets('learning zone recommendations skip completed resources',
      (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformLearningProgressRepository(storage: storage);
    final topRecommendation = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
    ).first.resource;
    final topRecommendationKey =
        ValueKey('recommendation-${topRecommendation.id}');
    final topResourceKey = ValueKey('resource-${topRecommendation.id}');

    await tester.pumpWidget(
      MaterialApp(
        home: LearningZonePage(progressRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    final recommendationGoalChip =
        find.byKey(const ValueKey('learning-goal-recommendation'));
    await tester.ensureVisible(recommendationGoalChip);
    await tester.tap(recommendationGoalChip);
    await tester.pumpAndSettle();

    expect(find.byKey(topRecommendationKey), findsOneWidget);

    final resourceCard = find.byKey(topResourceKey);
    await tester.ensureVisible(resourceCard);
    await tester.tap(
      find.descendant(
        of: resourceCard,
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(topRecommendationKey), findsNothing);
  });

  testWidgets('learning zone copies recommendation markdown', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformLearningProgressRepository(storage: storage);
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = Map<String, Object?>.from(call.arguments as Map);
          clipboardText = data['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LearningZonePage(progressRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    final recommendationGoalChip =
        find.byKey(const ValueKey('learning-goal-recommendation'));
    await tester.ensureVisible(recommendationGoalChip);
    await tester.tap(recommendationGoalChip);
    await tester.pumpAndSettle();

    final copyButton = find.byTooltip('复制学习推荐清单');
    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('学习推荐清单已复制'), findsOneWidget);
    expect(clipboardText, contains('# 学习推荐清单'));
    expect(clipboardText, contains('- 推荐数量：'));
    expect(clipboardText, contains('## 下一步推荐'));
    expect(clipboardText, contains('- 推荐理由：'));
  });

  testWidgets('learning zone shows empty state when recommendations are done',
      (tester) async {
    final completedRecommendationIds = recommendPlatformResources(
      PlatformLearningGoal.recommendation,
      limit: allPlatformLearningResources.length,
    ).map((recommendation) => recommendation.resource.id).toList();
    final storage = _MemoryPlatformRagStorage()
      ..values[PlatformSettingKey.platformCompletedLearningResources] =
          completedRecommendationIds;
    final repository = PlatformLearningProgressRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(
        home: LearningZonePage(progressRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    final recommendationGoalChip =
        find.byKey(const ValueKey('learning-goal-recommendation'));
    await tester.ensureVisible(recommendationGoalChip);
    await tester.tap(recommendationGoalChip);
    await tester.pumpAndSettle();

    expect(
      find.text('当前目标下的推荐资源已完成，可以切换学习目标或复制推荐清单做复盘。'),
      findsOneWidget,
    );
  });

  testWidgets('RAG preview saves study notes into local library',
      (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RagLibraryPreview(repository: repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(storage.savedDocuments, isEmpty);

    final saveStudyNoteButton = find.text('沉淀到 RAG 资料库');

    await tester.ensureVisible(saveStudyNoteButton);
    await tester.tap(saveStudyNoteButton);
    await tester.pumpAndSettle();

    expect(storage.savedDocuments.length, 1);
    expect(storage.savedDocuments.single['source'], 'RAG 学习笔记');
    expect(storage.savedDocuments.single['content'], contains('# RAG 学习笔记'));
    expect(find.textContaining('已导入 1 条本地资料'), findsOneWidget);

    final savedTitle = storage.savedDocuments.single['title'];

    await tester.ensureVisible(saveStudyNoteButton);
    await tester.tap(saveStudyNoteButton);
    await tester.pumpAndSettle();

    expect(storage.savedDocuments.length, 1);
    expect(storage.savedDocuments.single['title'], savedTitle);
    expect(find.text('RAG 学习笔记已存在，已聚焦到资料库'), findsOneWidget);
  });

  testWidgets('RAG preview focuses duplicate manual imports', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = Map<String, Object?>.from(call.arguments as Map);
          clipboardText = data['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RagLibraryPreview(repository: repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _addRagDocument(
      tester,
      title: '  Custom RAG note  ',
      source: 'Notebook import',
      tags: 'RAGTag UXTag FlowTag CacheTag ExtraTag DebugTag',
      content: '  Duplicate-safe imported content.  ',
    );

    final copyPlanButton = find.byTooltip('复制检索计划');
    await tester.ensureVisible(copyPlanButton);
    await tester.tap(copyPlanButton);
    await tester.pumpAndSettle();

    expect(find.text('RAG 检索计划已复制'), findsOneWidget);
    expect(clipboardText, contains('# RAG 检索计划'));
    expect(clipboardText, contains('- 查询：Custom RAG note'));
    expect(clipboardText, contains('- 意图：'));
    expect(clipboardText, contains('- 策略：'));
    expect(clipboardText, contains('- 关键词：'));

    final copyAnswerDraftButton = find.text('复制回答草稿');
    await tester.ensureVisible(copyAnswerDraftButton);
    await tester.tap(copyAnswerDraftButton);
    await tester.pumpAndSettle();

    expect(find.text('RAG 回答草稿已复制'), findsOneWidget);
    expect(clipboardText, contains('# RAG 回答草稿'));
    expect(clipboardText, contains('- 问题：Custom RAG note'));
    expect(clipboardText, contains('## 回答'));
    expect(clipboardText, contains('## 引用摘要'));

    expect(storage.savedDocuments.length, 1);
    expect(storage.savedDocuments.single['title'], 'Custom RAG note');
    expect(storage.savedDocuments.single['source'], 'Notebook import');
    expect(storage.savedDocuments.single['tags'], [
      'RAGTag',
      'UXTag',
      'FlowTag',
      'CacheTag',
      'ExtraTag',
      'DebugTag',
    ]);
    expect(
      storage.savedDocuments.single['content'],
      'Duplicate-safe imported content.',
    );
    expect(find.text('Notebook import'), findsWidgets);
    expect(find.text('RAGTag'), findsWidgets);
    expect(find.text('UXTag'), findsWidgets);
    expect(find.text('FlowTag'), findsWidgets);
    expect(find.text('CacheTag'), findsWidgets);
    expect(find.text('+2'), findsOneWidget);
    expect(find.byTooltip('ExtraTag, DebugTag'), findsOneWidget);

    final copyButton = find.byTooltip('复制资料');
    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('已复制 Custom RAG note'), findsOneWidget);
    expect(clipboardText, contains('# Custom RAG note'));
    expect(clipboardText, contains('- 来源：Notebook import'));
    expect(clipboardText,
        contains('- 标签：RAGTag, UXTag, FlowTag, CacheTag, ExtraTag, DebugTag'));
    expect(clipboardText, contains('Duplicate-safe imported content.'));

    final copyExcerptButton = find.byTooltip('复制片段').first;
    await tester.ensureVisible(copyExcerptButton);
    await tester.tap(copyExcerptButton);
    await tester.pumpAndSettle();

    expect(find.text('已复制片段 Custom RAG note'), findsOneWidget);
    expect(clipboardText, contains('# 检索片段：Custom RAG note'));
    expect(clipboardText, contains('- 来源：Notebook import'));
    expect(clipboardText, contains('- 排序原因：'));
    expect(clipboardText, contains('## 证据'));
    expect(clipboardText, contains('Duplicate-safe imported content.'));

    final queryField = find.byType(TextField).first;
    await tester.enterText(queryField, 'unrelated query');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Custom RAG note').last);
    await tester.tap(find.text('Custom RAG note').last);
    await tester.pumpAndSettle();

    final queryTextField = tester.widget<TextField>(queryField);
    expect(queryTextField.controller?.text, 'Custom RAG note');

    await _addRagDocument(
      tester,
      title: 'Custom RAG note',
      source: 'Notebook import',
      tags: 'RAGTag UXTag FlowTag CacheTag ExtraTag DebugTag',
      content: 'Duplicate-safe imported content.',
    );

    expect(storage.savedDocuments.length, 1);
    expect(storage.savedDocuments.single['title'], 'Custom RAG note');
    expect(find.text('RAG 资料已存在，已聚焦到资料库'), findsOneWidget);
  });

  testWidgets('RAG preview copies imported library summary markdown',
      (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = Map<String, Object?>.from(call.arguments as Map);
          clipboardText = data['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RagLibraryPreview(repository: repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _addRagDocument(
      tester,
      title: 'First RAG import',
      source: 'Notebook',
      tags: 'RAG Flutter',
      content: 'First imported note content.',
    );
    await _addRagDocument(
      tester,
      title: 'Second RAG import',
      source: 'Notebook',
      tags: 'RAG Audit',
      content: 'Second imported note content.',
    );

    final copySummaryButton = find.byTooltip('复制资料库总览');
    await tester.ensureVisible(copySummaryButton);
    await tester.tap(copySummaryButton);
    await tester.pumpAndSettle();

    expect(find.text('RAG 资料库总览已复制'), findsOneWidget);
    expect(clipboardText, contains('# RAG 资料库总览'));
    expect(clipboardText, contains('- 资料数量：2'));
    expect(clipboardText, contains('- 来源分布：Notebook 2'));
    expect(clipboardText, contains('RAG 2'));
    expect(clipboardText, contains('Flutter 1'));
    expect(clipboardText, contains('Audit 1'));
    expect(clipboardText, contains('1. Second RAG import'));
    expect(clipboardText, contains('2. First RAG import'));
    expect(clipboardText, contains('- 摘要：Second imported note content.'));
    expect(clipboardText, contains('- 摘要：First imported note content.'));
  });

  testWidgets('RAG preview can undo imported document deletion',
      (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RagLibraryPreview(repository: repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _addRagDocument(
      tester,
      title: 'Undoable RAG note',
      content: 'Imported content that can be restored after deletion.',
    );

    expect(storage.savedDocuments.length, 1);

    final deleteButton = find.byTooltip('删除资料');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(storage.savedDocuments, isEmpty);
    expect(find.text('已删除 Undoable RAG note'), findsOneWidget);

    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();

    expect(storage.savedDocuments.length, 1);
    expect(storage.savedDocuments.single['title'], 'Undoable RAG note');
    expect(find.text('Undoable RAG note'), findsWidgets);
  });

  testWidgets('coding zone presents code audit workspace actions',
      (tester) async {
    Future<List<CodeAuditSavedReport>> loadReports({
      CodeAuditReportType? reportType,
    }) async {
      return const [];
    }

    await tester.pumpWidget(
      MaterialApp(home: CodingZonePage(reportHistoryLoader: loadReports)),
    );

    expect(find.text('编程区'), findsOneWidget);
    expect(find.text('代码工作区'), findsOneWidget);
    expect(find.text('AI 代码审计'), findsOneWidget);
    expect(find.text('审计报告'), findsOneWidget);
    expect(find.byTooltip('平台设置'), findsOneWidget);
    expect(find.text('审计准备进度'), findsOneWidget);
    expect(find.text('审计清单'), findsOneWidget);
    expect(find.text('规则配置'), findsOneWidget);
    expect(find.text('选择本次片段扫描和项目扫描要启用的本地规则。'), findsOneWidget);
    expect(find.text('本地项目审计'), findsOneWidget);
    expect(find.text('扫描项目'), findsOneWidget);
    expect(find.text('保存项目报告'), findsOneWidget);
    expect(find.text('本地规则扫描'), findsOneWidget);
    expect(find.text('复制报告'), findsOneWidget);
    expect(find.text('运行扫描'), findsOneWidget);
    expect(find.text('发现 3 个风险'), findsOneWidget);
    expect(find.text('疑似硬编码密钥'), findsWidgets);
    expect(find.text('明文 HTTP 地址'), findsWidgets);
    expect(find.text('AI 审计接口占位'), findsOneWidget);
    expect(find.text('复制 AI 请求草稿'), findsOneWidget);
    expect(find.textContaining('当前不会调用远程模型'), findsOneWidget);
    expect(find.text('修复建议模板'), findsOneWidget);
    expect(find.text('复制修复模板'), findsOneWidget);
    expect(find.textContaining('模板包含风险定位'), findsOneWidget);
    expect(find.text('审计报告历史'), findsOneWidget);
    expect(find.text('保存报告后会在这里显示最近的 Markdown 记录。'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('片段'), findsOneWidget);
    expect(find.text('项目'), findsOneWidget);
    expect(find.text('Prompt 模板'), findsOneWidget);
    expect(find.text('复制 Prompt'), findsOneWidget);
    expect(find.text('代码审计流程'), findsOneWidget);
    expect(find.text('导入项目'), findsWidgets);
    expect(find.text('规则扫描'), findsWidgets);
    expect(find.text('AI 审计'), findsWidgets);
    expect(find.text('生成报告'), findsWidgets);
  });

  testWidgets('coding zone filters report history by audit type',
      (tester) async {
    final snippetReport = CodeAuditSavedReport(
      fileName: 'code_audit_snippet.md',
      reportType: CodeAuditReportType.snippet,
      path: r'C:\tmp\code_audit_snippet.md',
      modifiedAt: DateTime(2026, 1, 1, 10),
      sizeBytes: 128,
    );
    final projectReport = CodeAuditSavedReport(
      fileName: 'project_code_audit_app.md',
      reportType: CodeAuditReportType.project,
      path: r'C:\tmp\project_code_audit_app.md',
      modifiedAt: DateTime(2026, 1, 2, 10),
      sizeBytes: 256,
    );
    final requestedTypes = <CodeAuditReportType?>[];

    Future<List<CodeAuditSavedReport>> loadReports({
      CodeAuditReportType? reportType,
    }) async {
      requestedTypes.add(reportType);
      return switch (reportType) {
        null => [projectReport, snippetReport],
        CodeAuditReportType.snippet => [snippetReport],
        CodeAuditReportType.project => [projectReport],
      };
    }

    await tester.pumpWidget(
      MaterialApp(home: CodingZonePage(reportHistoryLoader: loadReports)),
    );
    await tester.pumpAndSettle();

    expect(requestedTypes, [null]);
    expect(find.text('code_audit_snippet.md'), findsOneWidget);
    expect(find.text('project_code_audit_app.md'), findsOneWidget);

    await tester.ensureVisible(find.text('项目'));
    await tester.tap(find.text('项目'));
    await tester.pumpAndSettle();

    expect(requestedTypes.last, CodeAuditReportType.project);
    expect(find.text('project_code_audit_app.md'), findsOneWidget);
    expect(find.text('code_audit_snippet.md'), findsNothing);

    await tester.ensureVisible(find.text('片段'));
    await tester.tap(find.text('片段'));
    await tester.pumpAndSettle();

    expect(requestedTypes.last, CodeAuditReportType.snippet);
    expect(find.text('code_audit_snippet.md'), findsOneWidget);
    expect(find.text('project_code_audit_app.md'), findsNothing);
  });

  testWidgets('coding zone deletes and restores saved report history entries',
      (tester) async {
    final snippetReport = CodeAuditSavedReport(
      fileName: 'code_audit_snippet.md',
      reportType: CodeAuditReportType.snippet,
      path: r'C:\tmp\code_audit_snippet.md',
      modifiedAt: DateTime(2026, 1, 1, 10),
      sizeBytes: 128,
    );
    final projectReport = CodeAuditSavedReport(
      fileName: 'project_code_audit_app.md',
      reportType: CodeAuditReportType.project,
      path: r'C:\tmp\project_code_audit_app.md',
      modifiedAt: DateTime(2026, 1, 2, 10),
      sizeBytes: 256,
    );
    final reports = <CodeAuditSavedReport>[projectReport, snippetReport];
    final deletedReports = <String>[];
    final restoredReports = <String>[];
    final reportMarkdown = <String, String>{
      projectReport.path: '# Project report',
      snippetReport.path: '# Snippet report',
    };

    Future<List<CodeAuditSavedReport>> loadReports({
      CodeAuditReportType? reportType,
    }) async {
      if (reportType == null) return reports;
      return reports
          .where((report) => report.reportType == reportType)
          .toList(growable: false);
    }

    Future<void> deleteReport(CodeAuditSavedReport report) async {
      deletedReports.add(report.fileName);
      reports.removeWhere((item) => item.path == report.path);
    }

    Future<String> readReport(CodeAuditSavedReport report) async {
      return reportMarkdown[report.path]!;
    }

    Future<void> restoreReport(
      CodeAuditSavedReport report,
      String markdown,
    ) async {
      restoredReports.add('${report.fileName}:$markdown');
      reports.insert(0, report);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: CodingZonePage(
          reportHistoryLoader: loadReports,
          reportHistoryDeleter: deleteReport,
          reportMarkdownReader: readReport,
          reportHistoryRestorer: restoreReport,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.byTooltip('删除报告').first;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(deletedReports, ['project_code_audit_app.md']);
    expect(find.text('project_code_audit_app.md 已删除'), findsOneWidget);
    expect(find.text('project_code_audit_app.md'), findsNothing);
    expect(find.text('code_audit_snippet.md'), findsOneWidget);

    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();

    expect(restoredReports, ['project_code_audit_app.md:# Project report']);
    expect(find.text('project_code_audit_app.md 已恢复'), findsOneWidget);
    expect(find.text('project_code_audit_app.md'), findsOneWidget);
    expect(find.text('code_audit_snippet.md'), findsOneWidget);
  });

  testWidgets('relax zone presents recovery resources', (tester) async {
    final repository = PlatformRelaxSessionRepository(
      storage: _MemoryPlatformRagStorage(),
    );

    await tester.pumpWidget(
      MaterialApp(home: RelaxZonePage(sessionRepository: repository)),
    );

    expect(find.text('放松区'), findsOneWidget);
    expect(find.text('番茄钟'), findsOneWidget);
    expect(find.text('休息资源'), findsOneWidget);
    expect(find.text('轻量工具'), findsOneWidget);
    expect(find.byTooltip('平台设置'), findsOneWidget);
    expect(find.text('专注节奏'), findsOneWidget);
    expect(find.byTooltip('记录完成'), findsOneWidget);
    expect(find.text('节奏记录'), findsOneWidget);
    expect(find.text('已记录 0 次，共 0 分钟。'), findsOneWidget);
    expect(find.text('节奏分布：无'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('开始'), findsOneWidget);
    expect(find.text('放松工具箱'), findsOneWidget);
    expect(find.text('专注 25 分钟'), findsWidgets);
    expect(find.text('短休息 5 分钟'), findsWidgets);
    expect(find.text('长休息 15 分钟'), findsWidgets);
  });

  testWidgets('relax zone copies session summary markdown', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRelaxSessionRepository(storage: storage);
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = Map<String, Object?>.from(call.arguments as Map);
          clipboardText = data['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: RelaxZonePage(sessionRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('记录完成'));
    await tester.pumpAndSettle();

    expect(find.text('已记录 1 次，共 25 分钟。'), findsOneWidget);
    expect(find.text('节奏分布：专注 25 分钟 1 次/25 分钟'), findsOneWidget);

    final copyButton = find.byTooltip('复制总结');
    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('节奏总结已复制'), findsOneWidget);
    expect(clipboardText, contains('# 放松节奏总结'));
    expect(clipboardText, contains('- 记录次数：1'));
    expect(clipboardText, contains('- 累计分钟：25'));
    expect(clipboardText, contains('专注 25 分钟'));
  });

  testWidgets('relax zone can undo clearing session history', (tester) async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRelaxSessionRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(home: RelaxZonePage(sessionRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('记录完成'));
    await tester.pumpAndSettle();

    expect(find.text('已记录 1 次，共 25 分钟。'), findsOneWidget);
    expect(
      storage.values[PlatformSettingKey.platformRelaxSessions],
      isNotEmpty,
    );

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(find.text('节奏记录已清空'), findsOneWidget);
    expect(find.text('已记录 0 次，共 0 分钟。'), findsOneWidget);
    expect(storage.values[PlatformSettingKey.platformRelaxSessions], isEmpty);

    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();

    expect(find.text('已记录 1 次，共 25 分钟。'), findsOneWidget);
    expect(
      storage.values[PlatformSettingKey.platformRelaxSessions],
      isNotEmpty,
    );
  });

  testWidgets('platform settings page focuses on platform-level controls',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlatformSettingsPage()));

    expect(find.text('平台设置'), findsWidgets);
    expect(find.text('平台偏好'), findsOneWidget);
    expect(find.text('外观设置'), findsOneWidget);
    expect(find.text('界面设置'), findsOneWidget);
    expect(find.text('关于平台'), findsOneWidget);
    expect(find.text('平台偏好'), findsOneWidget);
    expect(find.textContaining('默认启动页'), findsOneWidget);
    expect(find.textContaining('许可证'), findsOneWidget);
  });
}

Future<void> _addRagDocument(
  WidgetTester tester, {
  required String title,
  required String content,
  String? source,
  String? tags,
}) async {
  final addButton = find.text('添加资料');
  await tester.ensureVisible(addButton);
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  final textFields = find.byType(TextField);
  await tester.enterText(textFields.at(1), title);
  if (source != null) {
    await tester.enterText(textFields.at(2), source);
  }
  if (tags != null) {
    await tester.enterText(textFields.at(4), tags);
  }
  await tester.enterText(textFields.at(5), content);

  final saveButton = find.text('加入资料库');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

class _MemoryPlatformRagStorage implements PlatformRagStorage {
  final Map<String, Object?> values = {};

  List<Map<dynamic, dynamic>> get savedDocuments {
    final raw = values[PlatformSettingKey.platformRagDocuments];
    if (raw is! List) return const [];
    return raw.whereType<Map<dynamic, dynamic>>().toList();
  }

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values[key] ?? defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }
}
