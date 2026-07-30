import '../events/event_engine.dart';
import '../events/event_names.dart';
import '../events/mentora_event.dart';
import '../logging/logger_engine.dart';
import '../logging/log_level.dart';
import '../audit/audit_action.dart';
import '../audit/audit_engine.dart';

import '../financial/ledger/financial_ledger_factory.dart';
import '../financial/ledger/models/ledger_entry.dart';
import '../financial/ledger/models/ledger_transaction.dart';
import '../financial/ledger/models/ledger_transaction_status.dart';
import '../financial/ledger/models/ledger_transaction_type.dart';

import 'models/payment_request.dart';
import 'models/payment_result.dart';
import 'registry/payment_provider_registry.dart';

class PaymentEngine {
  PaymentEngine._();

  static Future<PaymentResult> startPayment(PaymentRequest request) async {
    LoggerEngine.log(
      level: LogLevel.info,
      engine: 'PaymentEngine',
      message: 'Starting payment',
      metadata: {
        'provider': request.provider.name,
        'bookingId': request.bookingId,
      },
    );

    final provider = PaymentProviderRegistry.providerOf(request.provider);

    if (provider == null) {
      throw Exception(
        'No payment provider registered for ${request.provider.name}',
      );
    }

    final result = await provider.startPayment(request);

    await AuditEngine.record(
      actorId: request.clientId,
      actorRole: 'client',
      action: result.isSuccess
          ? AuditAction.paymentSucceeded
          : AuditAction.paymentFailed,
      targetType: 'booking',
      targetId: request.bookingId,
      metadata: {
        'provider': request.provider.name,
        'status': result.status.name,
        'transactionId': result.transactionId,
      },
    );

    if (result.isSuccess) {
      final ledger = FinancialLedgerFactory.firestore();

      await ledger.recordTransaction(
        LedgerTransaction(
          id: 'ledger_${result.transactionId}',
          reference: request.bookingId,
          transactionType: LedgerTransactionType.payment,
          status: LedgerTransactionStatus.posted,
          bookingId: request.bookingId,
          clientId: request.clientId,
          expertId: request.expertId,
          countryCode: request.countryCode,
          currency: request.currency,
          provider: request.provider.name,
          createdAt: DateTime.now(),
          entries: [
            LedgerEntry(
              accountId: 'client_external_${request.clientId}',
              type: LedgerEntryType.debit,
              amount: request.amount,
            ),
            LedgerEntry(
              accountId: 'escrow_${request.bookingId}',
              type: LedgerEntryType.credit,
              amount: request.amount,
            ),
          ],
          metadata: {
            'providerReference': result.providerReference,
            'rawResponse': result.rawResponse,
          },
        ),
      );

      EventEngine.publish(
        MentoraEvent(
          name: EventNames.paymentSucceeded,
          payload: {
            'bookingId': request.bookingId,
            'transactionId': result.transactionId,
          },
          occurredAt: DateTime.now(),
        ),
      );
    } else {
      EventEngine.publish(
        MentoraEvent(
          name: EventNames.paymentFailed,
          payload: {'bookingId': request.bookingId, 'message': result.message},
          occurredAt: DateTime.now(),
        ),
      );
    }

    return result;
  }
}
