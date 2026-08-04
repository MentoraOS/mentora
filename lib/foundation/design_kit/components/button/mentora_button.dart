import 'package:flutter/material.dart';

import '../../tokens/button_tokens.dart';
import '../design_kit_scope.dart';
import 'mentora_button_style.dart';
import 'mentora_button_theme.dart';

/// The official Mentora button — the only button of the product.
///
/// Every dimension, color, typography and duration comes from the
/// Design Kit through the [DesignKitScope]; the widget holds no value.
/// Interaction states (pressed, focused, hovered) belong to the
/// component; asynchronous phases (loading, success, error) are driven
/// by an optional [MentoraButtonController] from the application layer.
final class MentoraButton extends StatefulWidget {
  final String label;

  /// Null means disabled — the absent act is expressed, never hidden.
  final VoidCallback? onPressed;
  final MentoraButtonVariant variant;
  final MentoraButtonSize size;
  final IconData? icon;
  final MentoraButtonIconPosition iconPosition;
  final MentoraButtonController? controller;

  const MentoraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MentoraButtonVariant.contained,
    this.size = MentoraButtonSize.medium,
    this.icon,
    this.iconPosition = MentoraButtonIconPosition.leading,
    this.controller,
  });

  @override
  State<MentoraButton> createState() => _MentoraButtonState();
}

final class _MentoraButtonState extends State<MentoraButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onPhaseChanged);
  }

  @override
  void didUpdateWidget(MentoraButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onPhaseChanged);
      widget.controller?.addListener(_onPhaseChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onPhaseChanged);
    super.dispose();
  }

  void _onPhaseChanged() {
    if (mounted) setState(() {});
  }

  MentoraButtonPhase get _phase =>
      widget.controller?.phase ?? MentoraButtonPhase.idle;

  /// Exactly one effective state; the resolution order is the
  /// component's contract: absence of act, then phase, then finger,
  /// then focus, then pointer.
  MentoraButtonState get _effectiveState {
    if (widget.onPressed == null) return MentoraButtonState.disabled;
    switch (_phase) {
      case MentoraButtonPhase.loading:
        return MentoraButtonState.loading;
      case MentoraButtonPhase.success:
        return MentoraButtonState.success;
      case MentoraButtonPhase.error:
        return MentoraButtonState.error;
      case MentoraButtonPhase.idle:
        break;
    }
    if (_pressed) return MentoraButtonState.pressed;
    if (_focused) return MentoraButtonState.focused;
    if (_hovered) return MentoraButtonState.hovered;
    return MentoraButtonState.idle;
  }

  /// The act is reachable only when nothing is pending — a phase in
  /// progress blocks the tap (fail closed) until the application
  /// resets its controller.
  bool get _actionable =>
      widget.onPressed != null && _phase == MentoraButtonPhase.idle;

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);
    final theme = MentoraButtonTheme.fromScope(scope);
    final spec = theme.specOf(widget.size);
    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);
    final minExtent = theme.minimumExtentOf(widget.size);
    final radius = BorderRadius.circular(buttonCornerRadius);

    return Semantics(
      button: true,
      enabled: _actionable,
      label: widget.label,
      child: AnimatedContainer(
        duration: theme.transitionDuration,
        constraints: BoxConstraints(minHeight: minExtent, minWidth: minExtent),
        decoration: BoxDecoration(
          color: visuals.background,
          borderRadius: radius,
          border: visuals.border == null
              ? null
              : Border.all(
                  color: visuals.border!,
                  width: visuals.borderWidth,
                ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            canRequestFocus: _actionable,
            overlayColor: WidgetStatePropertyAll(theme.pressedOverlay),
            onTap: _actionable ? widget.onPressed : null,
            onHover: (value) => setState(() => _hovered = value),
            onFocusChange: (value) => setState(() => _focused = value),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spec.horizontalPadding,
              ),
              // The button announces exactly one thing: its Semantics
              // label. The visual content never speaks twice (AFI-04:
              // the icon and the wait signal are decorative).
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _content(theme, spec, state, visuals),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    MentoraButtonTheme theme,
    ButtonSizeSpec spec,
    MentoraButtonState state,
    MentoraButtonVisuals visuals,
  ) {
    final label = Flexible(
      child: Text(
        widget.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.labelStyleOf(visuals),
      ),
    );

    final Widget? side;
    if (state == MentoraButtonState.loading) {
      // The wait is expressed where the icon lives — sober, exactly
      // one signal.
      side = SizedBox(
        width: spec.iconSize,
        height: spec.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: buttonSpinnerStroke,
          color: visuals.foreground,
        ),
      );
    } else if (widget.icon != null) {
      side = Icon(widget.icon, size: spec.iconSize, color: visuals.foreground);
    } else {
      side = null;
    }

    if (side == null) return [label];
    final gap = SizedBox(width: spec.iconGap);
    return widget.iconPosition == MentoraButtonIconPosition.leading
        ? [side, gap, label]
        : [label, gap, side];
  }
}
