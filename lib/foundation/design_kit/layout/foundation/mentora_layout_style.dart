import 'package:flutter/widgets.dart' show Widget;

import '../../components/button/mentora_button.dart';

/// The shared vocabulary of the Layout layer.
///
/// What lives here belongs to no particular layout: it is what several
/// of them speak, or what a future family will speak. A specialization
/// never declares a style of its own — there is one style file for the
/// whole layer, and a scan proves it.

/// One panel of a dashboard.
///
/// A panel is a subject, what is said about it, and the acts offered
/// on it. The foundation composes the official container, the official
/// words and the official acts — it styles none of them, and it knows
/// nothing of what a panel carries.
final class MentoraDashboardPanel {
  /// What the panel is about. The application owns every string
  /// (Localization Engine); the layer composes none.
  final String title;

  /// What the panel carries. It belongs entirely to the application:
  /// the layer wraps it in nothing and changes nothing about it.
  final Widget content;

  /// The acts offered on the subject — the Button remains their owner.
  final List<MentoraButton> acts;

  const MentoraDashboardPanel({
    required this.title,
    required this.content,
    this.acts = const [],
  });
}

/// One region of content.
///
/// A region is an IDENTITY, a name and what it carries. It is not a
/// position: the application announces the regions in the order it
/// wants them read, and the identity is what the product refers to
/// forever.
///
/// What it carries is already built. It is handed on strictly intact:
/// nothing is wrapped around it, nothing is added beside it.
final class MentoraContentRegion {
  /// What this region IS — stable forever, never a position.
  final String id;

  /// What the screen reader hears about the region: a landmark name.
  /// The application owns every string; the layer composes none.
  final String semanticLabel;

  /// What the region carries, already built by the application.
  final Widget content;

  const MentoraContentRegion({
    required this.id,
    required this.semanticLabel,
    required this.content,
  });
}
