import 'feature.dart';
import 'feature_flag.dart';
import 'feature_strategy.dart';
import 'feature_target.dart';

class FeatureRegistry {
  FeatureRegistry._();

  static final Map<Feature, FeatureFlag> flags = {
    Feature.wallet: const FeatureFlag(
      feature: Feature.wallet,
      strategy: FeatureStrategy.countryBased,
      enabled: true,
      countries: ['SN'],
      targets: [FeatureTarget.clients],
    ),

    Feature.aiSummary: const FeatureFlag(
      feature: Feature.aiSummary,
      strategy: FeatureStrategy.enabled,
      enabled: true,
    ),

    Feature.videoRecording: const FeatureFlag(
      feature: Feature.videoRecording,
      strategy: FeatureStrategy.roleBased,
      enabled: true,
      targets: [FeatureTarget.premiumExperts],
    ),
  };
}
