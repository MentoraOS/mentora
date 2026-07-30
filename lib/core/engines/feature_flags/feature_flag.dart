import 'feature.dart';
import 'feature_strategy.dart';
import 'feature_target.dart';

class FeatureFlag {
  final Feature feature;

  final FeatureStrategy strategy;

  final bool enabled;

  final List<String> countries;

  final List<FeatureTarget> targets;

  final int rolloutPercentage;

  const FeatureFlag({
    required this.feature,
    required this.strategy,
    required this.enabled,
    this.countries = const [],
    this.targets = const [],
    this.rolloutPercentage = 100,
  });
}
