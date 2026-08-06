import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show IconData;

import '../../tokens/search_bar_tokens.dart';

/// The five official presentations of an intention bar.
enum MentoraSearchBarVariant {
  standard,
  expanded,
  floating,
  inline,
  persistent,
}

/// The seven official states.
enum MentoraSearchBarState {
  idle,
  focused,
  typing,
  searching,
  loading,
  disabled,
  error,
}

/// What the application announces about the intention it received.
///
/// `searching` says an answer is being sought; `loading` says the aids
/// are being gathered. They are different facts, and both belong to
/// the application: the bar seeks nothing and gathers nothing.
enum MentoraSearchPhase { idle, searching, loading, error }

/// An intention, written by a person.
///
/// It is a QUERY and never a result: this object holds what was typed,
/// and knows nothing of what may be found. It is never interpreted,
/// never normalized, never matched against anything by the Kit.
final class MentoraSearchQuery {
  final String text;

  const MentoraSearchQuery(this.text);

  static const MentoraSearchQuery empty = MentoraSearchQuery('');

  bool get isEmpty => text.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is MentoraSearchQuery && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// An aid offered to someone writing an intention.
///
/// A suggestion is never a result, never a search and never a way
/// somewhere: it is a help, published by the application, and choosing
/// one is reported — never performed.
final class MentoraSearchSuggestion {
  /// What this aid IS — stable, never a position.
  final String id;

  /// What it says. The application owns every string (Localization
  /// Engine); the Kit composes none.
  final String label;

  /// What situates it, when it needs situating.
  final String? supporting;

  final IconData? icon;

  const MentoraSearchSuggestion({
    required this.id,
    required this.label,
    this.supporting,
    this.icon,
  });
}

/// An affordance the application prepares but the Kit never performs —
/// speaking an intention, or recalling the ones already written.
///
/// A control without a name is never rendered: the label is required.
final class MentoraSearchAffordance {
  final String label;
  final VoidCallback onInvoke;

  const MentoraSearchAffordance({
    required this.label,
    required this.onInvoke,
  });
}

/// The presentation a variant materializes.
SearchBarPresentationSpec specOf(MentoraSearchBarVariant variant) {
  switch (variant) {
    case MentoraSearchBarVariant.standard:
      return standardSearchBarSpec;
    case MentoraSearchBarVariant.expanded:
      return expandedSearchBarSpec;
    case MentoraSearchBarVariant.floating:
      return floatingSearchBarSpec;
    case MentoraSearchBarVariant.inline:
      return inlineSearchBarSpec;
    case MentoraSearchBarVariant.persistent:
      return persistentSearchBarSpec;
  }
}

/// Carries the intention the application acknowledged, the phase it
/// announced, and the aids it published.
///
/// The bar never writes here by itself: it reports what a person
/// meant, and the application announces what it made of it.
final class MentoraSearchController extends ChangeNotifier {
  MentoraSearchQuery _query;
  MentoraSearchPhase _phase = MentoraSearchPhase.idle;
  List<MentoraSearchSuggestion> _suggestions = const [];

  MentoraSearchController([
    MentoraSearchQuery initial = MentoraSearchQuery.empty,
  ]) : _query = initial;

  MentoraSearchQuery get query => _query;

  MentoraSearchPhase get phase => _phase;

  /// The aids currently offered — published by the application, never
  /// computed here.
  List<MentoraSearchSuggestion> get suggestions =>
      List.unmodifiable(_suggestions);

  void announceQuery(MentoraSearchQuery query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }

  void publishSuggestions(List<MentoraSearchSuggestion> suggestions) {
    _suggestions = List.of(suggestions);
    notifyListeners();
  }

  /// What the application is doing with the intention it received.
  void announcePhase(MentoraSearchPhase phase) => _updatePhase(phase);

  void beginSearching() => _updatePhase(MentoraSearchPhase.searching);

  void beginLoading() => _updatePhase(MentoraSearchPhase.loading);

  void showError() => _updatePhase(MentoraSearchPhase.error);

  void reset() => _updatePhase(MentoraSearchPhase.idle);

  void _updatePhase(MentoraSearchPhase next) {
    if (next == _phase) return;
    _phase = next;
    notifyListeners();
  }
}
