import 'package:flutter/material.dart';

import '../../tokens/snackbar_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_snackbar_request.dart';
import 'mentora_snackbar_style.dart';
import 'mentora_snackbar_theme.dart';

/// The official Mentora message — the only transient signal of the
/// product.
///
/// It never asks: it carries no act, because an act to answer is a
/// dialog. It informs, confirms, reassures — then disappears alone.
/// It never interrupts, never traps the focus, never competes with a
/// dialog and never replaces a notification. One message, one idea.
///
/// It is the surface of a signal, not a route: the
/// [MentoraSnackbarService] decides when it speaks, the host expresses
/// it. Every surface, form, breathing and duration comes from the
/// Design Kit through the [DesignKitScope].
final class MentoraSnackbar extends StatelessWidget {
  final MentoraSnackbarRequest request;
  final MentoraSnackbarState state;

  const MentoraSnackbar({
    super.key,
    required this.request,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraSnackbarTheme.fromScope(DesignKitScope.of(context));
    final visuals = theme.visualsOf(
      variant: request.variant,
      state: state,
    );
    final icon = theme.iconOf(request.variant);

    return Semantics(
      container: true,
      // The message is announced where it appears — it never takes
      // the focus, and it never interrupts keyboard navigation.
      liveRegion: true,
      label: request.semanticLabel ?? request.message,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: snackbarMaximumWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: visuals.surface,
            borderRadius: BorderRadius.circular(snackbarCornerRadius),
            border: Border.all(
              color: visuals.border,
              width: snackbarBorderWidth,
            ),
          ),
          child: Padding(
            padding: theme.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  ExcludeSemantics(
                    child: Icon(
                      icon,
                      size: snackbarIconSize,
                      color: visuals.accent,
                    ),
                  ),
                  SizedBox(width: theme.contentGap),
                ] else if (request.reportsOngoing) ...[
                  // A state still happening shows exactly one sober
                  // signal — never a story.
                  ExcludeSemantics(
                    child: SizedBox(
                      width: snackbarIconSize,
                      height: snackbarIconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: snackbarProgressStroke,
                        color: visuals.accent,
                      ),
                    ),
                  ),
                  SizedBox(width: theme.contentGap),
                ],
                Flexible(
                  child: ExcludeSemantics(
                    child: MentoraText(
                      request.message,
                      role: theme.messageRole,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
