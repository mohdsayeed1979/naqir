import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';
import 'package:naqirgiftbox/features/payment/domain/repositories/payment_gateway.dart';

/// Stands in for Stripe/Moyasar/HyperPay/Apple Pay/Google Pay until merchant
/// credentials exist and the corresponding native SDK is added — reports a
/// clear, honest failure instead of silently succeeding or crashing.
class UnconfiguredGateway implements PaymentGateway {
  const UnconfiguredGateway(this.type, this.label);

  @override
  final PaymentMethodType type;
  final String label;

  @override
  Future<Result<PaymentOutcome>> pay(PaymentRequest request) async {
    return Result.failure(
      ServerFailure(
        '$label is not connected yet — see docs/ARCHITECTURE.md §8.',
      ),
    );
  }
}
