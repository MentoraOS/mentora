import 'package:flutter/widgets.dart' show Widget;

import '../components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../components/button/mentora_button.dart';
import '../components/dialog/mentora_dialog_service.dart';
import '../components/snackbar/mentora_snackbar_service.dart';
import '../structure/bottom_navigation/mentora_bottom_navigation.dart';
import '../structure/navigation_drawer/mentora_navigation_drawer.dart';
import '../structure/navigation_rail/mentora_navigation_rail.dart';
import '../structure/workspace/mentora_workspace_style.dart';

/// The official shapes a screen of Mentora may take.
///
/// A product does not invent a shape per screen: it speaks these, and
/// only these. The vocabulary is the point — a layout adds no pixel of
/// its own, it names an assembly and guarantees it.
enum MentoraLayoutKind {
  /// One page, in the working context of the product.
  workspace,

  /// A page whose content is a set of panels.
  dashboard,

  /// A context whose whole point is the way through the product.
  navigation,

  /// A room shared between regions, in the working context.
  splitWorkspace,

  /// Two spaces in relation, in the working context.
  masterDetail,
}

/// What every layout of the family is handed.
///
/// It is the SAME contract for the five of them: the name of the
/// context, where the person is — already resolved —, the disposition
/// — already decided —, the way through the product, and the services
/// whose layers may be mounted. Nothing here is ever decided by a
/// layout; all of it is announced by the application.
final class MentoraLayoutContext {
  /// What the screen reader hears about the working context itself.
  final String semanticLabel;

  /// Where the person is, already resolved by the application.
  final MentoraWorkspaceNavigationState navigation;

  /// The disposition, already decided by the application.
  final MentoraWorkspaceConfiguration configuration;

  /// The way through the product — each channel remains the owner of
  /// what it expresses.
  final MentoraNavigationDrawer? orientation;
  final MentoraNavigationRail? rail;
  final MentoraBottomNavigation? base;

  /// The layers that come and go. Given a service, the official host
  /// is mounted for it; given none, nothing is mounted.
  final MentoraDialogService? dialogs;
  final MentoraBottomSheetService? sheets;
  final MentoraSnackbarService? messages;

  const MentoraLayoutContext({
    required this.semanticLabel,
    required this.navigation,
    this.configuration = const MentoraWorkspaceConfiguration(),
    this.orientation,
    this.rail,
    this.base,
    this.dialogs,
    this.sheets,
    this.messages,
  });

  /// Whether a way through the product was given at all.
  bool get carriesNavigation =>
      configuration.navigation != MentoraWorkspaceNavigationChannel.none;
}

/// One panel of a dashboard.
///
/// A panel is a subject, what is said about it, and the acts offered
/// on it. The layout composes the official container, the official
/// words and the official acts — it styles none of them, and it knows
/// nothing of what the panel carries.
final class MentoraDashboardPanel {
  /// What the panel is about. The application owns every string
  /// (Localization Engine); the layout composes none.
  final String title;

  /// What the panel carries. It belongs entirely to the application:
  /// the layout wraps it in nothing and changes nothing about it.
  final Widget content;

  /// The acts offered on the subject — the Button remains their owner.
  final List<MentoraButton> acts;

  const MentoraDashboardPanel({
    required this.title,
    required this.content,
    this.acts = const [],
  });
}
