import 'fee_component.dart';

class FeeBreakdown {
  final List<FeeComponent> components;

  const FeeBreakdown({required this.components});

  int get totalMinor =>
      components.fold(0, (sum, component) => sum + component.amountMinor);

  FeeComponent? byCode(String code) {
    for (final component in components) {
      if (component.code == code) {
        return component;
      }
    }

    return null;
  }
}
