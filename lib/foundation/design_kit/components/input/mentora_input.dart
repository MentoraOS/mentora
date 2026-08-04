import 'package:flutter/material.dart';

import '../../tokens/input_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_input_style.dart';
import 'mentora_input_theme.dart';
import 'mentora_input_validator.dart';

/// The official Mentora field — the only text entry of the product.
///
/// It carries a value; it judges none. Every chrome, state, spacing
/// and duration comes from the Design Kit through the
/// [DesignKitScope]; no decoration, no color and no size is ever
/// built here. It composes the Core Components it needs: its label,
/// its placeholder and its message are [MentoraText].
///
/// It re-decides nothing that already has an authority: the reading
/// direction, the input method, the text composition and the
/// autofill belong to the platform through the editing primitive —
/// no screen ever handles them specially.
final class MentoraInput extends StatefulWidget {
  final MentoraInputVariant variant;
  final MentoraInputAvailability availability;
  final MentoraInputSize size;

  /// What the field is — the application owns every string.
  final String? label;
  final String? placeholder;

  /// The calm explanation shown while no verdict has been published.
  final String? supportingMessage;

  final TextEditingController? textController;
  final FocusNode? focusNode;
  final MentoraInputController? controller;

  /// The business judge. Absent, nothing is ever judged: the Kit
  /// invents no rule.
  final MentoraInputValidator? validator;

  final ValueChanged<String>? onChanged;
  final IconData? leadingIcon;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  /// The screen reader's name for the field when it must differ from
  /// the visible label.
  final String? semanticLabel;

  /// The name of the reveal affordance of a secure field. Absent, the
  /// affordance is not rendered: a control is never offered without a
  /// name (the opposable requirement prevails over the convenience).
  final String? secureRevealLabel;

  const MentoraInput({
    super.key,
    this.variant = MentoraInputVariant.outlined,
    this.availability = MentoraInputAvailability.editable,
    this.size = MentoraInputSize.medium,
    this.label,
    this.placeholder,
    this.supportingMessage,
    this.textController,
    this.focusNode,
    this.controller,
    this.validator,
    this.onChanged,
    this.leadingIcon,
    this.keyboardType,
    this.autofillHints,
    this.semanticLabel,
    this.secureRevealLabel,
  });

  @override
  State<MentoraInput> createState() => _MentoraInputState();
}

final class _MentoraInputState extends State<MentoraInput> {
  late final TextEditingController _text =
      widget.textController ?? TextEditingController();
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  late final bool _ownsText = widget.textController == null;
  late final bool _ownsFocus = widget.focusNode == null;

  MentoraValidation _localVerdict = MentoraValidation.pristine;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(_onStateChanged);
    _focus.addListener(_onStateChanged);
    widget.controller?.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(MentoraInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStateChanged);
      widget.controller?.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _text.removeListener(_onStateChanged);
    _focus.removeListener(_onStateChanged);
    widget.controller?.removeListener(_onStateChanged);
    if (_ownsText) _text.dispose();
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  MentoraInputPhase get _phase =>
      widget.controller?.phase ?? MentoraInputPhase.idle;

  /// The published verdict wins over the local one: what the business
  /// announced is never overwritten by a keystroke's re-judgement.
  MentoraValidation get _verdict {
    final published = widget.controller?.validation;
    if (published != null &&
        published.state != MentoraValidationState.pristine) {
      return published;
    }
    return _localVerdict;
  }

  bool get _editable =>
      widget.availability == MentoraInputAvailability.editable &&
      _phase != MentoraInputPhase.loading;

  /// Exactly one effective state; the resolution order is the
  /// component's contract: availability, then the announced phase,
  /// then a refusal (never hidden by the focus), then the writing,
  /// then the accepted value, then the content.
  MentoraInputState get _effectiveState {
    switch (widget.availability) {
      case MentoraInputAvailability.disabled:
        return MentoraInputState.disabled;
      case MentoraInputAvailability.readOnly:
        return MentoraInputState.readOnly;
      case MentoraInputAvailability.editable:
        break;
    }
    switch (_phase) {
      case MentoraInputPhase.loading:
        return MentoraInputState.loading;
      case MentoraInputPhase.error:
        return MentoraInputState.error;
      case MentoraInputPhase.success:
        return MentoraInputState.success;
      case MentoraInputPhase.idle:
        break;
    }
    if (_verdict.isInvalid) return MentoraInputState.invalid;
    if (_focus.hasFocus) {
      return _text.text.isEmpty
          ? MentoraInputState.focused
          : MentoraInputState.typing;
    }
    if (_verdict.state == MentoraValidationState.valid) {
      return MentoraInputState.valid;
    }
    return _text.text.isEmpty
        ? MentoraInputState.idle
        : MentoraInputState.filled;
  }

  void _handleChanged(String value) {
    final validator = widget.validator;
    if (validator != null) {
      final verdict = validator.validate(value);
      if (verdict != _localVerdict) _localVerdict = verdict;
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraInputTheme.fromScope(DesignKitScope.of(context));
    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);
    final spec = theme.specOf(widget.size);
    final message = _verdict.message ?? widget.supportingMessage;
    final obscure =
        widget.variant == MentoraInputVariant.secure && !_revealed;

    final field = AnimatedContainer(
      // Motion accompanies a change of STATE inside a chrome; it never
      // interpolates between two chrome families (a base alone and an
      // enclosure are not two moments of the same shape).
      key: ValueKey(visuals.underlineOnly),
      duration: theme.transitionDurationFor(state),
      constraints: BoxConstraints(minHeight: theme.minimumExtentOf(widget.size)),
      padding: theme.paddingOf(widget.size),
      decoration: BoxDecoration(
        color: visuals.fill,
        borderRadius: visuals.underlineOnly
            ? null
            : BorderRadius.circular(visuals.cornerRadius),
        border: _borderOf(visuals),
      ),
      child: Row(
        children: [
          if (widget.leadingIcon != null) ...[
            ExcludeSemantics(
              child: Icon(
                widget.leadingIcon,
                size: spec.iconSize,
                color: visuals.iconColor,
              ),
            ),
            SizedBox(width: spec.iconGap),
          ],
          Expanded(child: _editor(theme, visuals, obscure)),
          ..._trailing(theme, visuals, spec, state, obscure),
        ],
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          MentoraText(widget.label!, role: theme.labelRole),
          SizedBox(height: theme.labelGap),
        ],
        field,
        if (message != null) ...[
          SizedBox(height: theme.labelGap),
          MentoraText(message, role: theme.messageRoleFor(state)),
        ],
      ],
    );

    return Semantics(
      container: true,
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      value: obscure ? null : _text.text,
      obscured: obscure,
      readOnly: !_editable,
      enabled: widget.availability != MentoraInputAvailability.disabled,
      child: state == MentoraInputState.disabled
          // Unavailability is stated, never hidden: the field stays
          // readable behind the official veil.
          ? Opacity(opacity: inputDisabledVeilOpacity, child: content)
          : content,
    );
  }

  BoxBorder? _borderOf(MentoraInputVisuals visuals) {
    final color = visuals.border;
    if (color == null) return null;
    final side = BorderSide(color: color, width: visuals.borderWidth);
    return visuals.underlineOnly
        ? Border(bottom: side)
        : Border.fromBorderSide(side);
  }

  Widget _editor(
    MentoraInputTheme theme,
    MentoraInputVisuals visuals,
    bool obscure,
  ) {
    // No InputDecoration exists anywhere in Mentora: the chrome is
    // the component's, and the editing primitive is left bare.
    final editor = TextField(
      controller: _text,
      focusNode: _focus,
      decoration: null,
      style: theme.valueStyle(visuals),
      cursorColor: visuals.foreground,
      enabled: widget.availability != MentoraInputAvailability.disabled,
      readOnly: !_editable,
      obscureText: obscure,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      onChanged: _handleChanged,
    );

    final placeholder = widget.placeholder;
    if (placeholder == null || _text.text.isNotEmpty) return editor;

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        // The suggestion never replaces the label, and never speaks to
        // the screen reader twice (AFI-04).
        ExcludeSemantics(
          child: MentoraText(
            placeholder,
            role: theme.placeholderRole,
            maxLines: 1,
          ),
        ),
        editor,
      ],
    );
  }

  List<Widget> _trailing(
    MentoraInputTheme theme,
    MentoraInputVisuals visuals,
    InputSizeSpec spec,
    MentoraInputState state,
    bool obscure,
  ) {
    if (state == MentoraInputState.loading) {
      return [
        SizedBox(width: spec.iconGap),
        SizedBox(
          width: spec.iconSize,
          height: spec.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: inputProgressStroke,
            color: visuals.iconColor,
          ),
        ),
      ];
    }

    final revealLabel = widget.secureRevealLabel;
    if (widget.variant == MentoraInputVariant.secure && revealLabel != null) {
      return [
        SizedBox(width: spec.iconGap),
        Semantics(
          button: true,
          label: revealLabel,
          child: InkWell(
            onTap: () => setState(() => _revealed = !_revealed),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: theme.minimumExtentOf(widget.size),
                minHeight: theme.minimumExtentOf(widget.size),
              ),
              child: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: spec.iconSize,
                color: visuals.iconColor,
              ),
            ),
          ),
        ),
      ];
    }

    final icon = theme.validationIconFor(state);
    if (icon == null) return const [];
    return [
      SizedBox(width: spec.iconGap),
      ExcludeSemantics(
        child: Icon(icon, size: spec.iconSize, color: visuals.iconColor),
      ),
    ];
  }
}
