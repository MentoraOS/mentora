import 'package:flutter/widgets.dart';

import 'mentora_layout_assembly.dart';
import 'mentora_layout_context.dart';
import 'mentora_layout_kind.dart';

/// What every official layout of Mentora IS.
///
/// A layout is a SPECIALIZATION of this foundation: it says which
/// official shape it is, it is handed the one official context, it
/// describes the surface it needs, and it refuses its own contract
/// when that contract is not honoured.
///
/// It does nothing else. The assembly below is the only path from a
/// specialization to a screen — a layout cannot assemble itself,
/// cannot create a working context, cannot create a page and cannot
/// mount a layer, because it never builds anything at all.
///
/// This is why the family can grow to fifteen or twenty shapes without
/// a single refactoring: a new layout declares four things, and
/// inherits everything else, forever.
abstract base class MentoraLayout extends StatelessWidget {
  const MentoraLayout({super.key});

  /// Which official shape this layout materializes — from the closed
  /// registry, never a name of its own.
  MentoraLayoutKind get kind;

  /// The one official context, handed by the application.
  MentoraLayoutContext get frame;

  /// The surface this layout asks for. It is a description: the
  /// assembly is what builds it.
  MentoraLayoutSurface surfaceOf(BuildContext context);

  /// What this layout refuses.
  ///
  /// The foundation verifies what every layout owes — a named context;
  /// a specialization adds only what it owes as itself.
  void verify() {}

  @override
  Widget build(BuildContext context) {
    if (frame.semanticLabel.isEmpty) {
      throw StateError(
        'A working context announces itself: without a name a person '
        'never knows where they are working.',
      );
    }
    verify();

    return MentoraLayoutAssembly(
      kind: kind,
      frame: frame,
      surface: surfaceOf(context),
    );
  }
}
