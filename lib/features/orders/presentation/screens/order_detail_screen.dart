import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/features/orders/domain/entities/order.dart';
import 'package:naqirgiftbox/features/orders/presentation/providers/orders_providers.dart';
import 'package:naqirgiftbox/shared/widgets/app_image.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final order = ref.watch(orderByIdProvider(orderId));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetailsTitle)),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.commonNoResultsFound,
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('#${order.id.split('-').last}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(l10n.orderTrackingTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _TrackingTimeline(status: order.status),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      child: Row(
                        children: [
                          AppImage(
                            item.productImage,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${item.productName} × ${item.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text('SAR ${item.lineTotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: AppSpacing.lg),
                  _Line(label: l10n.cartSubtotal, value: order.subtotal),
                  if (order.discount > 0)
                    _Line(label: l10n.cartDiscount, value: -order.discount),
                  _Line(label: l10n.cartShipping, value: order.shippingFee),
                  const Divider(),
                  _Line(
                    label: l10n.cartTotal,
                    value: order.total,
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.checkoutAddressBook,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${order.shippingAddress.fullName} · ${order.shippingAddress.phone}',
                  ),
                  Text(
                    '${order.shippingAddress.streetAddress}, ${order.shippingAddress.district}, '
                    '${order.shippingAddress.city}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    order.shippingMethodLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            DateFormat.yMMMMd().add_jm().format(order.placedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.status});

  final OrderStatus status;

  static const _steps = [
    (OrderStatus.placed, 'Order placed', Icons.receipt_long_outlined),
    (OrderStatus.confirmed, 'Confirmed', Icons.check_circle_outline_rounded),
    (OrderStatus.shipped, 'Shipped', Icons.local_shipping_outlined),
    (OrderStatus.delivered, 'Delivered', Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _steps
        .indexWhere((s) => s.$1 == status)
        .clamp(0, _steps.length - 1);

    return Row(
      children: List.generate(_steps.length, (index) {
        final (_, label, icon) = _steps[index];
        final isDone = index <= currentIndex;
        final color = isDone
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(child: Divider(color: color, thickness: 2)),
                  Icon(icon, color: color, size: 22),
                  if (index < _steps.length - 1)
                    Expanded(
                      child: Divider(
                        color: index < currentIndex
                            ? color
                            : theme.colorScheme.outlineVariant,
                        thickness: 2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDone
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value == 0 ? 'Free' : 'SAR ${value.toStringAsFixed(0)}',
            style: style,
          ),
        ],
      ),
    );
  }
}
