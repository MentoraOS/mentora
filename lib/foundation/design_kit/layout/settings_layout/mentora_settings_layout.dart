import 'package:flutter/widgets.dart';

import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_page_like_layout.dart';

/// The official Settings Layout — the form of a space where a person
/// configures a system.
///
/// It is not a form, not a list, not a dashboard, not a detail, not a
/// navigation and not a work in steps. It is a set of CATEGORIES, each
/// with an identity that never changes, each announced, and each either
/// open or closed — as the application says.
///
/// It expresses. It never decides.
///
/// It opens no category and closes none. It remembers nothing: there is
/// no state here, and there never will be — what is open belongs to the
/// application, which announces it. Announcing something else is what
/// opens or closes a category.
///
/// It knows no preference, no value, no persistence, no storage, no
/// permission and no model. An option is HANDED, never read, never
/// interpreted, never judged: MentoraInput, MentoraButton and every
/// control of the Kit remain the only owners of what a person does.
///
/// What a closed category holds is not built. It is absent from the
/// tree, from the focus and from what a screen reader announces —
/// nothing is hidden, because nothing is there.
///
/// It builds nothing at all: it describes its categories, and the
/// assembly of the layer is what places them.
final class MentoraSettingsLayout extends MentoraPageLikeLayout {
  /// The categories, in the order they are to be read.
  final List<MentoraSettingsCategory> categories;

  const MentoraSettingsLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required this.categories,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.settings;

  @override
  void verify() {
    if (categories.isEmpty) {
      throw StateError(
        'A configuration space is made of categories: without one it '
        'configures nothing, and nothing is not a space.',
      );
    }
    final identities = <String>{};
    for (final category in categories) {
      if (category.id.isEmpty) {
        throw StateError('A category without an identity is not a category.');
      }
      if (category.semanticLabel.isEmpty) {
        throw StateError(
          'A category without a name is not a landmark: a person always '
          'knows what they are configuring.',
        );
      }
      if (!identities.add(category.id)) {
        throw StateError('Two categories never share one identity.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.settings(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      categories: categories,
    );
  }
}
