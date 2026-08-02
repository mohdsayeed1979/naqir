import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/features/cart/domain/entities/cart.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/shared/widgets/app_image.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  bool _applyingCoupon = false;
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) return;
    setState(() {
      _applyingCoupon = true;
      _couponError = null;
    });
    final result = await ref
        .read(cartProvider.notifier)
        .applyCoupon(_couponController.text);
    if (!mounted) return;
    setState(() {
      _applyingCoupon = false;
      _couponError = result.success ? null : result.errorMessage;
    });
    if (result.success) _couponController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cartTitle)),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: l10n.cartEmpty,
              message: l10n.cartEmptySubtitle,
              actionLabel: l10n.cartStartShopping,
              onAction: () => context.go(RoutePaths.home),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        _CartItemTile(item: cart.items[index]),
                  ),
                ),
                _CartSummary(
                  cart: cart,
                  couponController: _couponController,
                  applyingCoupon: _applyingCoupon,
                  couponError: _couponError,
                  onApplyCoupon: _applyCoupon,
                ),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImage(
          item.productImage,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.variantLabel != null)
                Text(
                  item.variantLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'SAR ${item.unitPrice.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(item.id, item.quantity - 1),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(item.id, item.quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  const _CartSummary({
    required this.cart,
    required this.couponController,
    required this.applyingCoupon,
    required this.couponError,
    required this.onApplyCoupon,
  });

  final Cart cart;
  final TextEditingController couponController;
  final bool applyingCoupon;
  final String? couponError;
  final VoidCallback onApplyCoupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isAuthenticated = ref.watch(authProvider).valueOrNull != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cart.couponCode == null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: couponController,
                        decoration: InputDecoration(
                          hintText: l10n.cartCouponHint,
                          errorText: couponError,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilledButton(
                      onPressed: applyingCoupon ? null : onApplyCoupon,
                      child: Text(l10n.cartApplyCoupon),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        cart.couponCode!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(cartProvider.notifier).removeCoupon(),
                      child: Text(l10n.commonDelete),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: l10n.cartSubtotal, value: cart.subtotal),
              if (cart.couponDiscount > 0)
                _SummaryRow(
                  label: l10n.cartDiscount,
                  value: -cart.couponDiscount,
                ),
              const Divider(),
              _SummaryRow(
                label: l10n.cartTotal,
                value: cart.total,
                emphasize: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: l10n.cartProceedToCheckout,
                onPressed: () => context.push(
                  isAuthenticated ? RoutePaths.checkout : RoutePaths.login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
          Text('SAR ${value.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}
