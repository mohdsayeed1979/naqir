import 'package:flutter_test/flutter_test.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/error/result.dart';

void main() {
  group('Result', () {
    test('success exposes data and isSuccess', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure exposes the failure and isFailure', () {
      const failure = NetworkFailure();
      const result = Result<int>.failure(failure);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('when dispatches to the matching branch without mixing them up', () {
      const success = Result<int>.success(7);
      const failure = Result<int>.failure(NetworkFailure());

      expect(
        success.when(success: (d) => 'data:$d', failure: (_) => 'fail'),
        'data:7',
      );
      expect(
        failure.when(
          success: (d) => 'data:$d',
          failure: (f) => 'fail:${f.message}',
        ),
        'fail:No internet connection.',
      );
    });
  });
}
