import 'package:flutter/widgets.dart' show Widget;

import 'mentora_bottom_sheet_style.dart';

/// A demand addressed to the sheet service — what to accompany, and
/// with what. It carries no business, no decision and no rule.
final class MentoraBottomSheetRequest {
  final MentoraBottomSheetVariant variant;

  /// What the sheet is about. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String title;

  /// The content the sheet accompanies — composed by the application
  /// with Mentora components. The Kit never invents it.
  final Widget content;

  /// The screen reader's name for the layer, when it must differ from
  /// the title.
  final String? semanticLabel;

  const MentoraBottomSheetRequest({
    required this.variant,
    required this.title,
    required this.content,
    this.semanticLabel,
  });

  /// The contracts a demand must honor — verified once, at the door of
  /// the service, never silently repaired.
  void verify() {
    if (title.isEmpty) {
      throw StateError('A sheet without a title announces nothing.');
    }
  }

  MentoraBottomSheetDetent get initialDetent => initialDetentOf(variant);

  bool get expandable => isExpandable(variant);
}

/// How the accompaniment ended.
enum MentoraBottomSheetOutcome {
  /// The person stepped back, or the sheet had done its work.
  dismissed,

  /// The application closed the layer itself.
  closed,

  /// Another demand took the layer's place.
  replaced,
}

/// What the caller receives when the sheet closes.
final class MentoraBottomSheetResult {
  final MentoraBottomSheetOutcome outcome;

  const MentoraBottomSheetResult.dismissed()
    : outcome = MentoraBottomSheetOutcome.dismissed;

  const MentoraBottomSheetResult.closed()
    : outcome = MentoraBottomSheetOutcome.closed;

  const MentoraBottomSheetResult.replaced()
    : outcome = MentoraBottomSheetOutcome.replaced;

  @override
  bool operator ==(Object other) =>
      other is MentoraBottomSheetResult && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;
}
