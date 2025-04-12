import 'dart:async';

extension FutureTimeout on Future {
  Future addTimeout<T>(Duration duration, {FutureOr<T> Function()? onTimeout}) {
    if (duration == Duration.zero) return this;
    return timeout(duration, onTimeout: onTimeout);
  }
}
