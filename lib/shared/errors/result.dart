/// Result type for representing success or failure in async operations
/// Using Either pattern for functional error handling
sealed class Result<T> {
  const Result();

  /// Map success value to another type
  Result<R> map<R>(R Function(T) fn) => switch (this) {
    Success(value: final value) => Success(fn(value)),
    Failure(exception: final exception) => Failure(exception),
  };

  /// Map failure to another type
  Result<T> mapError(T Function(Exception) fn) => switch (this) {
    Success(value: final value) => Success(value),
    Failure(exception: final exception) => Success(fn(exception)),
  };

  /// Get value or null
  T? getOrNull() => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };

  /// Get exception or null
  Exception? getExceptionOrNull() => switch (this) {
    Success() => null,
    Failure(exception: final exception) => exception,
  };

  /// Execute callback on success
  void whenSuccess(void Function(T) fn) {
    if (this is Success) {
      fn((this as Success<T>).value);
    }
  }

  /// Execute callback on failure
  void whenFailure(void Function(Exception) fn) {
    if (this is Failure) {
      fn((this as Failure<T>).exception);
    }
  }
}

/// Success result containing a value
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Failure result containing an exception
class Failure<T> extends Result<T> {
  final Exception exception;

  const Failure(this.exception);

  @override
  String toString() => 'Failure($exception)';
}
