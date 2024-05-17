typedef FutureVoidCallback = Future<void> Function();

/// Class to wrap a future instead of throwing an exception.
/// Useful to wrap futures coming from a provider.
class FutureRes<V, E> {
  final V? value;
  final E? error;

  FutureRes._(this.value, this.error);

  factory FutureRes.value(V value) {
    return FutureRes._(value, null);
  }

  factory FutureRes.error(E error) {
    return FutureRes._(null, error);
  }

  bool get isError => error != null;
}

/// Extention on [Future] to automatically wrap them in a [FutureRes]
extension MapFutureRes<T> on Future<T> {
  Future<FutureRes<T, Object?>> mapRes() {
    return then((value) => FutureRes.value(value))
        .onError((error, stackTrace) => FutureRes<T, Object?>.error(error));
  }
}
