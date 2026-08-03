import 'package:flutter/foundation.dart';

import '../logging/foundation_logger.dart';

/// The error boundary of the foundation: every uncaught error — widget
/// layer or platform dispatcher — is reported, never swallowed. It
/// observes and reports; it never decides recovery (that belongs to
/// the surfaces, honestly, per the interaction rules).
final class FoundationErrorHandler {
  final FoundationLogger _logger;

  FoundationErrorHandler({required FoundationLogger logger})
    : _logger = logger;

  void install() {
    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      _logger.log(
        LogLevel.error,
        'Uncaught framework error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
      previousFlutterHandler?.call(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Uncaught platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }
}
