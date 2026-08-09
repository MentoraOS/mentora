import '../../components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../../components/dialog/mentora_dialog_service.dart';
import '../../components/snackbar/mentora_snackbar_service.dart';
import '../../structure/bottom_navigation/mentora_bottom_navigation.dart';
import '../../structure/navigation_drawer/mentora_navigation_drawer.dart';
import '../../structure/navigation_rail/mentora_navigation_rail.dart';
import '../../structure/workspace/mentora_workspace_style.dart';

/// The official contract of the whole Layout layer.
///
/// Every layout of every family — the five that exist and the fifteen
/// that will — is handed exactly this, and never a context of its own.
/// There is no parallel contract in the product, and a scan proves it.
///
/// Nothing here is ever decided by a layout: the name of the working
/// context, the place the person is in, the disposition and the way
/// through the product are all announced by the application, already
/// resolved.
final class MentoraLayoutContext {
  /// What the screen reader hears about the working context itself.
  final String semanticLabel;

  /// Where the person is, already resolved by the application.
  final MentoraNavigationAnnouncement navigation;

  /// The disposition, already decided by the application.
  final MentoraWorkspaceConfiguration configuration;

  /// The way through the product — each channel remains the owner of
  /// what it expresses.
  final MentoraNavigationDrawer? orientation;
  final MentoraNavigationRail? rail;
  final MentoraBottomNavigation? base;

  /// The layers that come and go. Given a service, the official host
  /// is mounted for it by the assembly; given none, nothing is
  /// mounted. A layout never mounts a layer itself.
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
