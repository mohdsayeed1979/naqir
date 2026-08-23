import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String emailOrPhone,
    required String password,
  });

  Future<Result<User>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> requestOtp({required String phone});

  Future<Result<User>> verifyOtp({required String phone, required String code});

  Future<Result<void>> forgotPassword({required String email});

  Future<Result<User>> updateProfile({required String fullName, String? phone});

  /// Rehydrates the session from local cache — no network call, so app
  /// launch never blocks on connectivity to know if a user is logged in.
  Future<User?> getCachedUser();

  Future<void> logout();

  /// Permanently deletes the signed-in user's account and erases every
  /// user-owned record on the device. On any failure the account and local
  /// data are left intact and the user stays signed in — never reports a
  /// false success. See docs/ACCOUNT_DELETION.md.
  Future<Result<void>> deleteAccount();
}
