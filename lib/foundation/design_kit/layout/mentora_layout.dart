import 'package:flutter/widgets.dart';

import '../structure/workspace/mentora_workspace.dart';
import '../structure/workspace/mentora_workspace_style.dart';
import 'mentora_layout_style.dart';

/// The single assembly of the Layout family.
///
/// Every official layout of Mentora is assembled HERE, and nowhere
/// else. A layout declares what makes it that layout — its typed zones
/// and its own contract — and hands the surface it built to this one
/// place. The working context, the way through the product and the
/// temporary layers are therefore composed exactly once for the five
/// of them: there is no second assembly to keep in step, and a scan
/// proves it.
///
/// It creates nothing: no scroll view, no padding, no decision. It
/// composes the official working context and gives it what it was
/// handed.
final class MentoraLayoutAssembly extends StatelessWidget {
  /// Which official shape this screen takes. It is expressed as a key,
  /// so that a screen can always be recognised for what it is.
  final MentoraLayoutKind kind;

  /// What every layout is handed — the same contract for all five.
  final MentoraLayoutContext frame;

  /// The surface being worked in, already built by the layout that
  /// owns it. It is sealed: the compiler admits exactly one.
  final MentoraWorkspaceSurface surface;

  const MentoraLayoutAssembly({
    super.key,
    required this.kind,
    required this.frame,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return MentoraWorkspace(
      key: Key('layout-${kind.name}'),
      semanticLabel: frame.semanticLabel,
      configuration: frame.configuration,
      navigation: frame.navigation,
      orientation: frame.orientation,
      rail: frame.rail,
      base: frame.base,
      dialogs: frame.dialogs,
      sheets: frame.sheets,
      messages: frame.messages,
      surface: surface,
    );
  }
}
