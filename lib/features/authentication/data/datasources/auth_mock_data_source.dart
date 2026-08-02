import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/models/user_dto.dart';

/// Accepts any well-formed input and fabricates a session — there is no real
/// backend to authenticate against yet (see docs/ARCHITECTURE.md §1). OTP is
/// "verified" by accepting any 4-digit code.
class AuthMockDataSource implements AuthDataSource {
  String _tokenFor(String subject) => 'mock-access-token-$subject';

  @override
  Future<AuthResultDto> login({
    required String emailOrPhone,
    required String password,
  }) async {
    await _simulateLatency();
    if (password.length < 4) {
      throw const ValidationException(
        'Incorrect email/phone or password.',
        fieldErrors: {'password': 'Incorrect email/phone or password.'},
      );
    }
    return _buildResult(
      emailOrPhone.contains('@') ? emailOrPhone : 'guest@naqirgiftbox.com',
      name: 'Sarah Al-Qahtani',
    );
  }

  @override
  Future<AuthResultDto> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _simulateLatency();
    return _buildResult(email, name: fullName);
  }

  @override
  Future<void> requestOtp({required String phone}) async {
    await _simulateLatency();
  }

  @override
  Future<AuthResultDto> verifyOtp({
    required String phone,
    required String code,
  }) async {
    await _simulateLatency();
    if (code.length != 4) {
      throw const ValidationException(
        'Enter the 4-digit code sent to your phone.',
      );
    }
    return _buildResult(phone, name: 'Sarah Al-Qahtani', phone: phone);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _simulateLatency();
  }

  @override
  Future<UserDto> updateProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    await _simulateLatency();
    return UserDto(id: userId, fullName: fullName, email: email, phone: phone);
  }

  AuthResultDto _buildResult(
    String subject, {
    required String name,
    String? phone,
  }) {
    return AuthResultDto(
      accessToken: _tokenFor(subject),
      refreshToken: 'mock-refresh-token-$subject',
      user: UserDto(
        id: 'user-${subject.hashCode.abs()}',
        fullName: name,
        email: subject.contains('@') ? subject : 'guest@naqirgiftbox.com',
        phone: phone,
      ),
    );
  }

  Future<void> _simulateLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));
}
