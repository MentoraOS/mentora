import 'package:flutter/material.dart';

import '../../tokens/card_tokens.dart';
import '../design_kit_scope.dart';
import 'mentora_card_style.dart';
import 'mentora_card_theme.dart';

/// The official Mentora container — the only card of the product.
///
/// It contains, organizes, protects and hierarchizes. It never
/// decides: it holds the child it is given and invents no content,
/// no string, no substitute. Every surface, delimitation, depth,
/// breathing and duration comes from the Design Kit through the
/// [DesignKitScope]; the widget holds no value.
final class MentoraCard extends StatefulWidget {
  final Widget child;
  final MentoraCardVariant variant;

  /// The act the container invites, when it invites one. An
  /// [MentoraCardVariant.interactive] card without an act is refused
  /// (fail closed): a container that invites must lead somewhere.
  final VoidCallback? onTap;

  /// The container's own announcement for screen readers. The
  /// application owns every string (Localization Engine); the card
  /// never composes one.
  final String? semanticLabel;

  final bool enabled;
  final MentoraCardController? controller;

  const MentoraCard({
    super.key,
    required this.child,
    this.variant = MentoraCardVariant.surface,
    this.onTap,
    this.semanticLabel,
    this.enabled = true,
    this.controller,
  });

  @override
  State<MentoraCard> createState() => _MentoraCardState();
}

final class _MentoraCardState extends State<MentoraCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onPhaseChanged);
  }

  @override
  void didUpdateWidget(MentoraCard oldWidget) {
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

  MentoraCardPhase get _phase =>
      widget.controller?.phase ?? MentoraCardPhase.idle;

  /// The act is served only when the container invites one, is
  /// enabled, and its content is not pending. An error never blocks
  /// the act: the application may offer to try again.
  bool get _actionable =>
      widget.onTap != null &&
      widget.enabled &&
      _phase != MentoraCardPhase.loading;

  /// Exactly one effective state; the resolution order is the
  /// component's contract: unavailability, then the content's phase,
  /// then the finger, the focus, the pointer, then the selection.
  MentoraCardState get _effectiveState {
    if (!widget.enabled) return MentoraCardState.disabled;
    switch (_phase) {
      case MentoraCardPhase.loading:
        return MentoraCardState.loading;
      case MentoraCardPhase.error:
        return MentoraCardState.error;
      case MentoraCardPhase.idle:
        break;
    }
    if (_pressed) return MentoraCardState.pressed;
    if (_focused) return MentoraCardState.focused;
    if (_hovered) return MentoraCardState.hovered;
    if (widget.variant == MentoraCardVariant.selected) {
      return MentoraCardState.selected;
    }
    return MentoraCardState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);
    if (widget.variant == MentoraCardVariant.interactive &&
        widget.onTap == null) {
      throw StateError(
        'An interactive card without an act is refused: a container '
        'that invites must lead somewhere.',
      );
    }

    final theme = MentoraCardTheme.fromScope(scope);
    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);
    final radius = BorderRadius.circular(cardCornerRadius);

    Widget content = Padding(padding: theme.padding, child: widget.child);
    if (state == MentoraCardState.disabled) {
      // Unavailability is stated, never hidden — the content stays
      // readable behind the official veil (OpacityRole.disabledVeil).
      content = Opacity(opacity: cardDisabledVeilOpacity, child: content);
    }

    final decorated = AnimatedContainer(
      duration: theme.transitionDuration,
      constraints: widget.onTap == null
          ? const BoxConstraints()
          : BoxConstraints(
              minHeight: theme.minimumInteractiveExtent,
              minWidth: theme.minimumInteractiveExtent,
            ),
      decoration: BoxDecoration(
        color: visuals.background,
        borderRadius: radius,
        border: visuals.border == null
            ? null
            : Border.all(color: visuals.border!, width: visuals.borderWidth),
        boxShadow: visuals.shadow,
      ),
      child: widget.onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                canRequestFocus: _actionable,
                overlayColor: WidgetStatePropertyAll(theme.overlay),
                onTap: _actionable ? widget.onTap : null,
                onHover: (value) => setState(() => _hovered = value),
                onFocusChange: (value) => setState(() => _focused = value),
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: content,
              ),
            ),
    );

    return Semantics(
      // A container groups — it becomes a button only when it invites
      // an act, and it is selected only when it carries the selection.
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      button: widget.onTap != null,
      enabled: widget.onTap == null ? null : _actionable,
      selected: widget.variant == MentoraCardVariant.selected,
      child: decorated,
    );
  }
}
