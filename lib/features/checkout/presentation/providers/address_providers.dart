import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/checkout/data/address_repository.dart';
import 'package:naqirgiftbox/features/checkout/domain/entities/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(HiveBoxes.addresses),
);

class AddressListNotifier extends Notifier<List<Address>> {
  late AddressRepository _repository;

  @override
  List<Address> build() {
    _repository = ref.watch(addressRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> save(Address address) async {
    await _repository.save(address);
    state = _repository.getAll();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = _repository.getAll();
  }
}

final addressListProvider =
    NotifierProvider<AddressListNotifier, List<Address>>(
      AddressListNotifier.new,
    );

/// Selected address for the current checkout session (not persisted —
/// resets each time checkout is entered).
final selectedAddressIdProvider = StateProvider<String?>((ref) => null);
