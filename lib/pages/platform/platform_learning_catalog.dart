import 'package:flutter/material.dart';

enum PlatformResourceType {
  video,
  skill,
  mcp,
  rag,
  model,
}

extension PlatformResourceTypeLabel on PlatformResourceType {
  String get label {
    return switch (this) {
      PlatformResourceType.video => '视频',
      PlatformResourceType.skill => 'Skill',
      PlatformResourceType.mcp => 'MCP',
      PlatformResourceType.rag => 'RAG',
      PlatformResourceType.model => '模型',
    };
  }

  IconData get icon {
    return switch (this) {
      PlatformResourceType.video => Icons.play_circle_outline,
      PlatformResourceType.skill => Icons.psychology_alt_outlined,
      PlatformResourceType.mcp => Icons.hub_outlined,
      PlatformResourceType.rag => Icons.folder_copy_outlined,
      PlatformResourceType.model => Icons.auto_graph_outlined,
    };
  }
}

class PlatformLearningSection {
  const PlatformLearningSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.resources,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<PlatformLearningResource> resources;
}

class PlatformLearningResource {
  const PlatformLearningResource({
    required this.title,
    required this.description,
    required this.type,
    required this.level,
    required this.actionLabel,
    required this.url,
    this.tags = const [],
    this.guide,
  });

  final String title;
  final String description;
  final PlatformResourceType type;
  final String level;
  final String actionLabel;
  final String url;
  final List<String> tags;
  final PlatformLearningGuide? guide;

  String get id => url;

  bool get isExternalUrl {
    return url.startsWith('https://') || url.startsWith('http://');
  }

  bool matches(String keyword, PlatformResourceType? selectedType) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesType = selectedType == null || selectedType == type;
    final matchesKeyword = normalizedKeyword.isEmpty ||
        title.toLowerCase().contains(normalizedKeyword) ||
        description.toLowerCase().contains(normalizedKeyword) ||
        tags.any((tag) => tag.toLowerCase().contains(normalizedKeyword));
    return matchesType && matchesKeyword;
  }
}

class PlatformLearningGuide {
  const PlatformLearningGuide({
    required this.overview,
    required this.steps,
    required this.outputs,
  });

  final String overview;
  final List<String> steps;
  final List<String> outputs;

  String toClipboardText(PlatformLearningResource resource) {
    final buffer = StringBuffer()
      ..writeln('# ${resource.title}')
      ..writeln()
      ..writeln(overview)
      ..writeln()
      ..writeln('## 步骤');
    for (var i = 0; i < steps.length; i++) {
      buffer.writeln('${i + 1}. ${steps[i]}');
    }
    buffer
      ..writeln()
      ..writeln('## 产出');
    for (final output in outputs) {
      buffer.writeln('- $output');
    }
    return buffer.toString();
  }
}

const platformLearningSections = [
  PlatformLearningSection(
    title: '视频资源',
    description: '收集免费课程、技术分享和实战项目视频。',
    icon: Icons.play_circle_outline,
    resources: [
      PlatformLearningResource(
        title: 'CS50',
        description: '计算机科学入门和编程基础。',
        type: PlatformResourceType.video,
        level: '入门',
        actionLabel: '打开课程',
        url: 'https://cs50.harvard.edu/x/',
        tags: ['计算机科学', 'C', 'Python', '基础'],
      ),
      PlatformLearningResource(
        title: 'MIT 6.006',
        description: '算法设计、数据结构和复杂度分析。',
        type: PlatformResourceType.video,
        level: '进阶',
        actionLabel: '查看课程',
        url:
            'https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/',
        tags: ['算法', '数据结构', '复杂度'],
      ),
      PlatformLearningResource(
        title: 'FreeCodeCamp',
        description: '覆盖前端、后端和项目实战的免费视频课程。',
        type: PlatformResourceType.video,
        level: '入门',
        actionLabel: '进入学习',
        url: 'https://www.freecodecamp.org/learn/',
        tags: ['前端', '后端', '项目实战'],
      ),
      PlatformLearningResource(
        title: 'The Missing Semester',
        description: '补齐 Shell、Git、编辑器、调试和命令行工具等工程基本功。',
        type: PlatformResourceType.video,
        level: '基础',
        actionLabel: '打开课程',
        url: 'https://missing.csail.mit.edu/',
        tags: ['Shell', 'Git', '调试', '工程效率'],
      ),
      PlatformLearningResource(
        title: 'CMU 15-445',
        description: '数据库系统课程，适合理解索引、事务、查询执行和存储引擎。',
        type: PlatformResourceType.video,
        level: '进阶',
        actionLabel: '查看课程',
        url: 'https://15445.courses.cs.cmu.edu/',
        tags: ['数据库', '系统', '存储', '索引'],
      ),
    ],
  ),
  PlatformLearningSection(
    title: '常用 Skill',
    description: '整理高频 AI Agent Skill，按学习、编码、调试分类。',
    icon: Icons.psychology_alt_outlined,
    resources: [
      PlatformLearningResource(
        title: 'TDD',
        description: '先写失败测试，再写最小实现。',
        type: PlatformResourceType.skill,
        level: '实战',
        actionLabel: '查看步骤',
        url: 'local://skills/test-driven-development',
        tags: ['测试', '重构', '质量'],
        guide: PlatformLearningGuide(
          overview: '用一个失败测试锁定目标行为，再写最小实现并重构。',
          steps: [
            '把需求改写成一个可执行测试。',
            '确认测试失败，失败原因必须指向目标行为。',
            '写最小代码让测试通过。',
            '在测试保护下整理命名、边界和重复代码。',
          ],
          outputs: ['失败测试', '最小实现', '重构记录'],
        ),
      ),
      PlatformLearningResource(
        title: '系统化调试',
        description: '先定位根因，再实施修复。',
        type: PlatformResourceType.skill,
        level: '实战',
        actionLabel: '查看步骤',
        url: 'local://skills/systematic-debugging',
        tags: ['调试', '根因', '复现'],
        guide: PlatformLearningGuide(
          overview: '把问题从现象拆成可复现输入、最小范围和可验证假设。',
          steps: [
            '记录复现步骤、环境和期望/实际结果。',
            '缩小到最小失败样例或最小代码路径。',
            '一次只验证一个假设。',
            '修复后补回归测试并记录根因。',
          ],
          outputs: ['复现说明', '根因假设', '回归测试'],
        ),
      ),
      PlatformLearningResource(
        title: '代码审查',
        description: '聚焦行为风险、回归和缺失测试。',
        type: PlatformResourceType.skill,
        level: '实战',
        actionLabel: '查看清单',
        url: 'local://skills/requesting-code-review',
        tags: ['审查', '风险', '测试'],
        guide: PlatformLearningGuide(
          overview: '先看行为风险和回归面，再看风格与可维护性。',
          steps: [
            '确认改动目标、入口和用户可见行为。',
            '检查数据流、错误处理、权限和边界条件。',
            '对照测试覆盖关键路径和失败路径。',
            '按严重度输出文件位置、影响和修复建议。',
          ],
          outputs: ['风险清单', '缺失测试', '修复建议'],
        ),
      ),
      PlatformLearningResource(
        title: '需求拆解',
        description: '把模糊想法拆成目标、验收条件、任务和风险。',
        type: PlatformResourceType.skill,
        level: '常用',
        actionLabel: '查看模板',
        url: 'local://skills/requirement-breakdown',
        tags: ['需求', '任务拆解', '验收'],
        guide: PlatformLearningGuide(
          overview: '先把用户目标写清楚，再拆成可验证的小任务，减少边做边猜。',
          steps: [
            '用一句话写出用户要完成的结果。',
            '列出必须满足的验收条件和非目标。',
            '按数据、界面、逻辑、测试拆成小任务。',
            '标出依赖、未知点和最容易返工的部分。',
          ],
          outputs: ['目标说明', '验收清单', '任务列表'],
        ),
      ),
      PlatformLearningResource(
        title: '学习复盘',
        description: '把一次编码或课程学习沉淀成本地 RAG 资料。',
        type: PlatformResourceType.skill,
        level: '常用',
        actionLabel: '查看模板',
        url: 'local://skills/learning-retrospective',
        tags: ['复盘', 'RAG', '笔记'],
        guide: PlatformLearningGuide(
          overview: '把过程中的问题、判断和结论整理成下一次能检索到的知识片段。',
          steps: [
            '记录这次学习或编码的背景和目标。',
            '写下关键概念、踩坑点和最终方案。',
            '补充可复用代码片段、Prompt 或检查清单。',
            '添加标签后导入本地 RAG，并用问题检索验证。',
          ],
          outputs: ['复盘笔记', 'RAG 片段', '检索问题'],
        ),
      ),
    ],
  ),
  PlatformLearningSection(
    title: 'MCP 工具',
    description: '沉淀可复用的 MCP Server、工具链和使用说明。',
    icon: Icons.hub_outlined,
    resources: [
      PlatformLearningResource(
        title: 'Context7',
        description: '按库名查询官方文档和 API 用法。',
        type: PlatformResourceType.mcp,
        level: '常用',
        actionLabel: '配置 MCP',
        url: 'local://mcp/context7',
        tags: ['文档', 'API', '上下文'],
        guide: PlatformLearningGuide(
          overview: '用 Context7 把官方文档接入 Agent，降低过期 API 记忆带来的误差。',
          steps: [
            '确认当前项目依赖的库名和版本。',
            '让 Agent 先查询官方文档，再编写代码。',
            '把关键 API 用法沉淀到本地 RAG。',
          ],
          outputs: ['库名清单', '官方 API 摘要', '可复用示例'],
        ),
      ),
      PlatformLearningResource(
        title: 'Filesystem MCP',
        description: '安全读写本地文件和目录。',
        type: PlatformResourceType.mcp,
        level: '常用',
        actionLabel: '配置 MCP',
        url: 'local://mcp/filesystem',
        tags: ['文件', '本地', '自动化'],
        guide: PlatformLearningGuide(
          overview: '给 Agent 明确的本地文件访问边界，支持项目读取、编辑和资料导入。',
          steps: [
            '只暴露需要协作的工作区目录。',
            '先读取结构和现有模式，再执行修改。',
            '变更后用测试、diff 和日志确认影响范围。',
          ],
          outputs: ['工作区白名单', '文件改动记录', '验证命令'],
        ),
      ),
      PlatformLearningResource(
        title: 'GitHub MCP',
        description: '管理 Issue、PR、CI 和仓库上下文。',
        type: PlatformResourceType.mcp,
        level: '进阶',
        actionLabel: '配置 MCP',
        url: 'local://mcp/github',
        tags: ['GitHub', 'PR', 'CI'],
        guide: PlatformLearningGuide(
          overview: '把远端仓库、PR、Issue 和 CI 状态纳入开发上下文。',
          steps: [
            '读取 Issue/PR 目标和验收条件。',
            '检查分支、提交、CI 和评审意见。',
            '把修复结果同步到 PR 摘要和后续任务。',
          ],
          outputs: ['PR 上下文', 'CI 结果', '评审反馈清单'],
        ),
      ),
      PlatformLearningResource(
        title: 'Playwright MCP',
        description: '让 Agent 通过浏览器检查页面、交互流程和截图结果。',
        type: PlatformResourceType.mcp,
        level: '进阶',
        actionLabel: '配置 MCP',
        url: 'local://mcp/playwright',
        tags: ['浏览器', 'E2E', '截图', '交互'],
        guide: PlatformLearningGuide(
          overview: '把前端页面的可见结果纳入 Agent 验证流程，适合 UI 调试和端到端检查。',
          steps: [
            '启动本地应用或测试页面。',
            '让 Agent 打开页面、执行关键交互并采集截图。',
            '检查空白画面、遮挡、响应式布局和控制台错误。',
            '把失败截图和复现步骤写入修复任务。',
          ],
          outputs: ['页面截图', '交互记录', 'UI 问题清单'],
        ),
      ),
      PlatformLearningResource(
        title: 'Database MCP',
        description: '连接本地或测试数据库，辅助查看表结构、样例数据和查询结果。',
        type: PlatformResourceType.mcp,
        level: '进阶',
        actionLabel: '配置 MCP',
        url: 'local://mcp/database',
        tags: ['数据库', 'SQL', '数据分析'],
        guide: PlatformLearningGuide(
          overview: '在明确权限边界内让 Agent 读取数据库结构和样例数据，辅助定位数据问题。',
          steps: [
            '只连接开发库、测试库或脱敏数据源。',
            '先读取表结构、索引和字段含义。',
            '用只读查询验证业务假设和异常样例。',
            '把查询结论沉淀成项目 RAG 资料。',
          ],
          outputs: ['表结构摘要', '只读查询', '数据问题记录'],
        ),
      ),
    ],
  ),
  PlatformLearningSection(
    title: '本地 RAG 资料',
    description: '导入本地文档、代码片段和学习笔记，参与知识库检索与问答。',
    icon: Icons.folder_copy_outlined,
    resources: [
      PlatformLearningResource(
        title: 'Markdown 笔记',
        description: '适合课程笔记、读书摘要和项目复盘。',
        type: PlatformResourceType.rag,
        level: '本地',
        actionLabel: '导入目录',
        url: 'local://rag/markdown',
        tags: ['笔记', '知识库', 'Prompt'],
        guide: PlatformLearningGuide(
          overview: '把零散笔记整理成可检索资料，适合课程和项目复盘。',
          steps: [
            '按主题拆分 Markdown 文件。',
            '每篇保留标题、来源、摘要和标签。',
            '把关键结论导入本地 RAG 面板验证检索。',
          ],
          outputs: ['Markdown 资料包', '标签体系', '检索样例'],
        ),
      ),
      PlatformLearningResource(
        title: 'PDF 文档',
        description: '适合论文、电子书和官方手册。',
        type: PlatformResourceType.rag,
        level: '本地',
        actionLabel: '导入文件',
        url: 'local://rag/pdf',
        tags: ['论文', '手册', '文档'],
        guide: PlatformLearningGuide(
          overview: '把长文档拆成可引用片段，形成带来源的学习资料。',
          steps: [
            '提取章节标题、摘要和关键段落。',
            '为每个片段记录页码或章节来源。',
            '用问题检索检查召回结果是否可追溯。',
          ],
          outputs: ['文档摘要', '引用来源', '问答上下文'],
        ),
      ),
      PlatformLearningResource(
        title: '代码片段',
        description: '适合审计案例、漏洞样例和修复模板。',
        type: PlatformResourceType.rag,
        level: '本地',
        actionLabel: '导入片段',
        url: 'local://rag/code-snippets',
        tags: ['代码', '审计', '漏洞'],
        guide: PlatformLearningGuide(
          overview: '把代码案例沉淀成可复用的审计和修复知识。',
          steps: [
            '记录问题代码、触发条件和影响。',
            '补充修复代码和验证方式。',
            '用标签区分语言、漏洞类型和测试场景。',
          ],
          outputs: ['代码案例', '修复模板', '审计标签'],
        ),
      ),
      PlatformLearningResource(
        title: '课程字幕与摘录',
        description: '适合把视频课程中的关键讲解整理成可检索文本。',
        type: PlatformResourceType.rag,
        level: '本地',
        actionLabel: '导入摘录',
        url: 'local://rag/video-transcripts',
        tags: ['视频', '字幕', '课程', 'RAG'],
        guide: PlatformLearningGuide(
          overview: '把视频学习从“看过”变成“能检索、能引用、能复习”的资料。',
          steps: [
            '记录课程链接、章节标题和时间戳。',
            '摘录核心概念、例子和代码演示。',
            '按主题添加标签，例如 RAG、推荐算法、调试。',
            '用课程问题检索，确认能召回对应片段。',
          ],
          outputs: ['视频摘录', '时间戳来源', '复习问题'],
        ),
      ),
      PlatformLearningResource(
        title: '项目 README 与设计文档',
        description: '适合导入架构说明、接口约定、ADR 和模块边界。',
        type: PlatformResourceType.rag,
        level: '本地',
        actionLabel: '导入文档',
        url: 'local://rag/project-docs',
        tags: ['项目文档', '架构', '接口', 'ADR'],
        guide: PlatformLearningGuide(
          overview: '把项目背景、设计决策和模块边界放入知识库，减少重复摸索。',
          steps: [
            '收集 README、设计文档、接口说明和 ADR。',
            '按模块、业务流程和技术决策拆分片段。',
            '记录文件路径、版本和最后更新时间。',
            '用“某模块为什么这样设计”一类问题验证检索。',
          ],
          outputs: ['项目资料包', '模块标签', '架构问答上下文'],
        ),
      ),
    ],
  ),
  PlatformLearningSection(
    title: '算法与模型',
    description: '覆盖 RAG、推荐算法、搜索算法和排序模型。',
    icon: Icons.auto_graph_outlined,
    resources: [
      PlatformLearningResource(
        title: 'BM25',
        description: '传统关键词检索和混合搜索基础。',
        type: PlatformResourceType.model,
        level: '基础',
        actionLabel: '学习原理',
        url: 'local://models/bm25',
        tags: ['搜索', '排序', '关键词'],
        guide: PlatformLearningGuide(
          overview: '理解关键词检索的召回基础，方便后续做混合检索。',
          steps: [
            '学习词频、逆文档频率和字段权重。',
            '用本地 RAG 查询比较关键词命中差异。',
            '记录适合 BM25 的资料类型和失败场景。',
          ],
          outputs: ['BM25 笔记', '检索样例', '失败案例'],
        ),
      ),
      PlatformLearningResource(
        title: 'Embedding 模型',
        description: '向量检索、相似度搜索和语义召回。',
        type: PlatformResourceType.model,
        level: '进阶',
        actionLabel: '学习原理',
        url: 'local://models/embedding',
        tags: ['向量', '语义', '召回'],
        guide: PlatformLearningGuide(
          overview: '理解语义向量召回，补足关键词检索找不到同义表达的问题。',
          steps: [
            '整理同义问题和相似资料对。',
            '比较余弦相似度、Top-K 和阈值的影响。',
            '设计 BM25 + Embedding 的混合召回方案。',
          ],
          outputs: ['语义样例集', '阈值记录', '混合召回方案'],
        ),
      ),
      PlatformLearningResource(
        title: '推荐排序模型',
        description: '召回、粗排、精排和重排的学习入口。',
        type: PlatformResourceType.model,
        level: '进阶',
        actionLabel: '学习路径',
        url: 'local://models/recommendation-ranking',
        tags: ['推荐算法', '排序', '重排'],
        guide: PlatformLearningGuide(
          overview: '把学习资源推荐拆成召回、粗排、精排和解释四个阶段。',
          steps: [
            '定义用户学习目标、水平和近期行为。',
            '用标签、类型和关键词生成候选资源。',
            '按匹配分、难度和多样性重排。',
            '为每条推荐生成可解释原因。',
          ],
          outputs: ['用户画像', '排序特征', '推荐解释'],
        ),
      ),
      PlatformLearningResource(
        title: 'Learning to Rank',
        description: '用特征和监督信号学习搜索、推荐和资源排序。',
        type: PlatformResourceType.model,
        level: '进阶',
        actionLabel: '学习路径',
        url: 'local://models/learning-to-rank',
        tags: ['排序模型', '特征工程', '推荐算法', '搜索'],
        guide: PlatformLearningGuide(
          overview: '理解从人工规则排序走向可训练排序模型的关键概念。',
          steps: [
            '定义 query、候选资源、标签和排序目标。',
            '构造文本匹配、难度、时长、完成率等特征。',
            '比较 pointwise、pairwise 和 listwise 训练方式。',
            '用 NDCG、MRR 或命中率评估排序效果。',
          ],
          outputs: ['排序样本', '特征清单', '评估指标'],
        ),
      ),
      PlatformLearningResource(
        title: 'Bandit 与 A/B 实验',
        description: '在推荐系统中平衡探索、利用和在线评估。',
        type: PlatformResourceType.model,
        level: '高级',
        actionLabel: '学习路径',
        url: 'local://models/bandit-ab-testing',
        tags: ['推荐算法', 'A/B 实验', '探索利用', '评估'],
        guide: PlatformLearningGuide(
          overview: '理解推荐系统上线后的在线评估，以及新资源冷启动时的探索策略。',
          steps: [
            '定义点击率、完成率、留存和学习效果等指标。',
            '用 A/B 实验比较不同推荐策略。',
            '用 Bandit 思路为新资源保留探索流量。',
            '监控负反馈，避免只追求短期点击。',
          ],
          outputs: ['实验方案', '指标面板', '探索策略'],
        ),
      ),
    ],
  ),
];

List<PlatformLearningResource> get allPlatformLearningResources {
  return [
    for (final section in platformLearningSections) ...section.resources,
  ];
}

String buildLearningResourceCatalogMarkdown({
  required Iterable<PlatformLearningResource> resources,
  required Set<String> completedResourceIds,
  String keyword = '',
  PlatformResourceType? selectedType,
  DateTime? generatedAt,
}) {
  final resourceList = resources.toList(growable: false);
  final generatedTime = generatedAt ?? DateTime.now();
  final normalizedKeyword = keyword.trim();
  final typeCounts = <String, int>{};
  var completedCount = 0;

  for (final resource in resourceList) {
    typeCounts.update(resource.type.label, (count) => count + 1,
        ifAbsent: () => 1);
    if (completedResourceIds.contains(resource.id)) {
      completedCount++;
    }
  }

  final buffer = StringBuffer()
    ..writeln('# 学习资源清单')
    ..writeln()
    ..writeln('- 生成时间：${_formatLearningCatalogTimestamp(generatedTime)}')
    ..writeln('- 筛选关键词：${normalizedKeyword.isEmpty ? '全部' : normalizedKeyword}')
    ..writeln('- 资源类型：${selectedType?.label ?? '全部'}')
    ..writeln('- 匹配资源：${resourceList.length}')
    ..writeln('- 已完成：$completedCount')
    ..writeln('- 类型分布：${_formatLearningCatalogTypeCounts(typeCounts)}');

  if (resourceList.isEmpty) {
    buffer
      ..writeln()
      ..writeln('暂无匹配的学习资源。');
    return buffer.toString().trimRight();
  }

  buffer
    ..writeln()
    ..writeln('## 资源列表');

  for (var index = 0; index < resourceList.length; index++) {
    final resource = resourceList[index];
    final status = completedResourceIds.contains(resource.id) ? '已完成' : '未完成';
    buffer
      ..writeln()
      ..writeln('${index + 1}. ${resource.title}')
      ..writeln('   - 类型：${resource.type.label}')
      ..writeln('   - 难度：${resource.level}')
      ..writeln('   - 状态：$status')
      ..writeln('   - 标签：${resource.tags.join('、')}')
      ..writeln('   - 入口：${resource.url}')
      ..writeln('   - 简介：${resource.description}');
  }

  return buffer.toString().trimRight();
}

String _formatLearningCatalogTimestamp(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatLearningCatalogTypeCounts(Map<String, int> counts) {
  if (counts.isEmpty) return '无';
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return entries.map((entry) => '${entry.key} ${entry.value}').join('、');
}
