import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

/// Maps a [Failure] to a friendly icon/message and a retry action — the one
/// place error-to-copy mapping lives, so every screen shows errors the same
/// way instead of leaking `failure.message` (data-layer text) into the UI.
class ErrorState extends StatelessWidget {
  const ErrorState({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, message) = switch (failure) {
      NetworkFailure() => (
        Icons.wifi_off_rounded,
        l10n.commonNoInternetConnection,
      ),
      UnauthorizedFailure() => (Icons.lock_outline_rounded, failure.message),
      NotFoundFailure() => (
        Icons.search_off_rounded,
        l10n.commonNoResultsFound,
      ),
      _ => (Icons.error_outline_rounded, l10n.commonSomethingWentWrong),
    };

    return EmptyState(
      icon: icon,
      title: message,
      actionLabel: l10n.commonRetry,
      onAction: onRetry,
    );
  }
}
