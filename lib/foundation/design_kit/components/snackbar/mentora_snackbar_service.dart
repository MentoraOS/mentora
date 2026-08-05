import 'dart:async';

import 'package:flutter/foundation.dart';

import '../overlay/overlay_demand_queue.dart';
import 'mentora_snackbar_request.dart';

/// The official way to say something in passing. No screen ever
/// creates a transient signal: it addresses a demand to this service,
/// which holds exactly one message at a time — one message, one idea.
///
/// The service knows no business, and it never asks anything: a
/// message has no act to answer.
final class MentoraSnackbarService extends ChangeNotifier {
  late final OverlayDemandQueue<MentoraSnackbarRequest, MentoraSnackbarResult>
  _queue = OverlayDemandQueue(onChanged: notifyListeners);

  MentoraSnackbarRequest? get current => _queue.current;

  bool get isShowing => _queue.isBusy;

  int get pendingCount => _queue.pendingCount;

  /// Says it now — or refuses. A message is never silently deferred:
  /// a caller who means "now" learns that one is already speaking,
  /// and a caller who can wait says so with [queue].
  Future<MentoraSnackbarResult> show(MentoraSnackbarRequest request) {
    request.verify();
    if (isShowing) {
      throw StateError(
        'A message is already on screen and only one speaks at a '
        'time: queue() the demand instead of forcing it.',
      );
    }
    return _queue.open(request);
  }

  /// Waits its turn — and speaks as soon as the previous one is done.
  Future<MentoraSnackbarResult> queue(MentoraSnackbarRequest request) {
    request.verify();
    return _queue.enqueue(request);
  }

  /// Says something else instead — the replaced message never waits
  /// for an outcome that will not come.
  Future<MentoraSnackbarResult> replace(MentoraSnackbarRequest request) {
    request.verify();
    return _queue.replaceWith(request, const MentoraSnackbarResult.replaced());
  }

  /// Ends the message on screen — used by the application when the
  /// state it reported is over, and by the host when a message that
  /// leaves on its own has served its time.
  void dismiss([
    MentoraSnackbarResult result = const MentoraSnackbarResult.dismissed(),
  ]) {
    if (!isShowing) {
      throw StateError('No message is on screen: there is nothing to end.');
    }
    _queue.complete(result);
  }

  /// Ends everything at once — nothing stays queued behind a context
  /// that no longer exists.
  void clear() {
    if (!isShowing) return;
    _queue.closeAll(const MentoraSnackbarResult.cleared());
    notifyListeners();
  }

  @override
  void dispose() {
    _queue.closeAll(const MentoraSnackbarResult.cleared());
    super.dispose();
  }
}
