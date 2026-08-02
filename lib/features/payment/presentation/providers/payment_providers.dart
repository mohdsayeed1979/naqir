import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/features/payment/data/repositories/payment_gateway_factory.dart';

final paymentGatewayFactoryProvider = Provider<PaymentGatewayFactory>(
  (ref) => getIt<PaymentGatewayFactory>(),
);
