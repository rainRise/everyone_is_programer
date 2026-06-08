# 人人都是程序员 MVP 交付说明

## 目标

把原 Kazumi Flutter 壳改造成程序员学习平台 MVP，形成三个主区：

- 资料学习区
- 编程区
- 放松区

本阶段优先完成可运行、可测试、可本地持久化的闭环，而不是一次性移除所有旧业务代码。

## 已完成能力

### 资料学习区

- 三类核心学习流：课程资源、工具/Skill、本地知识沉淀。
- 五组资源目录：视频资源、常用 Skill、MCP 工具、本地 RAG 资料、算法与模型。
- 资源搜索和类型筛选。
- 外部课程链接打开和资源入口复制。
- 学习进度持久化。
- 本地 RAG 分块检索；Markdown 标题、列表项和引用行会作为分块边界，减少学习笔记结构被合并到同一证据片段。
- 本地 RAG 回答草稿：基于 Top 检索分块生成可追溯摘要、引用和依据片段。
- 本地 RAG 检索计划：展示查询意图、关键词 token、候选召回数量、上下文证据预算和当前检索策略；重复关键词会在检索与计划生成前归一化去重，逗号、顿号、分号、斜杠和竖线等常见分隔符也会作为关键词边界，避免重复输入放大排序分数。
- 本地 RAG 学习笔记：可复制包含检索计划、回答草稿和引用证据的 Markdown 笔记，也可一键沉淀回本地 RAG 资料库并立即参与后续检索；重复沉淀同一学习笔记时会聚焦已有资料，避免生成重复条目，围绕已保存笔记继续检索时标题保持幂等。
- RAG 资料导入、删除和持久化；持久化读写会归一化标题、来源、摘要、正文和标签，并过滤空标题/空正文资料，重复手动导入会聚焦已有资料而不是生成重复条目，删除后可通过提示操作撤销恢复，已导入列表会展示来源与标签便于整理，标签较多时会显示剩余数量提示且可查看折叠标签，点击已导入资料可快速聚焦检索，也可一键复制为 Markdown 资料卡；已导入资料库可一键复制 Markdown 总览，包含资料数量、来源/标签分布和逐条摘要；检索结果会显示排序原因，检索计划、回答草稿和检索结果片段都可复制为 Markdown 卡片，便于带入笔记或 Prompt。
- 推荐算法原型：按学习目标做本地召回和排序。

### 编程区

- 审计准备进度。
- 审计清单。
- 本地代码规则扫描。
- 扫描规则覆盖硬编码密钥、私钥材料、动态 `eval`、SQL 字符串拼接、命令字符串拼接、明文 HTTP、过宽 CORS 配置、Cookie Secure 关闭、CSRF 防护关闭、JWT none 算法、TLS 校验关闭、弱哈希算法、非加密随机数、调试输出。
- 风险发现展示严重级别、位置、证据、说明和建议。
- Markdown 审计报告复制。
- Markdown 审计报告保存到本地文件。
- Prompt 模板复制。

### 放松区

- 专注/休息计时器。
- 三种节奏：25 分钟专注、5 分钟短休息、15 分钟长休息。
- 节奏记录持久化。
- 最近记录、次数和累计分钟统计。
- 节奏历史可一键复制为 Markdown 总结，便于放入学习复盘或日志。

### 平台身份

- 应用标题、托盘提示、退出确认文案更新为 `人人都是程序员`。
- README 改写为程序员学习平台说明。
- `pubspec.yaml` 描述和 MSIX 显示名已更新。
- 平台模式下默认跳过旧插件、Bangumi、弹幕、下载和更新检查等启动服务。
- 界面设置页移除了旧番剧评分开关，只保留平台启动页选择。
- Windows 初始窗口标题、桌面快捷方式名称、单实例互斥锁和版本信息已改为平台身份。
- Windows Release 可执行文件名已改为 `everyone_is_programmer.exe`。

## 本地持久化数据

使用现有 Hive `setting` box 保存轻量平台数据：

- `platformRagDocuments`
- `platformCompletedLearningResources`
- `platformRelaxSessions`

这样避免新增 Hive adapter 和迁移成本，适合作为 MVP。

## 测试与构建

最近一次验证结果：

- `flutter test`：通过，54 个测试全部通过。
- `flutter build windows`：通过。
- Windows 构建产物：`build\windows\x64\runner\Release\everyone_is_programmer.exe`

补充验证：

- 平台区 widget 测试已用内存依赖隔离报告历史和放松节奏持久化，避免 smoke test 依赖本机 `path_provider` / Hive 状态。

已知非致命提示：

- `Nuget is not installed`
- `webview_windows` CMake warning
- Local RAG search now treats non-positive result limits as explicit empty result sets, so callers can disable retrieval or clamp candidate windows without relying on implicit `take(limit)` behavior.
- Local RAG document chunking now treats English periods and line breaks as body evidence boundaries, so imported notes produce smaller searchable snippets for sentence-style content.
- Local RAG document chunking now treats Markdown headings, list items, and blockquote lines as body evidence boundaries, so imported notes keep review sections and action items as focused snippets.
- Local RAG search results now include ranking reasons in the preview card and copied Markdown, showing matched fields, matched tags, best evidence chunk, and score.
- Learning progress can now be copied as a `学习进度复盘` Markdown review with generated time, completed count, completion percentage, resource type distribution, and completed resource entries.
- Learning progress can now be cleared from the progress panel with snackbar undo, restoring the previous completed resource set when tapped.
- Learning recommendations are now progress-aware: completed resource ids are filtered before ranking, so the recommendation panel behaves more like a next-step list.
- Learning recommendations can now be copied as a `学习推荐清单` Markdown artifact with the selected goal, completed-resource count, recommendation scores, reasons, tags, and entry links.
- Learning recommendation goals now show a completion empty state when every matching resource has already been marked done.
- Local code audit now flags enabled debug mode such as `debug: true`, `debugMode = true`, and `.debug = true` as a medium-severity hardening issue.
- Code audit report history entries can now be deleted from the coding zone, removing the saved Markdown file and refreshing the list.
- Code audit report deletion now supports snackbar undo, restoring the deleted Markdown file and refreshing report history when tapped.
- Relax session Markdown summaries now include rhythm distribution, showing counts and total minutes per focus/rest rhythm.
- Relax session history now shows the same rhythm distribution in the panel, including the empty `无` state before records exist.
- Relax session history clearing now supports snackbar undo, restoring the cleared records and persisted storage when tapped.
- Local RAG chunk scoring now boosts exact multi-token phrase matches, so evidence containing `conflict merge` ranks ahead of chunks that only match the words separately.
- Local RAG phrase scoring now tolerates technical separators between phrase tokens, so `conflict-merge` can rank as adjacent evidence for a `conflict merge` query.
- Local RAG retrieval plans now clamp negative candidate/context limits to zero before rendering plan chips, evidence budgets, or Markdown study notes.
- Local RAG answer drafts now explain when the context evidence budget is zero, instead of presenting the skipped retrieval as a no-hit result.
- Local RAG query tokenization now treats English and Chinese colons as title separators, so saved note titles such as `RAG 学习笔记：BM25:Embedding` continue to retrieve the underlying technical keywords.
- Local RAG query tokenization now treats plus signs as technical separators, so compact queries such as `BM25+Embedding+RAG` retrieve each underlying keyword.
- Local RAG query tokenization now treats hyphens as technical separators, so compact queries such as `BM25-Embedding-RAG` retrieve each underlying keyword.
- Local RAG query tokenization now treats ampersands as technical separators, so compact queries such as `BM25&Embedding&RAG` retrieve each underlying keyword.
- Local RAG query tokenization now treats half-width and full-width parentheses as title separators, so compact note titles such as `RAG(BM25)Embedding` and `RAG（BM25）Embedding` retrieve each underlying keyword.
- Local RAG query tokenization now treats half-width, full-width, and Chinese label brackets as title separators, so note titles such as `[BM25]Embedding` and `【RAG】BM25` retrieve each underlying keyword.
- Local RAG query tokenization now treats angle brackets and Chinese book-title quotes as title separators, so note titles such as `<RAG>BM25` and `《BM25》Embedding` retrieve each underlying keyword.
- Local RAG query tokenization now treats underscores as technical/file-name separators, so note titles such as `BM25_Embedding_RAG` retrieve each underlying keyword.
- Local RAG query tokenization now treats dots as technical/file-name separators, so note titles such as `BM25.Embedding.RAG` retrieve each underlying keyword.
- Local RAG query tokenization now treats backslashes as Windows/file-path separators, so note titles such as `RAG\BM25\Embedding` retrieve each underlying keyword.
- Local RAG query tokenization now treats hash signs as tag separators, so note titles such as `RAG#BM25#Embedding` retrieve each underlying keyword.
- Local RAG query tokenization now treats equals signs and Unicode arrows as flow separators, so prompt notes such as `BM25=>Embedding→RAG` retrieve each underlying keyword.
- 并行 Flutter test 可能撞 native asset 临时文件锁，顺序重跑可恢复。

## 仍然保留的旧内容

原 Kazumi 的大量模块仍在工程中，包括但不限于：

- 番剧播放相关页面和控制器
- Bangumi 同步
- 弹幕、播放器、下载
- 插件/规则系统
- 部分旧设置项
- 原图标与部分平台工程标识

这些没有在本阶段强行删除，因为它们和启动、依赖、平台构建仍有耦合。后续拆除应分阶段进行。

## 推荐后续路线

### 阶段 1：人工验收

按 `docs/qa/2026-05-31-manual-acceptance-checklist.md` 启动应用逐项检查。

### 阶段 2：旧模块隔离

把旧番剧/播放器/插件功能从主路由、设置和初始化流程中进一步隔离。

当前已完成启动流程的第一层隔离：旧服务默认不再主动初始化。Windows 原生入口和 Release 可执行文件名也已开始改名。后续仍需继续清理旧设置路由、Dart 包名、图标资源和未使用依赖。

### 阶段 3：RAG 增强

把当前关键词检索和回答草稿继续升级为：

- 更完整的文档分块策略
- BM25/向量混合检索
- Embedding 接口
- 重排
- 模型问答生成提示链

### 阶段 4：代码审计增强

已补齐：

- 文件/目录导入
- 规则配置
- 报告历史管理
- 报告历史会按文件名前缀标识片段审计和项目审计，便于区分 `code_audit_*.md` 与 `project_code_audit_*.md`
- AI 审计接口占位
- 修复建议模板
- 项目级 Markdown 审计报告：保存时包含扫描路径、已扫描/跳过文件数、启用规则、严重级别统计和风险发现，文件名使用 `project_code_audit_*.md`
- 审计报告历史复用：历史列表区分片段审计/项目审计，仓储层可按报告类型过滤，编程区 UI 可在全部/片段/项目历史之间切换，并支持直接复制 Markdown 报告或复制本地路径

### 阶段 5：品牌与安装包收口

进一步替换：

- 应用图标
- 可执行文件名
- 包名
- 平台安装元数据
- 旧 Kazumi 文案和截图资源

当前阶段 5 已继续收口 Windows 原生运行时标识：外部播放器临时 M3U8 文件名前缀已从 `kazumi_stream_` 改为 `everyone_is_programmer_stream_`；窗口标题、单实例互斥锁、快捷方式 AUMID 后缀和版本资源也已由边界测试守住；更新器在 URL 缺少文件名时的兜底安装包名也已从 `Kazumi-...` 改为 `everyone_is_programmer-...`；Android 后台下载服务通知 channel id 已从 `kazumi_download_channel` 改为 `everyone_is_programmer_download_channel`；音频服务的 Linux MPRIS D-Bus 名称、MPRIS identity、Android 音频通知 channel id/name 已从 Kazumi 播放标识改为 Everyone Is Programmer 播放标识。包名、MethodChannel 名称、图标资源和旧截图资源仍需分批处理。
