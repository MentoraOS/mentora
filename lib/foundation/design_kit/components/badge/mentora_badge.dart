import 'package:flutter/material.dart';

import '../../tokens/badge_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_badge_style.dart';
import 'mentora_badge_theme.dart';

/// The official Mentora badge — the state language of the product.
///
/// It affirms a state. It never tells a story, never asks for a
/// decision, never replaces a dialog or a message, and never competes
/// with a title: it completes an information, never the reverse.
///
/// **A badge is never interactive.** It carries no act, no gesture and
/// no destination — if a person can act on it, it is no longer a
/// badge. An executable scan keeps it that way.
///
/// Every colour, distance, form and duration comes from the Design Kit
/// through the [DesignKitScope]; the widget holds no value.
final class MentoraBadge extends StatefulWidget {
  final MentoraBadgeVariant variant;
  final MentoraBadgeShape shape;
  final MentoraBadgeSize size;

  /// The value shown. The application owns every string (Localization
  /// Engine); the Kit composes none.
  final String? label;

  /// What the screen reader hears: the value, the status and the
  /// context. A form that shows no words REQUIRES it — a state is
  /// never carried by colour alone (AFS-01).
  final String? semanticLabel;

  /// The resting state, when it never changes.
  final MentoraBadgeState state;

  /// The state over time, when the application makes it change. It
  /// prevails over [state]: one truth, announced from outside.
  final MentoraBadgeController? controller;

  const MentoraBadge({
    super.key,
    required this.variant,
    this.shape = MentoraBadgeShape.label,
    this.size = MentoraBadgeSize.medium,
    this.label,
    this.semanticLabel,
    this.state = MentoraBadgeState.idle,
    this.controller,
  });

  @override
  State<MentoraBadge> createState() => _MentoraBadgeState();
}

final class _MentoraBadgeState extends State<MentoraBadge> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onStateAnnounced);
  }

  @override
  void didUpdateWidget(MentoraBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStateAnnounced);
      widget.controller?.addListener(_onStateAnnounced);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onStateAnnounced);
    super.dispose();
  }

  void _onStateAnnounced() {
    if (mounted) setState(() {});
  }

  MentoraBadgeState get _effectiveState =>
      widget.controller?.state ?? widget.state;

  /// What the screen reader will say. A form without words that says
  /// nothing is refused: a state is never left to the colour.
  String _announcement() {
    final spoken = widget.semanticLabel ?? widget.label;
    if (spoken == null || spoken.isEmpty) {
      throw StateError(
        'A badge states its meaning: a form without words requires a '
        'semanticLabel — a state is never carried by colour alone.',
      );
    }
    return spoken;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraBadgeTheme.fromScope(DesignKitScope.of(context));
    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);
    final spec = theme.specOf(widget.size);
    final announcement = _announcement();

    final Widget body;
    if (widget.shape == MentoraBadgeShape.dot) {
      body = SizedBox(
        width: spec.dotDiameter,
        height: spec.dotDiameter,
        child: DecoratedBox(
          key: const Key('badge-mark'),
          decoration: BoxDecoration(
            color: visuals.accent,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      body = ConstrainedBox(
        constraints: BoxConstraints(minHeight: spec.height),
        child: Padding(
          padding: theme.paddingOf(widget.shape, widget.size),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _content(theme, spec, state, visuals),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: announcement,
      // The badge announces exactly once: what it paints never speaks
      // a second time (AFI-04).
      child: ExcludeSemantics(
        child: Opacity(
          opacity: visuals.opacity,
          child: AnimatedContainer(
            duration: theme.transitionDuration,
            curve: theme.curve,
            decoration: BoxDecoration(
              color: widget.shape == MentoraBadgeShape.dot
                  ? null
                  : visuals.ground,
              borderRadius: widget.shape == MentoraBadgeShape.dot
                  ? null
                  : BorderRadius.circular(theme.radiusOf(widget.shape)),
              border: widget.shape == MentoraBadgeShape.dot
                  ? null
                  : Border.all(
                      color: visuals.border,
                      width: badgeBorderWidth,
                    ),
            ),
            child: body,
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    MentoraBadgeTheme theme,
    BadgeSizeSpec spec,
    MentoraBadgeState state,
    MentoraBadgeVisuals visuals,
  ) {
    final children = <Widget>[];

    if (state == MentoraBadgeState.processing) {
      // A state still settling shows exactly one sober signal.
      children.add(
        SizedBox(
          width: spec.iconSize,
          height: spec.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: badgeProgressStroke,
            color: visuals.accent,
          ),
        ),
      );
    } else if (showsIcon(widget.shape)) {
      children.add(
        Icon(
          theme.iconOf(widget.variant),
          size: spec.iconSize,
          color: visuals.accent,
        ),
      );
    }

    final label = widget.label;
    if (showsWords(widget.shape) && label != null && label.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: theme.gapOf(widget.size)));
      }
      children.add(
        Flexible(
          child: MentoraText(
            label,
            role: theme.textRoleOf(widget.size),
            color: theme.textColorRoleOf(
              variant: widget.variant,
              state: state,
            ),
            maxLines: 1,
          ),
        ),
      );
    }

    return children;
  }
}
