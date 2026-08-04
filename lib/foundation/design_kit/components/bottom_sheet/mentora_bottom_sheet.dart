import 'package:flutter/material.dart';

import '../../tokens/bottom_sheet_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_bottom_sheet_request.dart';
import 'mentora_bottom_sheet_style.dart';
import 'mentora_bottom_sheet_theme.dart';

/// The official Mentora sheet — the only contextual layer of the
/// product.
///
/// It never interrupts: it accompanies. It extends the screen, it
/// never replaces a page. It never occupies room without a reason —
/// only the variants that need it may expand. It disappears as soon
/// as its purpose is served.
///
/// It is the surface of an accompaniment, not a route: the
/// [MentoraBottomSheetService] decides when it lives, the host
/// expresses it. Every surface, form, breathing and duration comes
/// from the Design Kit through the [DesignKitScope].
final class MentoraBottomSheet extends StatelessWidget {
  final MentoraBottomSheetRequest request;
  final MentoraBottomSheetState state;

  /// Where the sheet currently rests — the truth belongs to the
  /// service; the sheet only expresses it.
  final MentoraBottomSheetDetent detent;

  /// The grip's gesture, when the sheet may be moved at all.
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;

  const MentoraBottomSheet({
    super.key,
    required this.request,
    required this.state,
    required this.detent,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraBottomSheetTheme.fromScope(
      DesignKitScope.of(context),
    );
    final visuals = theme.visualsOf(
      variant: request.variant,
      state: state,
    );
    final radius = Radius.circular(bottomSheetCornerRadius);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: request.semanticLabel ?? request.title,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: bottomSheetMaximumWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: visuals.surface,
            // The sheet is anchored to the bottom: only what rises
            // above the scene is rounded.
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
            ),
            border: Border.all(
              color: visuals.border,
              width: bottomSheetBorderWidth,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (request.expandable) _handle(theme, visuals),
                // The content is bounded by the detent it lives in: a
                // sheet never grows past the room it was given, and a
                // long list is the content's own business to scroll.
                Flexible(
                  child: Padding(
                    padding: theme.padding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MentoraText(request.title, role: theme.titleRole),
                        SizedBox(height: theme.contentGap),
                        if (state == MentoraBottomSheetState.processing) ...[
                          Center(
                            child: SizedBox(
                              width: theme.sectionGap,
                              height: theme.sectionGap,
                              child: CircularProgressIndicator(
                                strokeWidth: bottomSheetProgressStroke,
                                color: visuals.handle,
                              ),
                            ),
                          ),
                          SizedBox(height: theme.contentGap),
                        ],
                        Flexible(child: request.content),
                      ],
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

  /// The grip: painted small, reachable large — the target honors the
  /// opposable minimum even though the line stays discreet.
  Widget _handle(
    MentoraBottomSheetTheme theme,
    MentoraBottomSheetVisuals visuals,
  ) {
    return GestureDetector(
      key: const Key('sheet-handle'),
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: ExcludeSemantics(
        child: SizedBox(
          height: theme.handleTargetExtent,
          child: Center(
            child: Container(
              width: bottomSheetHandleWidth,
              height: bottomSheetHandleHeight,
              decoration: BoxDecoration(
                color: visuals.handle,
                borderRadius: BorderRadius.circular(bottomSheetHandleRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
