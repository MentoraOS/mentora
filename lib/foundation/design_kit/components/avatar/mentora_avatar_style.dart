import 'package:flutter/foundation.dart';

/// The ten official identity kinds — the only identity vocabulary the
/// business screens will ever speak. No screen ever touches the
/// framework's own avatar widget or its account headers.
///
/// An identity says WHO is represented, never what the application is
/// doing: [MentoraAvatarIdentity.loading] means the identity itself is
/// not resolved yet, while [MentoraAvatarState.loading] means the
/// identity is known and its portrait is still arriving.
enum MentoraAvatarIdentity {
  /// A person represented by their portrait.
  photo,

  /// A person represented by their initials.
  initials,

  /// An institution.
  organisation,

  /// A business.
  company,

  /// An intelligence.
  ai,

  /// An account of the platform.
  user,

  /// Someone present without an account.
  guest,

  /// Mentora itself.
  system,

  /// An identity that exists but is not known.
  unknown,

  /// An identity not resolved yet.
  loading,
}

/// The three official forms.
enum MentoraAvatarShape { circle, rounded, square }

/// The six official extents.
enum MentoraAvatarSize {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
  doubleExtraLarge,
}

/// The five official states of the identity language itself.
enum MentoraAvatarState { idle, loading, unavailable, disabled, archived }

/// Whether an identity is represented by a person's portrait when one
/// is given. Collective and system identities always speak through
/// their own mark.
bool acceptsPortrait(MentoraAvatarIdentity identity) {
  switch (identity) {
    case MentoraAvatarIdentity.photo:
    case MentoraAvatarIdentity.initials:
    case MentoraAvatarIdentity.user:
    case MentoraAvatarIdentity.guest:
    case MentoraAvatarIdentity.organisation:
    case MentoraAvatarIdentity.company:
      return true;
    case MentoraAvatarIdentity.ai:
    case MentoraAvatarIdentity.system:
    case MentoraAvatarIdentity.unknown:
    case MentoraAvatarIdentity.loading:
      return false;
  }
}

/// Whether an identity may speak through initials when no portrait is
/// available. An intelligence, the system, an unknown or an unresolved
/// identity have no initials to give.
bool acceptsInitials(MentoraAvatarIdentity identity) {
  switch (identity) {
    case MentoraAvatarIdentity.photo:
    case MentoraAvatarIdentity.initials:
    case MentoraAvatarIdentity.user:
    case MentoraAvatarIdentity.organisation:
    case MentoraAvatarIdentity.company:
      return true;
    case MentoraAvatarIdentity.guest:
    case MentoraAvatarIdentity.ai:
    case MentoraAvatarIdentity.system:
    case MentoraAvatarIdentity.unknown:
    case MentoraAvatarIdentity.loading:
      return false;
  }
}

/// Carries the state of one identity over time. An avatar is never
/// interactive: its state always comes from outside — the application
/// announces it, the avatar expresses it.
final class MentoraAvatarController extends ChangeNotifier {
  MentoraAvatarState _state;

  MentoraAvatarController([MentoraAvatarState initial = MentoraAvatarState.idle])
    : _state = initial;

  MentoraAvatarState get state => _state;

  void announce(MentoraAvatarState state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
  }
}
