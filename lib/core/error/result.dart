import 'package:naqirgiftbox/core/error/failures.dart';

/// Lightweight Result type used instead of a functional-programming package
/// (dartz/fpdart) — Dart 3 sealed classes + pattern matching already give us
/// exhaustiveness checking, so `when` below is the one bit of ergonomics
/// worth keeping.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultError<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultError<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    ResultError<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultError<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    Success<T>(:final data) => success(data),
    ResultError<T>(failure: final f) => failure(f),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultError<T> extends Result<T> {
  const ResultError(this.failure);

  final Failure failure;
}
