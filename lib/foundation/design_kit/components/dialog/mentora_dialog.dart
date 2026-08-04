import 'package:flutter/material.dart';

import '../../tokens/dialog_tokens.dart';
import '../button/mentora_button.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_dialog_request.dart';
import 'mentora_dialog_style.dart';
import 'mentora_dialog_theme.dart';

/// The official Mentora dialog — the only overlay of the product.
///
/// It never surprises: it explains, reassures, protects and confirms.
/// It never forces: a dialog that asks always offers at least two ways
/// out. It never manipulates: one recommendation at most, a dangerous
/// act stays explicit and is never performed by a keystroke. It never
/// hides a consequence: a critical dialog states what it will cost.
///
/// It is the surface of an exchange, not a route: the
/// [MentoraDialogService] decides when it lives, the host expresses
/// it. Every surface, delimitation, breathing and duration comes from
/// the Design Kit through the [DesignKitScope].
final class MentoraDialog extends StatelessWidget {
  final MentoraDialogRequest request;
  final MentoraDialogState state;

  /// The act chosen by the person — the dialog reports, it decides
  /// nothing.
  final ValueChanged<MentoraDialogAction> onAction;

  const MentoraDialog({
    super.key,
    required this.request,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraDialogTheme.fromScope(DesignKitScope.of(context));
    final visuals = theme.visualsOf(variant: request.variant, state: state);
    final icon = theme.iconOf(request.variant);
    final consequence = request.consequence;
    final acting = state == MentoraDialogState.processing;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: request.semanticLabel ?? request.title,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: dialogMaximumWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: visuals.surface,
            borderRadius: BorderRadius.circular(dialogCornerRadius),
            border: Border.all(color: visuals.border, width: dialogBorderWidth),
          ),
          child: Padding(
            padding: theme.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  ExcludeSemantics(
                    child: Icon(
                      icon,
                      size: dialogIconSize,
                      color: visuals.accent,
                    ),
                  ),
                  SizedBox(height: theme.contentGap),
                ],
                MentoraText(request.title, role: theme.titleRole),
                SizedBox(height: theme.contentGap),
                MentoraText(
                  request.message,
                  role: theme.messageRole,
                  maxLines: null,
                ),
                if (consequence != null) ...[
                  SizedBox(height: theme.contentGap),
                  MentoraText(
                    consequence,
                    role: theme.consequenceRoleFor(request.variant),
                    maxLines: null,
                  ),
                ],
                if (state == MentoraDialogState.processing ||
                    request.variant == MentoraDialogVariant.progress) ...[
                  SizedBox(height: theme.sectionGap),
                  Center(
                    child: SizedBox(
                      width: dialogIconSize,
                      height: dialogIconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: dialogProgressStroke,
                        color: visuals.accent,
                      ),
                    ),
                  ),
                ],
                if (request.actions.isNotEmpty) ...[
                  SizedBox(height: theme.sectionGap),
                  Wrap(
                    spacing: theme.contentGap,
                    runSpacing: theme.contentGap,
                    alignment: WrapAlignment.end,
                    children: [
                      for (final action in request.actions)
                        MentoraButton(
                          key: Key('dialog-action-${action.id}'),
                          label: action.label,
                          // While the application works, no act is
                          // offered twice.
                          onPressed: acting ? null : () => onAction(action),
                          variant: theme.buttonVariantOf(
                            action,
                            request.variant,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
