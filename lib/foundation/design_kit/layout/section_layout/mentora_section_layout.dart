import 'package:flutter/widgets.dart';

import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_page_like_layout.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_layout_theme.dart';

/// The official Section Layout — the way every section of Mentora is
/// built.
///
/// A section is not a card, not a container, not a Flutter group, not a
/// column and not a panel. It is a logical UNIT of content: an identity
/// that never changes, the name of what it gathers, what completes that
/// name when something must be said, and the content itself.
///
/// A section gathers. It never decides.
///
/// What this layout owns is that unit and its announcement. What it
/// never owns is the room: it creates no padding, no margin, no
/// spacing, no scroll view, no column of its own making and no grid.
/// The order of the sections is not its work either — it asks the
/// assembly for the single disposition of the layer, exactly like
/// every other layout that disposes named content.
final class MentoraSectionLayout extends MentoraPageLikeLayout {
  /// The sections, in the order they are to be read.
  final List<MentoraSection> sections;

  const MentoraSectionLayout({
    super.key,
    required super.frame,
    required this.sections,
    required super.pageSemanticLabel,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.section;

  @override
  void verify() {
    if (sections.isEmpty) {
      throw StateError(
        'A section layout gathers sections: without one it gathers '
        'nothing, and nothing is not a section.',
      );
    }
    final identities = <String>{};
    for (final section in sections) {
      if (section.id.isEmpty) {
        throw StateError('A section without an identity is not a section.');
      }
      if (section.title.isEmpty) {
        throw StateError(
          'A section without a name gathers nothing a person can '
          'recognise: it is never offered.',
        );
      }
      if (section.description != null && section.description!.isEmpty) {
        throw StateError(
          'What completes a name is said or it is not: an empty '
          'description is an ambiguity, never a completion.',
        );
      }
      if (!identities.add(section.id)) {
        throw StateError('Two sections never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));

    return MentoraLayoutSurface.regions(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      regions: [
        for (final section in sections)
          MentoraContentRegion(
            id: section.id,
            // A section is announced ONCE, by the region it is: the
            // words below say the same thing to the eye, and stay
            // silent to the reader.
            semanticLabel: section.title,
            content: _section(theme, section),
          ),
      ],
    );
  }

  /// One section: its name, what completes it, and what it gathers —
  /// in that order, with nothing added between them.
  Widget _section(MentoraLayoutTheme theme, MentoraSection section) {
    return Column(
      key: Key('section-${section.id}'),
      // The room a section adds around what it gathers: none, and it
      // is a Token so that the none is opposable.
      spacing: theme.contentGap,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MentoraText(
          section.title,
          key: Key('section-title-${section.id}'),
          role: theme.sectionTitleRole,
          excludeFromSemantics: true,
        ),
        if (section.description != null)
          MentoraText(
            section.description!,
            key: Key('section-description-${section.id}'),
            role: theme.sectionDescriptionRole,
          ),
        section.content,
      ],
    );
  }
}
