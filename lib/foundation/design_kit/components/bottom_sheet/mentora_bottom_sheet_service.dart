import 'dart:async';

import 'package:flutter/foundation.dart';

import '../overlay/overlay_demand_queue.dart';
import 'mentora_bottom_sheet_request.dart';
import 'mentora_bottom_sheet_style.dart';

/// The official way to ask for a sheet. No screen ever creates a
/// contextual layer: it addresses a demand to this service, which
/// holds at most one accompaniment at a time and returns its outcome.
///
/// The service knows no business. It also owns where the sheet rests:
/// expanding and collapsing are demands like any other.
final class MentoraBottomSheetService extends ChangeNotifier {
  late final OverlayDemandQueue<
    MentoraBottomSheetRequest,
    MentoraBottomSheetResult
  >
  _queue = OverlayDemandQueue(onChanged: notifyListeners);

  MentoraBottomSheetDetent _detent = MentoraBottomSheetDetent.collapsed;

  MentoraBottomSheetRequest? get current => _queue.current;

  bool get isBusy => _queue.isBusy;

  int get pendingCount => _queue.pendingCount;

  /// Where the open sheet currently rests.
  MentoraBottomSheetDetent get detent => _detent;

  /// Shows now — or refuses. A demand is never silently deferred.
  Future<MentoraBottomSheetResult> show(MentoraBottomSheetRequest request) {
    request.verify();
    if (isBusy) {
      throw StateError(
        'A sheet is already open: queue() the demand instead of '
        'forcing it.',
      );
    }
    _detent = request.initialDetent;
    return _queue.open(request);
  }

  /// Waits its turn — and opens as soon as the layer is free.
  Future<MentoraBottomSheetResult> queue(MentoraBottomSheetRequest request) {
    request.verify();
    if (!isBusy) _detent = request.initialDetent;
    return _queue.enqueue(request);
  }

  /// Takes the place of the open accompaniment.
  Future<MentoraBottomSheetResult> replace(
    MentoraBottomSheetRequest request,
  ) {
    request.verify();
    _detent = request.initialDetent;
    return _queue.replaceWith(
      request,
      const MentoraBottomSheetResult.replaced(),
    );
  }

  /// Closes the open sheet with an outcome the application owns.
  void close([
    MentoraBottomSheetResult result = const MentoraBottomSheetResult.closed(),
  ]) {
    if (!isBusy) {
      throw StateError('No sheet is open: there is nothing to close.');
    }
    _complete(result);
  }

  /// Steps back — always offered: a sheet accompanies, it never
  /// encloses. It disappears as soon as its purpose is served.
  void dismiss() {
    if (!isBusy) {
      throw StateError('No sheet is open: there is nothing to dismiss.');
    }
    _complete(const MentoraBottomSheetResult.dismissed());
  }

  /// Takes more room — refused where the variant has no reason to.
  void expand() {
    final request = current;
    if (request == null) {
      throw StateError('No sheet is open: there is nothing to expand.');
    }
    if (!request.expandable) {
      throw StateError(
        'This sheet never takes more room than it needs: it is not '
        'expandable.',
      );
    }
    _moveTo(MentoraBottomSheetDetent.expanded);
  }

  /// Gives the room back.
  void collapse() {
    if (!isBusy) {
      throw StateError('No sheet is open: there is nothing to collapse.');
    }
    _moveTo(MentoraBottomSheetDetent.collapsed);
  }

  /// Where the person left the sheet after a gesture — the host
  /// reports, the service holds the truth.
  void settleAt(MentoraBottomSheetDetent detent) => _moveTo(detent);

  void _moveTo(MentoraBottomSheetDetent detent) {
    if (_detent == detent) return;
    _detent = detent;
    notifyListeners();
  }

  void _complete(MentoraBottomSheetResult result) {
    _queue.complete(result);
    final next = current;
    if (next != null) _detent = next.initialDetent;
  }

  @override
  void dispose() {
    _queue.closeAll(const MentoraBottomSheetResult.closed());
    super.dispose();
  }
}
