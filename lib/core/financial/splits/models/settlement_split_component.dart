import 'split_destination.dart';

class SettlementSplitComponent {
  final SplitDestination destination;
  final int amountMinor;

  final String code;
  final String label;

  const SettlementSplitComponent({
    required this.destination,
    required this.amountMinor,
    required this.code,
    required this.label,
  }) : assert(amountMinor >= 0),
       assert(code != ''),
       assert(label != '');

  SettlementSplitComponent copyWith({
    SplitDestination? destination,
    int? amountMinor,
    String? code,
    String? label,
  }) {
    return SettlementSplitComponent(
      destination: destination ?? this.destination,
      amountMinor: amountMinor ?? this.amountMinor,
      code: code ?? this.code,
      label: label ?? this.label,
    );
  }
}
