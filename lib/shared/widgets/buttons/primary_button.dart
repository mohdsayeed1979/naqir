import 'package:flutter/material.dart';

/// Standard full-width call-to-action button with a built-in loading state
/// so screens don't hand-roll a spinner-vs-label switch every time.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: outlined ? Theme.of(context).colorScheme.primary : null,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }
    return FilledButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}
