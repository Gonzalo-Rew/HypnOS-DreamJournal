import 'package:flutter_test/flutter_test.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

void main() {
  group('Result – Success', () {
    test('holds a value', () {
      const result = Success(42);
      expect(result.value, 42);
    });

    test('getOrNull returns the value', () {
      const result = Success('hello');
      expect(result.getOrNull(), 'hello');
    });

    test('getExceptionOrNull returns null', () {
      const result = Success(true);
      expect(result.getExceptionOrNull(), isNull);
    });

    test('map transforms the value', () {
      const result = Success(10);
      final mapped = result.map((v) => v * 2);
      expect(mapped.getOrNull(), 20);
    });

    test('mapError is a no-op on Success', () {
      const result = Success(5);
      final mapped = result.mapError((e) => -1);
      expect(mapped.getOrNull(), 5);
    });

    test('whenSuccess callback is invoked', () {
      var called = false;
      const Success(1).whenSuccess((_) => called = true);
      expect(called, isTrue);
    });

    test('whenFailure callback is NOT invoked on Success', () {
      var called = false;
      const Success(1).whenFailure((_) => called = true);
      expect(called, isFalse);
    });

    test('toString describes value', () {
      expect(const Success(7).toString(), contains('7'));
    });
  });

  group('Result – Failure', () {
    final ex = Exception('boom');

    test('holds an exception', () {
      final result = Failure<int>(ex);
      expect(result.exception, ex);
    });

    test('getOrNull returns null', () {
      final result = Failure<String>(ex);
      expect(result.getOrNull(), isNull);
    });

    test('getExceptionOrNull returns the exception', () {
      final result = Failure<int>(ex);
      expect(result.getExceptionOrNull(), ex);
    });

    test('map propagates the exception without calling fn', () {
      var fnCalled = false;
      final result = Failure<int>(ex);
      final mapped = result.map<String>((v) {
        fnCalled = true;
        return v.toString();
      });
      expect(fnCalled, isFalse);
      expect(mapped, isA<Failure<String>>());
    });

    test('mapError converts failure to Success', () {
      final result = Failure<int>(ex);
      final recovered = result.mapError((_) => -99);
      expect(recovered.getOrNull(), -99);
    });

    test('whenFailure callback is invoked', () {
      var called = false;
      Failure<int>(ex).whenFailure((_) => called = true);
      expect(called, isTrue);
    });

    test('whenSuccess callback is NOT invoked on Failure', () {
      var called = false;
      Failure<int>(ex).whenSuccess((_) => called = true);
      expect(called, isFalse);
    });
  });
}
