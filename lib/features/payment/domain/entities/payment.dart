import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

enum PaymentMethodType { cashOnDelivery, creditCard, applePay, googlePay }

@freezed
abstract class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String orderId,
    required double amount,
    required String currency,
  }) = _PaymentRequest;
}

@freezed
abstract class PaymentOutcome with _$PaymentOutcome {
  const factory PaymentOutcome({required bool success, String? transactionId}) =
      _PaymentOutcome;
}
