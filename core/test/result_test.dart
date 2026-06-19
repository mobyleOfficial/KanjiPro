import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Success holds data', () {
    const Result<int> r = Success(42);
    expect((r as Success<int>).data, 42);
  });

  test('FailureResult holds failure', () {
    const Result<int> r = FailureResult<int>(DataFailure('boom'));
    expect((r as FailureResult<int>).failure.message, 'boom');
  });
}
