import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/shared/providers/connectivity_provider.dart';

/// Thin, always-on-top banner shown across every screen when
/// [connectivityStatusProvider] reports no real internet access. Wraps the
/// whole app via `MaterialApp.router`'s `builder`, so no individual screen
/// needs to know about it.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline =
        ref.watch(connectivityStatusProvider).valueOrNull == false;
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: isOffline
              ? SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    color: theme.colorScheme.errorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 14,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).commonNoInternetConnection,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(child: child),
      ],
    );
  }
}
