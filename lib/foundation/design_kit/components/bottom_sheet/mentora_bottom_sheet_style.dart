import 'package:flutter/foundation.dart';

import '../../registry/semantic_roles.dart';

/// The eight official sheet variants — the only contextual-layer
/// vocabulary the business screens will ever speak. No screen ever
/// touches showModalBottomSheet, showBottomSheet, BottomSheet or
/// ModalBottomSheetRoute.
enum MentoraBottomSheetVariant {
  standard,
  action,
  selection,
  filter,
  preview,
  editor,
  expanded,
  custom,
}

/// Where a sheet rests. Two detents, no more: a sheet accompanies a
/// screen, it never becomes a page of its own.
enum MentoraBottomSheetDetent { collapsed, expanded }

/// The eight official states — no more. The layer's life belongs to
/// the host, the work in progress is announced by the application.
enum MentoraBottomSheetState {
  closed,
  opening,
  opened,
  dragging,
  expanded,
  collapsed,
  processing,
  closing,
}

/// What the application announces while the sheet is open. A sheet
/// accompanies: it reports no outcome — an outcome that must be
/// acknowledged belongs to a dialog.
enum MentoraBottomSheetPhase { idle, processing }

/// A sheet never encloses.
///
/// Its elevation MEANING is always the aparté: it dims the scene
/// without blocking it, it consults and returns. What must be
/// answered before anything else continues is a [MentoraDialog], not
/// a sheet — that boundary is the reason both components exist.
const ElevationMeaning bottomSheetElevationMeaning = ElevationMeaning.aparte;

/// Where a variant rests when it arrives — a sheet never occupies the
/// screen without a reason.
MentoraBottomSheetDetent initialDetentOf(MentoraBottomSheetVariant variant) {
  switch (variant) {
    case MentoraBottomSheetVariant.editor:
    case MentoraBottomSheetVariant.expanded:
      return MentoraBottomSheetDetent.expanded;
    case MentoraBottomSheetVariant.standard:
    case MentoraBottomSheetVariant.action:
    case MentoraBottomSheetVariant.selection:
    case MentoraBottomSheetVariant.filter:
    case MentoraBottomSheetVariant.preview:
    case MentoraBottomSheetVariant.custom:
      return MentoraBottomSheetDetent.collapsed;
  }
}

/// Whether a variant may take more room. A short list of acts never
/// grows to fill a screen it does not need.
bool isExpandable(MentoraBottomSheetVariant variant) =>
    variant != MentoraBottomSheetVariant.action;

/// Drives the work announced while the sheet is open. One controller
/// serves exactly one sheet.
final class MentoraBottomSheetController extends ChangeNotifier {
  MentoraBottomSheetPhase _phase = MentoraBottomSheetPhase.idle;

  MentoraBottomSheetPhase get phase => _phase;

  void beginProcessing() => _update(MentoraBottomSheetPhase.processing);

  void reset() => _update(MentoraBottomSheetPhase.idle);

  void _update(MentoraBottomSheetPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
