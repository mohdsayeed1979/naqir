import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';

/// Renders a static content page (About, Privacy Policy, Terms). Body copy
/// is English-only for now — translating legal text accurately needs the
/// business's own review, not a best-effort machine translation, so it's
/// left as a deliberate follow-up rather than guessed.
class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({
    required this.title,
    required this.sections,
    super.key,
  });

  final String title;
  final List<(String heading, String body)> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final (heading, body) = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (heading.isNotEmpty) ...[
                Text(heading, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
