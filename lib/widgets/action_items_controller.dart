import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/action_items/action_item.dart';
import '../domain/action_items/action_items_provider.dart';

/// Presentation-only controller of the action-items review.
///
/// GOVERNANCE: the only authorized chain is ActionItemsStream ->
/// ActionItemsController -> ActionItemsOverlay. This controller consumes
/// the ALREADY-PRODUCED proposal flux and holds the expert's LOCAL
/// review decisions: accepting changes only the visual state, editing
/// lives only here, rejecting only removes from the overlay. Nothing is
/// ever persisted, synchronized or sent back to the AI — the strict
/// separation between the user experience and the future business
/// layers. The expert is the authority; the AI never decides.
final class ActionItemsController extends ChangeNotifier {
  ActionItemsController({required ActionItemsStream actionItems}) {
    _subscription = actionItems.items.listen(
      _onItem,
      // Fail closed: an errored flux stops producing proposals; nothing
      // is ever invented.
      onError: (Object _) {},
    );
  }

  final List<ReviewableActionItem> _items = [];

  StreamSubscription<ActionItem>? _subscription;
  bool _collapsed = false;

  /// The proposals under review, oldest first, with their local state.
  List<ReviewableActionItem> get items => List.unmodifiable(_items);

  /// Whether the overlay is retracted to its compact chip.
  bool get collapsed => _collapsed;

  void toggleCollapsed() {
    _collapsed = !_collapsed;
    notifyListeners();
  }

  /// Accepting is ONLY a visual state — no task, no workflow, nothing
  /// written anywhere.
  void accept(String actionId) {
    _update(actionId, (entry) => entry._with(accepted: true));
  }

  /// Editing is ONLY local — the text lives here and nowhere else.
  void edit(String actionId, {String? title, String? description}) {
    _update(
      actionId,
      (entry) => entry._with(title: title, description: description),
    );
  }

  /// Rejecting ONLY removes the proposal from the overlay — nothing is
  /// deleted on the AI side, nothing persisted.
  void reject(String actionId) {
    _items.removeWhere((entry) => entry.item.actionId == actionId);
    notifyListeners();
  }

  void _onItem(ActionItem item) {
    _items.add(ReviewableActionItem._initial(item));
    notifyListeners();
  }

  void _update(
    String actionId,
    ReviewableActionItem Function(ReviewableActionItem) transform,
  ) {
    final index = _items.indexWhere(
      (entry) => entry.item.actionId == actionId,
    );
    if (index < 0) return;
    _items[index] = transform(_items[index]);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// One proposal with the expert's local review state.
final class ReviewableActionItem {
  final ActionItem item;

  /// The locally edited texts; initially the proposal's own.
  final String title;
  final String description;

  /// Visual acceptance only — no business meaning in this wave.
  final bool accepted;

  const ReviewableActionItem._({
    required this.item,
    required this.title,
    required this.description,
    required this.accepted,
  });

  factory ReviewableActionItem._initial(ActionItem item) {
    return ReviewableActionItem._(
      item: item,
      title: item.title,
      description: item.description,
      accepted: false,
    );
  }

  ReviewableActionItem _with({
    String? title,
    String? description,
    bool? accepted,
  }) {
    return ReviewableActionItem._(
      item: item,
      title: title?.trim().isNotEmpty ?? false ? title!.trim() : this.title,
      description: description?.trim().isNotEmpty ?? false
          ? description!.trim()
          : this.description,
      accepted: accepted ?? this.accepted,
    );
  }
}
