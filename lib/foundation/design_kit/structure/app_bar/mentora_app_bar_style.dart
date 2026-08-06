import 'package:flutter/foundation.dart';

import '../../tokens/app_bar_tokens.dart';

/// The six official context variants — the only structural vocabulary
/// the business screens will ever speak. Flutter's own bars stay
/// primitives: Mentora owns its structure.
enum MentoraAppBarVariant {
  standard,
  largeTitle,
  compact,
  transparent,
  search,
  modal,
}

/// The seven official states. The context never discovers them by
/// itself: the application announces where the content is.
enum MentoraAppBarState {
  idle,
  collapsed,
  expanded,
  scrolled,
  searching,
  loading,
  disabled,
}

/// What the application announces about the context.
enum MentoraAppBarStatus { idle, searching, loading, disabled }

/// How a context behaves while the content moves under it.
///
/// This is a DECLARATION, never a behaviour implemented here: the bar
/// subscribes to no scroll, computes no offset and decides nothing.
/// The application announces the progress; the structure expresses it.
enum MentoraAppBarScrollBehaviour {
  /// It never leaves.
  pinned,

  /// It returns as soon as the content comes back.
  floating,

  /// It gives its room to the content, keeping its collapsed extent.
  collapsible,

  /// It may exceed the room it reserved when the content is pulled.
  stretchable,
}

/// What stands at the start of a context — exactly one thing, and
/// never one without a name.
enum MentoraAppBarNavigationKind { back, close }

/// The way back out of a context. A control without a name is never
/// rendered: the label is required.
final class MentoraAppBarNavigation {
  final MentoraAppBarNavigationKind kind;
  final String label;
  final VoidCallback onInvoke;

  const MentoraAppBarNavigation.back({
    required this.label,
    required this.onInvoke,
  }) : kind = MentoraAppBarNavigationKind.back;

  const MentoraAppBarNavigation.close({
    required this.label,
    required this.onInvoke,
  }) : kind = MentoraAppBarNavigationKind.close;
}

/// Whether a variant offers more room than it keeps — only those can
/// collapse, expand or stretch.
bool canCollapse(MentoraAppBarVariant variant) =>
    variant == MentoraAppBarVariant.largeTitle;

/// Carries what the application knows about the context: its status,
/// and how far the content has taken its room.
///
/// The progress is announced, never measured here: 0 is fully
/// expanded, 1 fully collapsed. Beyond 1 the context is being
/// stretched, and only a stretchable declaration allows it.
final class MentoraAppBarController extends ChangeNotifier {
  MentoraAppBarStatus _status;
  double _collapseProgress = 0;

  MentoraAppBarController([MentoraAppBarStatus initial = MentoraAppBarStatus.idle])
    : _status = initial;

  MentoraAppBarStatus get status => _status;

  double get collapseProgress => _collapseProgress;

  void announce(MentoraAppBarStatus status) {
    if (status == _status) return;
    _status = status;
    notifyListeners();
  }

  /// The application reports where the content is. A progress outside
  /// the official range is refused: the structure never guesses.
  void reportProgress(double progress) {
    if (progress < 0 || progress > appBarFullOpacity + appBarMaximumStretch) {
      throw StateError(
        'A collapse progress is announced between 0 and its stretch '
        'bound: the structure measures nothing itself.',
      );
    }
    if (progress == _collapseProgress) return;
    _collapseProgress = progress;
    notifyListeners();
  }
}
