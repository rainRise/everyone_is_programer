import 'package:flutter/material.dart';

class RelaxTool {
  const RelaxTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.minutes,
  });

  final String title;
  final String description;
  final IconData icon;
  final int minutes;
}

const relaxTools = [
  RelaxTool(
    title: '专注 25 分钟',
    description: '用于进入学习或编码状态，结束后建议短休息。',
    icon: Icons.timer_outlined,
    minutes: 25,
  ),
  RelaxTool(
    title: '短休息 5 分钟',
    description: '离开屏幕、补水、活动肩颈，避免连续疲劳。',
    icon: Icons.local_cafe_outlined,
    minutes: 5,
  ),
  RelaxTool(
    title: '长休息 15 分钟',
    description: '适合多个专注周期后恢复注意力和体力。',
    icon: Icons.self_improvement_outlined,
    minutes: 15,
  ),
];
