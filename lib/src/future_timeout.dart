import 'dart:async';

extension FutureTimeout<T> on Future<T> {
  Future<T> addTimeout(Duration duration, {FutureOr<T> Function()? onTimeout}) {
    if (duration == Duration.zero) return this;
    return timeout(duration, onTimeout: onTimeout);
  }
}
