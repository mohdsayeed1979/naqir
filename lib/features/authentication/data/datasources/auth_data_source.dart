import 'package:naqirgiftbox/features/authentication/data/models/user_dto.dart';

abstract class AuthDataSource {
  Future<AuthResultDto> login({
    required String emailOrPhone,
    required String password,
  });

  Future<AuthResultDto> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> requestOtp({required String phone});

  Future<AuthResultDto> verifyOtp({
    required String phone,
    required String code,
  });

  Future<void> forgotPassword({required String email});

  /// Permanently deletes the authenticated user's server-side account and
  /// data. Authorization is derived server-side from the caller's session
  /// token — the client never sends a user id — so a user can only ever
  /// delete their own account.
  Future<void> deleteAccount();

  Future<UserDto> updateProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  });
}
