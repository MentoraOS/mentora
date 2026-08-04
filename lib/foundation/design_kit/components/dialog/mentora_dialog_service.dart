import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../registry/semantic_roles.dart';
import 'mentora_dialog_request.dart';
import 'mentora_dialog_style.dart';

final class _PendingDemand {
  final MentoraDialogRequest request;
  final Completer<MentoraDialogResult> completer;

  const _PendingDemand(this.request, this.completer);
}

/// The official way to ask for a dialog. No screen ever creates an
/// overlay: it addresses a demand to this service, which holds at
/// most one exchange at a time — because every dialog meaning is
/// exclusive (an enclosure is never stacked on an enclosure).
///
/// The service knows no business: it carries demands, verifies their
/// contracts at the door, orders them, and returns their outcome.
final class MentoraDialogService extends ChangeNotifier {
  MentoraDialogRequest? _current;
  Completer<MentoraDialogResult>? _completer;
  final Queue<_PendingDemand> _pending = Queue<_PendingDemand>();

  MentoraDialogRequest? get current => _current;

  bool get isBusy => _current != null;

  int get pendingCount => _pending.length;

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
    return _open(request);
  }

  /// Waits its turn — and opens as soon as the layer is free.
  Future<MentoraDialogResult> queue(MentoraDialogRequest request) {
    request.verify();
    if (!isBusy) return _open(request);
    final completer = Completer<MentoraDialogResult>();
    _pending.add(_PendingDemand(request, completer));
    notifyListeners();
    return completer.future;
  }

  /// Takes the place of the open exchange — the replaced demand is
  /// answered as replaced, never left waiting for an answer that will
  /// not come.
  Future<MentoraDialogResult> replace(MentoraDialogRequest request) {
    request.verify();
    _complete(const MentoraDialogResult.replaced());
    return _open(request);
  }

  /// Closes the open exchange with an outcome the application owns.
  void close([
    MentoraDialogResult result = const MentoraDialogResult.closed(),
  ]) {
    if (!isBusy) {
      throw StateError('No exchange is open: there is nothing to close.');
    }
    _complete(result);
    _advance();
  }

  /// Steps back — offered only where the meaning allows it. A
  /// decision is answered, never abandoned.
  void dismiss() {
    final request = _current;
    if (request == null) {
      throw StateError('No exchange is open: there is nothing to dismiss.');
    }
    if (!allowsStepBack(request)) {
      throw StateError(
        'This exchange is an enclosure: it is answered, never '
        'dismissed.',
      );
    }
    _complete(const MentoraDialogResult.dismissed());
    _advance();
  }

  /// Reports the act the person chose.
  void answer(MentoraDialogAction action) {
    if (!isBusy) {
      throw StateError('No exchange is open: there is nothing to answer.');
    }
    _complete(MentoraDialogResult.answered(action.id));
    _advance();
  }

  /// Whether the demand may be stepped back from — read from the
  /// single elevation meaning mapping, never from a boolean a caller
  /// invents.
  static bool allowsStepBack(MentoraDialogRequest request) =>
      elevationMeaningOf(request.variant) != ElevationMeaning.decision;

  Future<MentoraDialogResult> _open(MentoraDialogRequest request) {
    final completer = Completer<MentoraDialogResult>();
    _current = request;
    _completer = completer;
    notifyListeners();
    return completer.future;
  }

  void _complete(MentoraDialogResult result) {
    final completer = _completer;
    _current = null;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _advance() {
    if (_pending.isEmpty) {
      notifyListeners();
      return;
    }
    final next = _pending.removeFirst();
    _current = next.request;
    _completer = next.completer;
    notifyListeners();
  }

  @override
  void dispose() {
    // Nothing is left waiting for an answer that will never come.
    _complete(const MentoraDialogResult.closed());
    while (_pending.isNotEmpty) {
      final pending = _pending.removeFirst();
      if (!pending.completer.isCompleted) {
        pending.completer.complete(const MentoraDialogResult.closed());
      }
    }
    super.dispose();
  }
}
