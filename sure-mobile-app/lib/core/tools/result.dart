/// Result type for error handling without exceptions
/// Use this pattern instead of try-catch in domain/data layers
sealed class Result<T> {
  const Result();

  /// Execute different callbacks based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  });

  /// Map success value to a new type
  Result<R> map<R>(R Function(T data) mapper);

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
}

/// Success result containing data
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return success(data);
  }

  @override
  Result<R> map<R>(R Function(T data) mapper) {
    return Success(mapper(data));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failure result containing error message
class Failure<T> extends Result<T> {
  const Failure(this.message);

  final String message;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return failure(message);
  }

  @override
  Result<R> map<R>(R Function(T data) mapper) {
    return Failure(message);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
