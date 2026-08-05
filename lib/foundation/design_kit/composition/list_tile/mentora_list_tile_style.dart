import 'package:flutter/foundation.dart';

import '../../components/avatar/mentora_avatar_style.dart';

/// How much of itself a tile gives to an entity.
///
/// Density is a COMPOSITION decision — how much room this list gives
/// each entity. It never replaces the person's own Density
/// preference, which the appearance carries for the whole product.
enum MentoraListTileDensity { standard, compact, large, dense }

/// How a tile delimits the entity it presents.
enum MentoraListTileChrome { plain, outlined, separated, highlighted }

/// The seven official states. Focus and pointer belong to the tile;
/// everything else is announced from outside — an entity is selected,
/// loading or archived because the application says so.
enum MentoraListTileState {
  idle,
  focused,
  hovered,
  selected,
  disabled,
  loading,
  archived,
}

/// What the application announces about the entity itself.
enum MentoraListTileStatus { idle, selected, loading, archived, disabled }

/// The extent an identity takes at a given density — a dense list
/// presents smaller identities, never different ones.
MentoraAvatarSize avatarSizeOf(MentoraListTileDensity density) {
  switch (density) {
    case MentoraListTileDensity.large:
      return MentoraAvatarSize.large;
    case MentoraListTileDensity.standard:
      return MentoraAvatarSize.medium;
    case MentoraListTileDensity.compact:
      return MentoraAvatarSize.small;
    case MentoraListTileDensity.dense:
      return MentoraAvatarSize.extraSmall;
  }
}

/// Carries the state of one entity over time. The application
/// announces; the tile expresses.
final class MentoraListTileController extends ChangeNotifier {
  MentoraListTileStatus _status;

  MentoraListTileController([
    MentoraListTileStatus initial = MentoraListTileStatus.idle,
  ]) : _status = initial;

  MentoraListTileStatus get status => _status;

  void announce(MentoraListTileStatus status) {
    if (status == _status) return;
    _status = status;
    notifyListeners();
  }
}
