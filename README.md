# 人人都是程序员

一个基于 Flutter 的程序员学习平台，面向自学、项目实践和长期节奏管理。当前版本把原有 Flutter 桌面/移动端壳改造成三个主要区域：资料学习区、编程区、放松区。

## 三大区域

### 资料学习区

- 视频资源：CS50、MIT 6.006、FreeCodeCamp 等课程入口。
- 常用 Skill：TDD、系统化调试、代码审查等 Agent 工作流。
- MCP 工具：Context7、Filesystem MCP、GitHub MCP。
- 本地 RAG：支持导入标题、来源、摘要、内容和标签，并持久化到本地 Hive 设置盒。
- RAG 分块检索与回答草稿：根据当前问题召回本地资料分块，生成带引用和检索依据的可追溯回答。
- 推荐算法原型：按编程基础、本地 RAG、代码审计、推荐算法目标进行本地召回和排序。
- 学习进度：资源可标记完成，并持久化保存。

### 编程区

- 审计清单：导入项目、规则扫描、AI 审计、生成报告。
- 本地规则扫描：识别硬编码密钥、动态 `eval`、明文 HTTP、调试输出。
- Markdown 审计报告：可复制风险统计、位置、证据和修复建议。
- 报告保存：可把 Markdown 审计报告保存到本地应用支持目录。
- Prompt 模板：安全审计、学习复盘、推荐模型设计。

### 放松区

- 专注计时：25 分钟专注、5 分钟短休息、15 分钟长休息。
- 节奏记录：记录完成的专注/休息会话，统计次数和累计分钟数。
- 本地持久化：节奏记录保存到 Hive 设置盒。

## 本地数据

当前平台使用已有 Hive `setting` box 保存轻量数据：

- `platformRagDocuments`：用户导入的 RAG 资料。
- `platformCompletedLearningResources`：已完成学习资源 id。
- `platformRelaxSessions`：专注/休息节奏记录。

这些数据是本地优先的 MVP 设计，后续可以替换为更完整的知识库索引、向量检索或云同步。

## 旧模块隔离

项目仍保留原 Kazumi 的历史代码和依赖，但平台模式下启动流程默认不再主动初始化旧插件、Bangumi 同步、弹幕屏蔽、下载后台服务和自动更新检查。这样可以先保证三大区平台体验稳定，再分阶段拆除旧业务模块。

Windows 原生入口也已开始收口：初始窗口标题、单实例互斥锁、桌面快捷方式名称、版本信息和 Release 可执行文件名使用 `人人都是程序员` 平台身份。Dart package name 暂未大范围重命名，以降低现阶段构建风险。

依赖收口记录见 `docs/plans/platform-dependency-audit.md`。当前策略是先守住默认平台入口，再分批移除 legacy 源码和对应依赖。

## 开发与验证

常用命令：

```bash
flutter test
dart analyze lib/pages/platform test
flutter build windows
```

当前新增平台功能有对应测试覆盖，包括：

- 三大区页面和路由。
- 学习资源目录、进度仓储。
- 本地 RAG 分块检索、回答草稿和持久化仓储。
- 推荐算法原型。
- 本地代码审计规则和 Markdown 报告。
- 本地代码审计报告保存。
- 放松节奏记录仓储。
- 平台身份常量。
- 平台默认模块、设置模块和启动页的旧业务隔离边界。

## 构建说明

项目仍保留原 Flutter 多端工程结构，可在 Windows、Android、macOS、Linux、iOS 等 Flutter 支持平台上继续演进。当前验证重点放在 Windows：

```bash
flutter build windows
```

构建产物默认位于：

```text
build/windows/x64/runner/Release/everyone_is_programmer.exe
```

## 变更日志

详细实现思路、每一步为什么做、想实现什么功能、验证结果，记录在：

```text
docs/dev-log/2026-05-28-programmer-learning-platform-log.md
```

## 许可证

本项目继承原工程许可证，详见 `LICENSE`。
