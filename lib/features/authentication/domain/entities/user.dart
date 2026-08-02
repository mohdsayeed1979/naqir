import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String fullName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) = _User;
}
