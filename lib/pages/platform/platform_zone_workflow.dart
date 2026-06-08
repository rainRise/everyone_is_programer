import 'package:flutter/material.dart';

class PlatformZoneWorkflowStage {
  const PlatformZoneWorkflowStage({
    required this.title,
    required this.zoneLabel,
    required this.description,
    required this.icon,
    required this.outputs,
  });

  final String title;
  final String zoneLabel;
  final String description;
  final IconData icon;
  final List<String> outputs;
}

const platformZoneWorkflow = [
  PlatformZoneWorkflowStage(
    title: '资料输入',
    zoneLabel: '资料学习区',
    description: '先看视频课程、阅读 Skill/MCP 指南，并把关键内容沉淀到本地 RAG。',
    icon: Icons.school_outlined,
    outputs: ['课程笔记', 'Skill 清单', 'RAG 片段'],
  ),
  PlatformZoneWorkflowStage(
    title: '编码实践',
    zoneLabel: '编程区',
    description: '把学习目标变成项目任务，用本地规则扫描、Prompt 模板和审计报告完成实践闭环。',
    icon: Icons.code_outlined,
    outputs: ['项目代码', '审计报告', '复盘 Prompt'],
  ),
  PlatformZoneWorkflowStage(
    title: '节奏恢复',
    zoneLabel: '放松区',
    description: '用专注和休息节奏保护注意力，把长期学习变成可持续的日常系统。',
    icon: Icons.spa_outlined,
    outputs: ['专注记录', '休息计划', '下一轮目标'],
  ),
];
