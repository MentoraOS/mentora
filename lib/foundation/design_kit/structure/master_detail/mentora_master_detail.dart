import 'package:flutter/material.dart';

import '../../components/design_kit_scope.dart';
import '../../tokens/master_detail_tokens.dart';
import 'mentora_master_detail_style.dart';
import 'mentora_master_detail_theme.dart';

/// The official Mentora two-space container — the eighth Structural
/// Component, and the only master-detail of the product.
///
/// A master detail is not a layout: it is a RELATION. One space
/// presents, the other deepens, and the relation holds them together
/// without ever knowing what either of them carries.
///
/// Five things it never does, and each is verified:
/// - it never knows the platform, and takes no responsive decision:
///   the application announces the presentation;
/// - it never decides which space is shown: it is told;
/// - it never knows the content, the business or the data: it is
///   given two widgets, and it changes nothing about them;
/// - it never computes a proportion: the room is announced, already
///   decided, and it is expressed;
/// - it never knows a selection: it orchestrates two spaces, and
///   nothing that happens inside them.
///
/// The room is expressed by placement alone: nothing is measured,
/// nothing is computed and nothing is shared out — so the relation
/// cannot even accidentally decide it.
final class MentoraMasterDetail extends StatelessWidget {
  /// The space that presents. It belongs entirely to the application:
  /// the relation wraps it in nothing and changes nothing about it.
  final Widget master;

  /// The space that deepens. Same contract: it is carried, never
  /// touched.
  final Widget detail;

  /// How the relation is presented — announced by the application,
  /// which alone knows the surface and the moment.
  final MentoraMasterDetailPresentation presentation;

  /// Whether the presenting space is shown. The relation never puts it
  /// away and never brings it back: it is told.
  final MentoraMasterPaneVisibility visibility;

  /// Which of the two spaces is being worked in. It is announced, and
  /// expressed — never guessed, and never decided.
  final MentoraMasterDetailRegion activeRegion;

  /// The room the spaces take, already decided by the application.
  final MentoraMasterDetailLayoutSpecification layout;

  /// What the screen reader hears about each region: two landmarks,
  /// each named, so a person always knows which space they are in.
  final String masterSemanticLabel;
  final String detailSemanticLabel;

  /// Asking for the presenting space to be put away. The relation
  /// reports the intention; the application decides. It exists only
  /// where a veil can carry it.
  final VoidCallback? onDismissRequested;

  const MentoraMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    required this.layout,
    required this.masterSemanticLabel,
    required this.detailSemanticLabel,
    this.presentation = MentoraMasterDetailPresentation.split,
    this.visibility = MentoraMasterPaneVisibility.shown,
    this.activeRegion = MentoraMasterDetailRegion.detail,
    this.onDismissRequested,
  });

  /// The contracts a relation must honor — verified once, at build,
  /// and refused when they are not met.
  void _verify() {
    if (masterSemanticLabel.isEmpty || detailSemanticLabel.isEmpty) {
      throw StateError(
        'A region without a name is not a landmark: a person always '
        'knows which space they are in.',
      );
    }
    layout.verify();
    if (!showsRegion(activeRegion, presentation, visibility)) {
      throw StateError(
        'The region announced as active is not one this relation shows '
        'right now: a relation never guesses where the person works.',
      );
    }
    if (onDismissRequested != null &&
        presentation != MentoraMasterDetailPresentation.overlay) {
      throw StateError(
        'Only a space that passes in front of another can be asked to '
        'step aside: elsewhere, the application decides alone.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraMasterDetailTheme.fromScope(
      DesignKitScope.of(context),
    );
    _verify();

    final visuals = theme.visualsOf(presentation);
    final shownMaster = showsMaster(presentation, visibility);

    // Two named landmarks, and nothing above them: the relation adds
    // no node of its own between a person and the space they work in.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        key: const Key('master-detail'),
        children: _spaces(theme, visuals, shownMaster: shownMaster),
      ),
    );
  }

  /// Where each space stands.
  ///
  /// Placement only: a start, an end and an announced extent. Nothing
  /// here is a proportion, and nothing here is measured.
  List<Widget> _spaces(
    MentoraMasterDetailTheme theme,
    MentoraMasterDetailVisuals visuals, {
    required bool shownMaster,
  }) {
    final masterSpace = _region(
      theme,
      region: MentoraMasterDetailRegion.master,
      label: masterSemanticLabel,
      child: master,
    );
    final detailSpace = _region(
      theme,
      region: MentoraMasterDetailRegion.detail,
      label: detailSemanticLabel,
      child: detail,
    );

    switch (presentation) {
      case MentoraMasterDetailPresentation.stacked:
        // One space at a time takes the whole room; the other is not
        // built, so nothing of it is reachable or announced.
        return [
          Positioned.fill(child: shownMaster ? masterSpace : detailSpace),
        ];

      case MentoraMasterDetailPresentation.split:
        if (!shownMaster) {
          return [Positioned.fill(child: detailSpace)];
        }
        final line = layout.masterExtent;
        return [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: layout.masterExtent,
            child: masterSpace,
          ),
          PositionedDirectional(
            start: line,
            top: 0,
            bottom: 0,
            width: masterDetailDividerThickness,
            child: ColoredBox(
              key: const Key('master-detail-divider'),
              color: visuals.divider,
            ),
          ),
          // The space that deepens is given exactly what is left of
          // the room — never a share of it, and never a computed one.
          PositionedDirectional(
            start: line + masterDetailDividerThickness,
            end: 0,
            top: 0,
            bottom: 0,
            child: detailSpace,
          ),
        ];

      case MentoraMasterDetailPresentation.overlay:
        return [
          Positioned.fill(child: detailSpace),
          if (shownMaster) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Asking to step aside is reported, never performed.
                onTap: onDismissRequested,
                child: ColoredBox(
                  key: const Key('master-detail-scrim'),
                  color: visuals.scrim,
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: layout.masterExtent,
              child: masterSpace,
            ),
          ],
        ];
    }
  }

  /// One space of the relation: a named landmark, its own focus
  /// group, and the ground that says whether it is the one being
  /// worked in.
  Widget _region(
    MentoraMasterDetailTheme theme, {
    required MentoraMasterDetailRegion region,
    required String label,
    required Widget child,
  }) {
    final visuals = theme.regionVisualsOf(
      region: region,
      activeRegion: activeRegion,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      selected: region == activeRegion,
      // Each space travels as its own focus group: moving through a
      // relation follows its spaces, and never wanders between them.
      child: FocusTraversalGroup(
        child: AnimatedContainer(
          key: Key('master-detail-${region.name}'),
          duration: theme.transitionDuration,
          curve: theme.curve,
          decoration: BoxDecoration(color: visuals.surface),
          child: child,
        ),
      ),
    );
  }
}
