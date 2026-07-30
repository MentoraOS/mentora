final class LedgerJournalSource {
  LedgerJournalSource({required String type, required String id})
    : type = _normalizeRequired(value: type, fieldName: 'type'),
      id = _normalizeRequired(value: id, fieldName: 'id');

  final String type;

  final String id;

  static String _normalizeRequired({
    required String value,
    required String fieldName,
  }) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        'Ledger journal source $fieldName cannot be empty.',
      );
    }

    return normalized;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerJournalSource && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() {
    return 'LedgerJournalSource(type: $type, id: $id)';
  }
}
