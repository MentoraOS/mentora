import '../../balance/balance_engine.dart';
import '../../engine/ledger_engine.dart';
import '../../models/ledger_transaction.dart';

import '../builders/ledger_posting_builder.dart';
import '../models/posting_request.dart';

class PostingEngine {
  final LedgerPostingBuilder builder;

  final LedgerEngine ledgerEngine;

  final BalanceEngine balanceEngine;

  const PostingEngine({
    required this.builder,
    required this.ledgerEngine,
    required this.balanceEngine,
  });

  Future<LedgerTransaction> post(PostingRequest request) async {
    final transaction = builder.build(request);

    final posted = await ledgerEngine.post(transaction);

    final accountIds = posted.entries.map((e) => e.accountId).toSet();

    for (final accountId in accountIds) {
      await balanceEngine.calculate(accountId);
    }

    return posted;
  }
}
