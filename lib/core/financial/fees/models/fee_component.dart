class FeeComponent {
  final String code;

  final String label;

  /// Montant exprimé en unités mineures.
  final int amountMinor;

  const FeeComponent({
    required this.code,
    required this.label,
    required this.amountMinor,
  }) : assert(amountMinor >= 0);
}
