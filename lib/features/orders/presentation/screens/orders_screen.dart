import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/orders/domain/entities/order.dart';
import 'package:naqirgiftbox/features/orders/presentation/providers/orders_providers.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.ordersEmpty,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: () => context.push(RoutePaths.orderDetailPath(order.id)),
        title: Text(
          '#${order.id.split('-').last}',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(DateFormat.yMMMd().add_jm().format(order.placedAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'SAR ${order.total.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall,
            ),
            _StatusChip(status: order.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      OrderStatus.placed => ('Placed', theme.colorScheme.tertiary),
      OrderStatus.confirmed => ('Confirmed', theme.colorScheme.primary),
      OrderStatus.shipped => ('Shipped', theme.colorScheme.primary),
      OrderStatus.delivered => ('Delivered', Colors.green),
      OrderStatus.cancelled => ('Cancelled', theme.colorScheme.error),
    };
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
