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

  Future<UserDto> updateProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  });
}
