import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/authentication/domain/entities/user.dart';
import 'package:naqirgiftbox/features/authentication/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

/// `null` (once loaded) means signed out. `AsyncLoading` only happens once,
/// on the very first read, while the cached session is checked.
class AuthNotifier extends AsyncNotifier<User?> {
  late AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.getCachedUser();
  }

  bool get isAuthenticated => state.valueOrNull != null;

  Future<Result<User>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final result = await _repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (_) {},
    );
    return result;
  }

  Future<Result<User>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final result = await _repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (_) {},
    );
    return result;
  }

  Future<Result<void>> requestOtp({required String phone}) =>
      _repository.requestOtp(phone: phone);

  Future<Result<User>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final result = await _repository.verifyOtp(phone: phone, code: code);
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (_) {},
    );
    return result;
  }

  Future<Result<void>> forgotPassword({required String email}) =>
      _repository.forgotPassword(email: email);

  Future<Result<User>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final result = await _repository.updateProfile(
      fullName: fullName,
      phone: phone,
    );
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (_) {},
    );
    return result;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  /// Permanently deletes the account. Only drops the session to the
  /// signed-out state on a genuine success — on failure the user stays
  /// authenticated and the caller surfaces the error.
  Future<Result<void>> deleteAccount() async {
    final result = await _repository.deleteAccount();
    result.when(
      success: (_) => state = const AsyncValue.data(null),
      failure: (_) {},
    );
    return result;
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
