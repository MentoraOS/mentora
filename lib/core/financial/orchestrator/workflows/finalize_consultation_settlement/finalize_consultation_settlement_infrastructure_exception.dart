import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

/// Critical infrastructure failure encountered while finalizing
/// a consultation settlement.
///
/// This exception represents a Runtime infrastructure failure such as:
///
/// - transaction begin failure;
/// - transaction commit failure;
/// - transaction rollback failure;
/// - unavailable persistence infrastructure.
final class FinalizeConsultationSettlementInfrastructureException
    implements Exception {
  const FinalizeConsultationSettlementInfrastructureException({
    required this.runtimeFailure,
  });

  final FinancialRuntimeInfrastructureFailure runtimeFailure;

  String get executionId => runtimeFailure.executionId;

  String get correlationId => runtimeFailure.correlationId;

  String get transactionId => runtimeFailure.transactionId;

  Object get error => runtimeFailure.error;

  StackTrace get stackTrace => runtimeFailure.stackTrace;

  Object? get originalError => runtimeFailure.originalError;

  StackTrace? get originalStackTrace => runtimeFailure.originalStackTrace;

  @override
  String toString() {
    return 'FinalizeConsultationSettlementInfrastructureException('
        'executionId: $executionId, '
        'correlationId: $correlationId, '
        'transactionId: $transactionId, '
        'error: $error'
        ')';
  }
}
