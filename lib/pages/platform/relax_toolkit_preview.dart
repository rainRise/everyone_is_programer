import 'package:flutter/material.dart';
import 'package:kazumi/pages/platform/platform_relax_toolkit.dart';

class RelaxToolkitPreview extends StatelessWidget {
  const RelaxToolkitPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '放松工具箱',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (final tool in relaxTools) _RelaxToolTile(tool: tool),
      ],
    );
  }
}

class _RelaxToolTile extends StatelessWidget {
  const _RelaxToolTile({required this.tool});

  final RelaxTool tool;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(tool.icon, color: colorScheme.secondary),
        title: Text(tool.title),
        subtitle: Text(tool.description),
        tileColor: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
