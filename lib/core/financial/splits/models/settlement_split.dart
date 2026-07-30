import 'settlement_split_component.dart';
import 'split_destination.dart';

class SettlementSplit {
  final int grossAmountMinor;
  final String currency;
  final List<SettlementSplitComponent> components;

  const SettlementSplit({
    required this.grossAmountMinor,
    required this.currency,
    required this.components,
  }) : assert(grossAmountMinor >= 0),
       assert(currency != '');

  int get totalMinor {
    return components.fold<int>(0, (total, component) {
      return total + component.amountMinor;
    });
  }

  bool get isBalanced {
    return totalMinor == grossAmountMinor;
  }

  SettlementSplitComponent? byDestination(SplitDestination destination) {
    for (final component in components) {
      if (component.destination == destination) {
        return component;
      }
    }

    return null;
  }

  SettlementSplitComponent? byCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final component in components) {
      if (component.code.trim().toUpperCase() == normalizedCode) {
        return component;
      }
    }

    return null;
  }

  int amountFor(SplitDestination destination) {
    return byDestination(destination)?.amountMinor ?? 0;
  }

  bool containsDestination(SplitDestination destination) {
    return byDestination(destination) != null;
  }
}
