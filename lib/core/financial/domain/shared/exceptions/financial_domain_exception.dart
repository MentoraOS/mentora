/// Base class for all business-rule failures raised by the financial domain.
///
/// Infrastructure failures (network, database, provider, etc.) must not extend
/// this type because they are not domain failures.
abstract class FinancialDomainException implements Exception {
  const FinancialDomainException({
    required this.code,
    required this.message,
    this.details = const <String, Object?>{},
  });

  /// Stable machine-readable error code.
  final String code;

  /// Human-readable diagnostic message.
  final String message;

  /// Structured diagnostic data. It must never carry required domain state.
  final Map<String, Object?> details;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}
