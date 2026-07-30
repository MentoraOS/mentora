import 'package:mentora/domain/session/session_model.dart';
import 'feature.dart';
import 'feature_registry.dart';
import 'feature_strategy.dart';
import 'feature_target.dart';

class FeatureEngine {
  FeatureEngine._();

  static bool isEnabled(Feature feature) {
    final flag = FeatureRegistry.flags[feature];

    if (flag == null) return false;

    return flag.enabled;
  }

  static bool isAvailable({
    required Feature feature,
    required SessionModel session,
  }) {
    final flag = FeatureRegistry.flags[feature];

    if (flag == null) return false;
    if (!flag.enabled) return false;
    if (!session.isActive) return false;

    switch (flag.strategy) {
      case FeatureStrategy.enabled:
        return true;

      case FeatureStrategy.disabled:
        return false;

      case FeatureStrategy.countryBased:
        return flag.countries.contains(session.countryCode);

      case FeatureStrategy.roleBased:
        return _matchesTarget(session, flag.targets);

      case FeatureStrategy.percentageRollout:
        return _isInRollout(session.id, flag.rolloutPercentage);
    }
  }

  static bool _matchesTarget(
    SessionModel session,
    List<FeatureTarget> targets,
  ) {
    if (targets.isEmpty) return true;

    if (targets.contains(FeatureTarget.everyone)) return true;

    if (targets.contains(FeatureTarget.authenticatedUsers)) {
      return true;
    }

    if (targets.contains(FeatureTarget.clients) &&
        session.roles.contains('client')) {
      return true;
    }

    if (targets.contains(FeatureTarget.experts) &&
        session.roles.contains('expert')) {
      return true;
    }

    if (targets.contains(FeatureTarget.premiumExperts) &&
        session.roles.contains('premium_expert')) {
      return true;
    }

    if (targets.contains(FeatureTarget.admins) &&
        session.roles.contains('admin')) {
      return true;
    }

    if (targets.contains(FeatureTarget.countryManagers) &&
        session.roles.contains('country_manager')) {
      return true;
    }

    return false;
  }

  static bool _isInRollout(String userId, int percentage) {
    if (percentage <= 0) return false;
    if (percentage >= 100) return true;

    final hash = userId.codeUnits.fold<int>(
      0,
      (previous, current) => previous + current,
    );

    return hash % 100 < percentage;
  }
}
