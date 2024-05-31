/// Wrapper class to represent the result of a computation.
/// It can take the form of a value [Result.value]
/// or the form of an error [Result.error].
/// We use it to wrap a future instead of throwing an exception.
/// Useful to wrap futures coming from a provider.
class Result<V, E> {
  final V? value;
  final E? error;

  Result._(this.value, this.error);

  factory Result.value(V value) {
    return Result._(value, null);
  }

  factory Result.error(E error) {
    return Result._(null, error);
  }

  bool get isError => error != null;
}

/// Extention on [Future] to automatically wrap them in a [Result]
/// instead of throwing an error.
extension MapFutureRes<T> on Future<T> {
  Future<Result<T, Object?>> mapRes() {
    return then((value) => Result.value(value))
        .onError((error, stackTrace) => Result<T, Object?>.error(error));
  }
}
