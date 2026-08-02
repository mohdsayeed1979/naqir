import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';

/// One implementation per payment method — see docs/ARCHITECTURE.md §8 for
/// why the native SDKs (flutter_stripe, etc.) aren't wired in yet. Adding a
/// live gateway later is: implement this interface, register it in
/// [PaymentGatewayFactory], done — no checkout UI changes required.
abstract class PaymentGateway {
  PaymentMethodType get type;

  Future<Result<PaymentOutcome>> pay(PaymentRequest request);
}
