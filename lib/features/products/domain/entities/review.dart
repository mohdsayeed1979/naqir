import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String authorName,
    required double rating,
    required String comment,
    required DateTime createdAt,
  }) = _Review;
}
