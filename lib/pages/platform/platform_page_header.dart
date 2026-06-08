import 'package:flutter/material.dart';

class PlatformPageHeader extends StatelessWidget {
  const PlatformPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onOpenSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          tooltip: '平台设置',
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}
