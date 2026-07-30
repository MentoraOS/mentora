enum StartupStatus { unauthenticated, ready, failure }

final class StartupResult {
  const StartupResult._({required this.status, this.error, this.stackTrace});

  const StartupResult.unauthenticated()
    : this._(status: StartupStatus.unauthenticated);

  const StartupResult.ready() : this._(status: StartupStatus.ready);

  const StartupResult.failure({
    required Object error,
    required StackTrace stackTrace,
  }) : this._(
         status: StartupStatus.failure,
         error: error,
         stackTrace: stackTrace,
       );

  final StartupStatus status;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isUnauthenticated => status == StartupStatus.unauthenticated;
  bool get isReady => status == StartupStatus.ready;
  bool get isFailure => status == StartupStatus.failure;
}
