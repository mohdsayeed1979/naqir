import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';

/// "Title ... See all" row used above every horizontal product/category rail.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(AppLocalizations.of(context).commonSeeAll),
          ),
      ],
    );
  }
}
