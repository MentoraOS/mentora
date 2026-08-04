import 'dart:async';
import 'dart:collection';

final class _PendingDemand<TRequest, TResult> {
  final TRequest request;
  final Completer<TResult> completer;

  const _PendingDemand(this.request, this.completer);
}

/// The shared machinery of every official overlay service: at most one
/// demand is held, the others wait their turn, and no demand is ever
/// left without its outcome.
///
/// It carries no meaning of its own — what may be dismissed, what must
/// be answered, and what a demand must contain belong to each service.
/// It exists so that two services never write the same queue twice.
final class OverlayDemandQueue<TRequest extends Object, TResult> {
  final void Function() onChanged;
  final Queue<_PendingDemand<TRequest, TResult>> _pending =
      Queue<_PendingDemand<TRequest, TResult>>();

  TRequest? _current;
  Completer<TResult>? _completer;

  OverlayDemandQueue({required this.onChanged});

  TRequest? get current => _current;

  bool get isBusy => _current != null;

  int get pendingCount => _pending.length;

  /// Opens now. The caller has already verified that the layer is
  /// free — the refusal message belongs to the service.
  Future<TResult> open(TRequest request) {
    final completer = Completer<TResult>();
    _current = request;
    _completer = completer;
    onChanged();
    return completer.future;
  }

  /// Opens if the layer is free, waits its turn otherwise.
  Future<TResult> enqueue(TRequest request) {
    if (!isBusy) return open(request);
    final completer = Completer<TResult>();
    _pending.add(_PendingDemand(request, completer));
    onChanged();
    return completer.future;
  }

  /// Ends the held demand with its outcome, then opens the next one
  /// if any is waiting.
  void complete(TResult result) {
    _settle(result);
    if (_pending.isEmpty) {
      onChanged();
      return;
    }
    final next = _pending.removeFirst();
    _current = next.request;
    _completer = next.completer;
    onChanged();
  }

  /// Ends the held demand with [replacedResult] and takes its place —
  /// the queue keeps its order behind.
  Future<TResult> replaceWith(TRequest request, TResult replacedResult) {
    _settle(replacedResult);
    return open(request);
  }

  /// Ends everything with the same outcome — nothing is left waiting
  /// for an answer that will never come.
  void closeAll(TResult result) {
    _settle(result);
    while (_pending.isNotEmpty) {
      final pending = _pending.removeFirst();
      if (!pending.completer.isCompleted) pending.completer.complete(result);
    }
  }

  void _settle(TResult result) {
    final completer = _completer;
    _current = null;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }
}
