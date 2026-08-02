import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:naqirgiftbox/features/checkout/domain/entities/address.dart';

class AddressRepository {
  AddressRepository(this._box);

  final Box<String> _box;

  List<Address> getAll() {
    return _box.values
        .map((raw) {
          try {
            return Address.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Address>()
        .toList();
  }

  Future<void> save(Address address) async {
    if (address.isDefault) {
      for (final existing in getAll().where(
        (a) => a.id != address.id && a.isDefault,
      )) {
        await _box.put(
          existing.id,
          jsonEncode(existing.copyWith(isDefault: false).toJson()),
        );
      }
    }
    await _box.put(address.id, jsonEncode(address.toJson()));
  }

  Future<void> delete(String id) => _box.delete(id);
}
