import 'package:cloud_firestore/cloud_firestore.dart';

import 'ledger_engine.dart';
import 'repository/firestore_ledger_repository.dart';

class FinancialLedgerFactory {
  FinancialLedgerFactory._();

  static LedgerEngine firestore() {
    return LedgerEngine(
      repository: FirestoreLedgerRepository(
        firestore: FirebaseFirestore.instance,
      ),
    );
  }
}
