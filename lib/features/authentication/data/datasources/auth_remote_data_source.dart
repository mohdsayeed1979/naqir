import 'package:naqirgiftbox/core/constants/api_endpoints.dart';
import 'package:naqirgiftbox/core/network/api_client.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/models/user_dto.dart';

class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthResultDto> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'identifier': emailOrPhone, 'password': password},
    );
    return AuthResultDto.fromJson(response.data!);
  }

  @override
  Future<AuthResultDto> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {'full_name': fullName, 'email': email, 'password': password},
    );
    return AuthResultDto.fromJson(response.data!);
  }

  @override
  Future<void> requestOtp({required String phone}) async {
    await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.otpRequest,
      data: {'phone': phone},
    );
  }

  @override
  Future<AuthResultDto> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.otpVerify,
      data: {'phone': phone, 'code': code},
    );
    return AuthResultDto.fromJson(response.data!);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<UserDto> updateProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.account,
      data: {'full_name': fullName, 'phone': phone},
    );
    return UserDto.fromJson(response.data!);
  }
}
