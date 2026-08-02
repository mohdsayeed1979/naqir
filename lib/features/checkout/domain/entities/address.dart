import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

/// Local-only device state persisted as JSON, same rationale as [Cart] —
/// there is no address-book endpoint yet.
@freezed
abstract class Address with _$Address {
  const factory Address({
    required String id,
    required String label,
    required String fullName,
    required String phone,
    required String city,
    required String district,
    required String streetAddress,
    String? buildingNumber,
    String? additionalDirections,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
