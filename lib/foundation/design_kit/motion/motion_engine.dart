import 'package:flutter/animation.dart';

import '../appearance/appearance_engine.dart';
import '../tokens/design_tokens.dart';

/// The eight closed motion intentions (catalog §D10). A ninth requires
/// an upstream revision — never a local case.
enum MotionIntention {
  expliquer,
  guider,
  rassurer,
  preserverLeContexte,
  attirerLAttention,
  accompagner,
  confirmer,
  montrerLaContinuite,
}

/// The Motion Engine — consumes motion Tokens exclusively and declines
/// their expression by the Motion preference: Full keeps the Tokens,
/// Reduced shortens them, None silences them — the intentions remain,
/// their information stays available elsewhere (AFI-04).
final class MotionEngine {
  const MotionEngine();

  Duration durationFor(MotionIntention intention, AppearanceState state) {
    if (state.motion == MotionPreference.none) {
      return Duration.zero;
    }
    final base = _baseDuration(intention);
    if (state.motion == MotionPreference.reduced) {
      return base * reducedMotionFactor;
    }
    return base;
  }

  Curve curveFor(MotionIntention intention) {
    return intention == MotionIntention.attirerLAttention
        ? motionTokens.attentionCurve
        : motionTokens.standardCurve;
  }

  Duration _baseDuration(MotionIntention intention) {
    switch (intention) {
      case MotionIntention.expliquer:
        return motionTokens.expliquer;
      case MotionIntention.guider:
        return motionTokens.guider;
      case MotionIntention.rassurer:
        return motionTokens.rassurer;
      case MotionIntention.preserverLeContexte:
        return motionTokens.preserverLeContexte;
      case MotionIntention.attirerLAttention:
        return motionTokens.attirerLAttention;
      case MotionIntention.accompagner:
        return motionTokens.accompagner;
      case MotionIntention.confirmer:
        return motionTokens.confirmer;
      case MotionIntention.montrerLaContinuite:
        return motionTokens.montrerLaContinuite;
    }
  }
}
