import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';
import 'package:naqirgiftbox/features/payment/domain/repositories/payment_gateway.dart';

/// The one payment method that genuinely needs no merchant account — it's a
/// real, fully working gateway, not a stub.
class CashOnDeliveryGateway implements PaymentGateway {
  @override
  PaymentMethodType get type => PaymentMethodType.cashOnDelivery;

  @override
  Future<Result<PaymentOutcome>> pay(PaymentRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Result.success(
      PaymentOutcome(success: true, transactionId: 'COD-${request.orderId}'),
    );
  }
}
