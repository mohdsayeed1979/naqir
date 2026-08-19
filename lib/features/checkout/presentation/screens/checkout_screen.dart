import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/checkout/presentation/providers/address_providers.dart';
import 'package:naqirgiftbox/features/orders/domain/entities/order.dart';
import 'package:naqirgiftbox/features/orders/presentation/providers/orders_providers.dart';
import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';
import 'package:naqirgiftbox/features/payment/presentation/providers/payment_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class ShippingOption {
  const ShippingOption({
    required this.id,
    required this.label,
    required this.fee,
    required this.eta,
  });

  final String id;
  final String label;
  final double fee;
  final String eta;
}

const shippingOptions = [
  ShippingOption(
    id: 'standard',
    label: 'Standard shipping',
    fee: 15,
    eta: '2–4 business days',
  ),
  ShippingOption(
    id: 'express',
    label: 'Express shipping',
    fee: 30,
    eta: '1 business day',
  ),
];

const _freeShippingThreshold = 200.0;

const _paymentLabels = {
  PaymentMethodType.cashOnDelivery: 'Cash on Delivery',
  PaymentMethodType.creditCard: 'Credit / Debit Card',
  PaymentMethodType.applePay: 'Apple Pay',
  PaymentMethodType.googlePay: 'Google Pay',
};

// App Store review (2026): card payments, Apple Pay and Google Pay are
// intentionally NOT offered in this release. They were previously shown as
// selectable options backed by [UnconfiguredGateway], which always fails —
// Apple's reviewer selected Apple Pay/Card and saw the failure
// ("failed to load card payments or Apple Pay", Guideline 2.1(a)).
//
// Only genuinely working methods are listed here. The gateway abstraction,
// DI registrations and PaymentMethodType enum are all preserved intact — to
// re-enable a method later, wire in its real gateway (see
// docs/ARCHITECTURE.md §8) and add it back to this list. Do NOT add a method
// here until its gateway is fully functional and verified.
const _enabledPaymentMethods = [PaymentMethodType.cashOnDelivery];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String _selectedShippingId = shippingOptions.first.id;
  PaymentMethodType _selectedPayment = PaymentMethodType.cashOnDelivery;
  bool _isPlacingOrder;
  String? _errorMessage;

  _CheckoutScreenState() : _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final addresses = ref.watch(addressListProvider);
    final cart = ref.watch(cartProvider);

    _selectedAddressId ??=
        addresses.where((a) => a.isDefault).firstOrNull?.id ??
        addresses.firstOrNull?.id;

    final shipping = shippingOptions.firstWhere(
      (s) => s.id == _selectedShippingId,
    );
    final shippingFee =
        (shipping.id == 'standard' && cart.subtotal >= _freeShippingThreshold)
        ? 0.0
        : shipping.fee;
    final total = cart.total + shippingFee;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionCard(
            title: l10n.checkoutAddressBook,
            trailing: TextButton(
              onPressed: () => context.push(RoutePaths.addAddress),
              child: Text(l10n.checkoutAddAddress),
            ),
            child: addresses.isEmpty
                ? Text(
                    l10n.checkoutAddAddress,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    children: addresses
                        .map(
                          (address) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: address.id,
                            // ignore: deprecated_member_use
                            groupValue: _selectedAddressId,
                            // ignore: deprecated_member_use
                            onChanged: (value) =>
                                setState(() => _selectedAddressId = value),
                            title: Text(
                              '${address.label} — ${address.fullName}',
                            ),
                            subtitle: Text(
                              '${address.streetAddress}, ${address.district}, ${address.city}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.checkoutShippingMethod,
            child: Column(
              children: shippingOptions
                  .map(
                    (option) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: option.id,
                      // ignore: deprecated_member_use
                      groupValue: _selectedShippingId,
                      // ignore: deprecated_member_use
                      onChanged: (value) =>
                          setState(() => _selectedShippingId = value!),
                      title: Text(option.label),
                      subtitle: Text(option.eta),
                      secondary: Text(
                        option.id == 'standard' &&
                                cart.subtotal >= _freeShippingThreshold
                            ? 'Free'
                            : 'SAR ${option.fee.toStringAsFixed(0)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.checkoutPaymentMethod,
            child: Column(
              children: _enabledPaymentMethods
                  .map(
                    (method) => RadioListTile<PaymentMethodType>(
                      contentPadding: EdgeInsets.zero,
                      value: method,
                      // ignore: deprecated_member_use
                      groupValue: _selectedPayment,
                      // ignore: deprecated_member_use
                      onChanged: (value) =>
                          setState(() => _selectedPayment = value!),
                      title: Text(_paymentLabels[method]!),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.checkoutOrderSummary,
            child: Column(
              children: [
                _SummaryLine(label: l10n.cartSubtotal, value: cart.subtotal),
                if (cart.couponDiscount > 0)
                  _SummaryLine(
                    label: l10n.cartDiscount,
                    value: -cart.couponDiscount,
                  ),
                _SummaryLine(label: l10n.cartShipping, value: shippingFee),
                const Divider(),
                _SummaryLine(
                  label: l10n.cartTotal,
                  value: total,
                  emphasize: true,
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.checkoutPlaceOrder,
            isLoading: _isPlacingOrder,
            onPressed: _selectedAddressId == null
                ? null
                : () => _placeOrder(cart.total, shippingFee),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _placeOrder(double cartTotal, double shippingFee) async {
    final addresses = ref.read(addressListProvider);
    final address = addresses.firstWhere((a) => a.id == _selectedAddressId);
    final cart = ref.read(cartProvider);

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    final orderId = 'order-${DateTime.now().millisecondsSinceEpoch}';
    final total = cartTotal + shippingFee;
    final gateway = ref
        .read(paymentGatewayFactoryProvider)
        .resolve(_selectedPayment);
    final result = await gateway.pay(
      PaymentRequest(orderId: orderId, amount: total, currency: 'SAR'),
    );

    if (!mounted) return;

    await result.when(
      success: (_) async {
        final order = Order(
          id: orderId,
          items: cart.items
              .map(
                (item) => OrderItem(
                  productId: item.productId,
                  productName: item.productName,
                  productImage: item.productImage,
                  unitPrice: item.unitPrice,
                  quantity: item.quantity,
                  variantLabel: item.variantLabel,
                ),
              )
              .toList(),
          subtotal: cart.subtotal,
          discount: cart.couponDiscount,
          shippingFee: shippingFee,
          total: total,
          shippingAddress: address,
          shippingMethodLabel: shippingOptions
              .firstWhere((s) => s.id == _selectedShippingId)
              .label,
          status: OrderStatus.placed,
          placedAt: DateTime.now(),
        );
        await ref.read(ordersProvider.notifier).placeOrder(order);
        await ref.read(cartProvider.notifier).clear();
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        context.go(RoutePaths.orderDetailPath(orderId));
      },
      failure: (failure) async {
        setState(() {
          _isPlacingOrder = false;
          _errorMessage = failure.message;
        });
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
