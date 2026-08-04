import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../registry/semantic_roles.dart';
import '../overlay/overlay_demand_queue.dart';
import 'mentora_dialog_request.dart';
import 'mentora_dialog_style.dart';

/// The official way to ask for a dialog. No screen ever creates an
/// overlay: it addresses a demand to this service, which holds at
/// most one exchange at a time — because every dialog meaning is
/// exclusive (an enclosure is never stacked on an enclosure).
///
/// The service knows no business: it carries demands, verifies their
/// contracts at the door, orders them, and returns their outcome.
final class MentoraDialogService extends ChangeNotifier {
  late final OverlayDemandQueue<MentoraDialogRequest, MentoraDialogResult>
  _queue = OverlayDemandQueue(onChanged: notifyListeners);

  MentoraDialogRequest? get current => _queue.current;

  bool get isBusy => _queue.isBusy;

  int get pendingCount => _queue.pendingCount;

  /// Shows now — or refuses. A demand is never silently deferred: a
  /// caller who means "now" learns that the layer is taken, and a
  /// caller who can wait says so with [queue].
  Future<MentoraDialogResult> show(MentoraDialogRequest request) {
    request.verify();
    if (isBusy) {
      throw StateError(
        'A dialog is already open and every dialog is exclusive: '
        'queue() the demand instead of forcing it.',
      );
    }
    return _queue.open(request);
  }

  /// Waits its turn — and opens as soon as the layer is free.
  Future<MentoraDialogResult> queue(MentoraDialogRequest request) {
    request.verify();
    return _queue.enqueue(request);
  }

  /// Takes the place of the open exchange — the replaced demand is
  /// answered as replaced, never left waiting for an answer that will
  /// not come.
  Future<MentoraDialogResult> replace(MentoraDialogRequest request) {
    request.verify();
    return _queue.replaceWith(request, const MentoraDialogResult.replaced());
  }

  /// Closes the open exchange with an outcome the application owns.
  void close([
    MentoraDialogResult result = const MentoraDialogResult.closed(),
  ]) {
    if (!isBusy) {
      throw StateError('No exchange is open: there is nothing to close.');
    }
    _queue.complete(result);
  }

  /// Steps back — offered only where the meaning allows it. A
  /// decision is answered, never abandoned.
  void dismiss() {
    final request = current;
    if (request == null) {
      throw StateError('No exchange is open: there is nothing to dismiss.');
    }
    if (!allowsStepBack(request)) {
      throw StateError(
        'This exchange is an enclosure: it is answered, never '
        'dismissed.',
      );
    }
    _queue.complete(const MentoraDialogResult.dismissed());
  }

  /// Reports the act the person chose.
  void answer(MentoraDialogAction action) {
    if (!isBusy) {
      throw StateError('No exchange is open: there is nothing to answer.');
    }
    _queue.complete(MentoraDialogResult.answered(action.id));
  }

  /// Whether the demand may be stepped back from — read from the
  /// single elevation meaning mapping, never from a boolean a caller
  /// invents.
  static bool allowsStepBack(MentoraDialogRequest request) =>
      elevationMeaningOf(request.variant) != ElevationMeaning.decision;

  @override
  void dispose() {
    _queue.closeAll(const MentoraDialogResult.closed());
    super.dispose();
  }
}
