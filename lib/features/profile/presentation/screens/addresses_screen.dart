import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/checkout/domain/entities/address.dart';
import 'package:naqirgiftbox/features/checkout/presentation/providers/address_providers.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addresses = ref.watch(addressListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileAddresses)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.addAddress),
        icon: const Icon(Icons.add),
        label: Text(l10n.checkoutAddAddress),
      ),
      body: addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_on_outlined,
              title: l10n.checkoutAddressBook,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  _AddressCard(address: addresses[index]),
            ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  const _AddressCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(address.label, style: theme.textTheme.titleSmall),
                if (address.isDefault) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Default',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () =>
                      ref.read(addressListProvider.notifier).delete(address.id),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${address.fullName} · ${address.phone}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${address.streetAddress}, ${address.district}, ${address.city}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
