import 'package:flutter/material.dart';

class CodeAuditStep {
  const CodeAuditStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const codeAuditSteps = [
  CodeAuditStep(
    title: '导入项目',
    description: '选择本地代码目录，建立审计工作区上下文。',
    icon: Icons.drive_folder_upload_outlined,
  ),
  CodeAuditStep(
    title: '规则扫描',
    description: '先用确定性规则发现敏感信息、危险调用和配置风险。',
    icon: Icons.rule_folder_outlined,
  ),
  CodeAuditStep(
    title: 'AI 审计',
    description: '把代码片段、规则结果和上下文交给模型进行复核。',
    icon: Icons.manage_search_outlined,
  ),
  CodeAuditStep(
    title: '生成报告',
    description: '输出风险等级、文件位置、原因说明和修复建议。',
    icon: Icons.assignment_outlined,
  ),
];
