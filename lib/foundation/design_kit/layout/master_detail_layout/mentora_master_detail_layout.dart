import 'package:flutter/widgets.dart';

import '../../structure/master_detail/mentora_master_detail.dart';
import '../../structure/master_detail/mentora_master_detail_style.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';

/// The official Master Detail Layout - two spaces in relation, in the
/// working context of the product.
///
/// It is the shape of everything one browses then reads: a set of
/// entities presented on one side, what one of them holds on the
/// other.
///
/// It decides nothing: how the relation is presented, whether the
/// presenting space is shown, which space is being worked in and the
/// room it takes are all announced, already decided, by the
/// application.
final class MentoraMasterDetailLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// The space that presents, and the space that deepens. Both belong
  /// entirely to the application.
  final Widget master;
  final Widget detail;

  /// The room the spaces take, already decided.
  final MentoraMasterDetailLayoutSpecification specification;

  /// How the relation is presented, whether the presenting space is
  /// shown, and which space is being worked in.
  final MentoraMasterDetailPresentation presentation;
  final MentoraMasterPaneVisibility visibility;
  final MentoraMasterDetailRegion activeRegion;

  /// What the screen reader hears about each space: two landmarks,
  /// each named.
  final String masterSemanticLabel;
  final String detailSemanticLabel;

  /// Asking for the presenting space to step aside. The layout hands
  /// the intention on; the application decides.
  final VoidCallback? onDismissRequested;

  const MentoraMasterDetailLayout({
    super.key,
    required this.frame,
    required this.master,
    required this.detail,
    required this.specification,
    required this.masterSemanticLabel,
    required this.detailSemanticLabel,
    this.presentation = MentoraMasterDetailPresentation.split,
    this.visibility = MentoraMasterPaneVisibility.shown,
    this.activeRegion = MentoraMasterDetailRegion.detail,
    this.onDismissRequested,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.masterDetail;

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.relation(
      MentoraMasterDetail(
        master: master,
        detail: detail,
        layout: specification,
        presentation: presentation,
        visibility: visibility,
        activeRegion: activeRegion,
        masterSemanticLabel: masterSemanticLabel,
        detailSemanticLabel: detailSemanticLabel,
        onDismissRequested: onDismissRequested,
      ),
    );
  }
}
