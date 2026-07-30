import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/posting/ledger_journal_posting_request_factory.dart';

import 'package:mentora/core/financial/ledger/posting/models/posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';

void main() {
  group('LedgerJournalPostingRequestFactory', () {
    late LedgerJournalPostingRequestFactory factory;

    setUp(() {
      factory = const LedgerJournalPostingRequestFactory();
    });

    test('creates a posting request', () {
      final request = _request();

      final result = factory.create(request);

      expect(result.postingRequest, same(request));
    });

    test('builds deterministic journal id', () {
      final result = factory.create(_request(id: 'posting_001'));

      expect(result.journalId, 'journal_posting_001');
    });

    test('builds workflow key', () {
      final result = factory.create(
        _request(type: PostingType.paymentReleased),
      );

      expect(result.workflowKey, 'financial.posting.paymentReleased');
    });

    test('copies source information', () {
      final result = factory.create(_request(referenceId: 'operation-42'));

      expect(result.source.type, 'financial_posting');

      expect(result.source.id, 'operation-42');
    });

    test('uses utc dates', () {
      final createdAt = DateTime(2026, 1, 10, 14, 30);

      final result = factory.create(_request(createdAt: createdAt));

      expect(result.createdAt, isNotNull);
      expect(result.occurredAt, isNotNull);

      expect(result.createdAt!.isUtc, isTrue);

      expect(result.occurredAt!.isUtc, isTrue);
    });

    test('copies metadata', () {
      final result = factory.create(_request(metadata: {'foo': 'bar'}));

      expect(result.metadata['foo'], 'bar');
    });

    test('stores posting type', () {
      final result = factory.create(
        _request(type: PostingType.platformCommission),
      );

      expect(result.metadata['postingType'], 'platformCommission');
    });

    test('stores posting request id', () {
      final result = factory.create(_request(id: 'posting123'));

      expect(result.metadata['postingRequestId'], 'posting123');
    });

    test('stores consultation id', () {
      final result = factory.create(_request(consultationId: 'consultation99'));

      expect(result.metadata['consultationId'], 'consultation99');
    });

    test('stores client id', () {
      final result = factory.create(_request(clientId: 'client77'));

      expect(result.metadata['clientId'], 'client77');
    });

    test('stores expert id', () {
      final result = factory.create(_request(expertId: 'expert55'));

      expect(result.metadata['expertId'], 'expert55');
    });

    test('stores amount', () {
      final result = factory.create(_request(amountMinor: 15000));

      expect(result.metadata['amountMinor'], 15000);
    });

    test('normalizes currency', () {
      final result = factory.create(_request(currency: ' usd '));

      expect(result.metadata['currency'], 'USD');
    });

    test('rejects empty posting id', () {
      expect(() => factory.create(_request(id: '')), throwsArgumentError);
    });

    test('rejects empty reference id', () {
      expect(
        () => factory.create(_request(referenceId: '')),
        throwsArgumentError,
      );
    });

    test('rejects invalid currency', () {
      expect(() => factory.create(_request(currency: '')), throwsArgumentError);
    });

    test('rejects non positive amount', () {
      expect(
        () => factory.create(_request(amountMinor: 0)),
        throwsArgumentError,
      );
    });
  });
}

PostingRequest _request({
  String id = 'posting_001',
  String referenceId = 'operation_001',
  PostingType type = PostingType.paymentReleased,
  String consultationId = 'consultation_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  int amountMinor = 10000,
  String currency = 'USD',
  DateTime? createdAt,
  Map<String, dynamic> metadata = const {},
}) {
  return PostingRequest(
    id: id,
    referenceId: referenceId,
    type: type,
    consultationId: consultationId,
    clientId: clientId,
    expertId: expertId,
    amountMinor: amountMinor,
    currency: currency,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 10),
    metadata: metadata,
  );
}
