import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/authentication/domain/entities/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    String? phone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
abstract class AuthResultDto with _$AuthResultDto {
  const factory AuthResultDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required UserDto user,
  }) = _AuthResultDto;

  factory AuthResultDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResultDtoFromJson(json);
}

extension UserDtoMapper on UserDto {
  User toEntity() => User(
    id: id,
    fullName: fullName,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
  );
}
