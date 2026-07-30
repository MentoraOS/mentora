import '../models/ledger_account.dart';

class AccountRegistry {
  final Map<String, LedgerAccount> _accountsById = {};

  void register(LedgerAccount account) {
    final existing = _accountsById[account.id];

    if (existing == null) {
      _accountsById[account.id] = account;
      return;
    }

    if (!_hasSameDefinition(existing, account)) {
      throw StateError(
        'Ledger account ${account.id} is already registered '
        'with a different definition',
      );
    }
  }

  void registerAll(Iterable<LedgerAccount> accounts) {
    for (final account in accounts) {
      register(account);
    }
  }

  LedgerAccount? findById(String accountId) {
    return _accountsById[accountId];
  }

  LedgerAccount getRequired(String accountId) {
    final account = findById(accountId);

    if (account == null) {
      throw StateError('Ledger account $accountId is not registered');
    }

    return account;
  }

  List<LedgerAccount> findByOwnerId(String ownerId) {
    return _accountsById.values
        .where((account) => account.ownerId == ownerId)
        .toList(growable: false);
  }

  List<LedgerAccount> findByCurrency(String currency) {
    final normalizedCurrency = currency.toUpperCase();

    return _accountsById.values
        .where(
          (account) => account.currency.toUpperCase() == normalizedCurrency,
        )
        .toList(growable: false);
  }

  bool contains(String accountId) {
    return _accountsById.containsKey(accountId);
  }

  List<LedgerAccount> get allAccounts {
    return List.unmodifiable(_accountsById.values);
  }

  int get length => _accountsById.length;

  void clear() {
    _accountsById.clear();
  }

  bool _hasSameDefinition(LedgerAccount left, LedgerAccount right) {
    return left.id == right.id &&
        left.ownerId == right.ownerId &&
        left.currency == right.currency &&
        left.type == right.type &&
        left.name == right.name &&
        left.active == right.active;
  }
}
