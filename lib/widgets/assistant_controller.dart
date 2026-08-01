import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/assistant/assistant_provider.dart';
import '../domain/assistant/assistant_suggestion.dart';

/// Presentation-only controller of the copilot overlay.
///
/// GOVERNANCE: the only authorized chain is AssistantStream ->
/// AssistantController -> AssistantOverlay. This controller consumes the
/// ALREADY-PRODUCED suggestion flux — it never touches the assistant
/// provider, the gateway or any engine, decides nothing and persists
/// nothing. It keeps the last [maxVisible] suggestions alive (older ones
/// disappear automatically) and owns the collapsed state of the
/// retractable overlay.
final class AssistantController extends ChangeNotifier {
  AssistantController({
    required AssistantStream assistant,
    this.maxVisible = 3,
  }) {
    _subscription = assistant.suggestions.listen(
      _onSuggestion,
      // Fail closed: an errored flux stops producing suggestions;
      // nothing is ever invented.
      onError: (Object _) {},
    );
  }

  /// How many suggestions stay visible; the default is the product rule.
  final int maxVisible;

  final List<AssistantSuggestion> _visible = [];

  StreamSubscription<AssistantSuggestion>? _subscription;
  bool _collapsed = false;

  /// The last suggestions, oldest first. Never more than [maxVisible].
  List<AssistantSuggestion> get visible => List.unmodifiable(_visible);

  /// Whether the overlay is retracted to its compact chip.
  bool get collapsed => _collapsed;

  void toggleCollapsed() {
    _collapsed = !_collapsed;
    notifyListeners();
  }

  void _onSuggestion(AssistantSuggestion suggestion) {
    _visible.add(suggestion);
    while (_visible.length > maxVisible) {
      _visible.removeAt(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
