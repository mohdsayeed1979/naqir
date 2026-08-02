import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';
import 'package:naqirgiftbox/features/payment/domain/repositories/payment_gateway.dart';

class PaymentGatewayFactory {
  PaymentGatewayFactory(this._gateways);

  final Map<PaymentMethodType, PaymentGateway> _gateways;

  PaymentGateway resolve(PaymentMethodType type) {
    final gateway = _gateways[type];
    if (gateway == null) {
      throw StateError('No gateway registered for $type.');
    }
    return gateway;
  }

  List<PaymentMethodType> get availableMethods => PaymentMethodType.values;
}
