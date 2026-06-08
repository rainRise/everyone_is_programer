import 'package:flutter/material.dart';
import 'package:kazumi/pages/platform/platform_code_audit_catalog.dart';

class CodeAuditPreview extends StatelessWidget {
  const CodeAuditPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '代码审计流程',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (final step in codeAuditSteps) _AuditStepTile(step: step),
      ],
    );
  }
}

class _AuditStepTile extends StatelessWidget {
  const _AuditStepTile({required this.step});

  final CodeAuditStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(step.icon, color: colorScheme.secondary),
        title: Text(step.title),
        subtitle: Text(step.description),
        tileColor: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
