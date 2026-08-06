import 'package:flutter/material.dart';

import '../../components/button/mentora_button.dart';
import '../../components/button/mentora_button_style.dart';
import '../../components/design_kit_scope.dart';
import '../../components/input/mentora_input.dart';
import '../../components/input/mentora_input_style.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/search_bar_tokens.dart';
import 'mentora_search_bar_style.dart';
import 'mentora_search_bar_theme.dart';

/// The official Mentora intention bar — the fourth Structural
/// Component.
///
/// A search bar is not a text field: it carries an INTENTION. It helps
/// someone find, and it finds nothing itself. Four things it never
/// does, and each is verified:
/// - it never knows the data: it knows a query, and a query is never
///   a result;
/// - it never interprets, never normalizes and never matches anything;
/// - it never seeks: it reports an intention, and the application
///   decides what to do with it;
/// - an aid is never a way somewhere: choosing one is REPORTED, never
///   performed — the bar does not even fill its own field.
///
/// Flutter's own search widgets stay primitives: none is used. The
/// entry itself is a [MentoraInput], which owns it.
final class MentoraSearchBar extends StatefulWidget {
  final MentoraSearchController controller;

  /// What a person meant, as they wrote it. The bar reports; the
  /// application decides.
  final ValueChanged<MentoraSearchQuery> onQueryChanged;

  /// That the person considers their intention written.
  final ValueChanged<MentoraSearchQuery>? onSubmitted;

  /// That an aid was chosen — reported by identity, never performed.
  final ValueChanged<String>? onSuggestionChosen;

  /// What invites the intention. The application owns every string.
  final String placeholder;

  /// The name of the act that empties the intention. Absent, the act
  /// is not offered: a control without a name is never rendered.
  final String? clearLabel;

  /// What the screen reader hears about the bar itself.
  final String semanticLabel;

  final MentoraSearchBarVariant variant;

  /// Prepared, never performed: the Kit captures no voice and keeps no
  /// history — the application owns both.
  final MentoraSearchAffordance? voice;
  final MentoraSearchAffordance? history;

  final bool enabled;

  const MentoraSearchBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    required this.placeholder,
    required this.semanticLabel,
    this.onSubmitted,
    this.onSuggestionChosen,
    this.clearLabel,
    this.variant = MentoraSearchBarVariant.standard,
    this.voice,
    this.history,
    this.enabled = true,
  });

  @override
  State<MentoraSearchBar> createState() => _MentoraSearchBarState();
}

final class _MentoraSearchBarState extends State<MentoraSearchBar> {
  late final TextEditingController _text = TextEditingController(
    text: widget.controller.query.text,
  );
  late final FocusNode _focus = FocusNode();
  final Set<String> _heldAids = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAnnounced);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(MentoraSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onAnnounced);
      widget.controller.addListener(_onAnnounced);
      // A new acknowledgement replaces the previous one: the field
      // always shows the intention that is currently acknowledged.
      _syncAcknowledgedIntention();
    }
  }

  void _syncAcknowledgedIntention() {
    final acknowledged = widget.controller.query.text;
    if (_text.text == acknowledged) return;
    _text.value = TextEditingValue(
      text: acknowledged,
      selection: TextSelection.collapsed(offset: acknowledged.length),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAnnounced);
    _focus.removeListener(_onFocusChanged);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  /// The application acknowledged an intention: the field shows what
  /// it acknowledged, and nothing else.
  void _onAnnounced() {
    if (!mounted) return;
    _syncAcknowledgedIntention();
    setState(() {});
  }

  MentoraSearchPhase get _phase => widget.controller.phase;

  /// Exactly one effective state: availability, then what the
  /// application announced, then the writing, then the focus.
  MentoraSearchBarState get _effectiveState {
    if (!widget.enabled) return MentoraSearchBarState.disabled;
    switch (_phase) {
      case MentoraSearchPhase.error:
        return MentoraSearchBarState.error;
      case MentoraSearchPhase.searching:
        return MentoraSearchBarState.searching;
      case MentoraSearchPhase.loading:
        return MentoraSearchBarState.loading;
      case MentoraSearchPhase.idle:
        break;
    }
    if (_focus.hasFocus) {
      return _text.text.isEmpty
          ? MentoraSearchBarState.focused
          : MentoraSearchBarState.typing;
    }
    return MentoraSearchBarState.idle;
  }

  void _verify() {
    if (widget.placeholder.isEmpty || widget.semanticLabel.isEmpty) {
      throw StateError(
        'An intention bar says what it invites: without a name it '
        'invites nothing.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraSearchBarTheme.fromScope(DesignKitScope.of(context));
    _verify();

    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);
    final presentation = specOf(widget.variant);
    final aids = widget.controller.suggestions;

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Opacity(
        key: const Key('search-presence'),
        opacity: visuals.opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              key: const Key('search-surface'),
              duration: theme.transitionDuration,
              curve: theme.curve,
              constraints: BoxConstraints(
                minHeight: theme.extentOf(widget.variant),
              ),
              padding: theme.padding,
              decoration: BoxDecoration(
                color: visuals.ground,
                borderRadius: BorderRadius.circular(presentation.radius),
                border: visuals.border == null
                    ? null
                    : Border.all(
                        color: visuals.border!,
                        width: searchBarBorderWidth,
                      ),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      theme.intentionMark,
                      size: searchBarIconSize,
                      color: visuals.mark,
                    ),
                  ),
                  SizedBox(width: theme.gap),
                  Expanded(child: _entry(state)),
                  ..._acts(theme),
                ],
              ),
            ),
            if (state == MentoraSearchBarState.searching ||
                state == MentoraSearchBarState.loading)
              const LinearProgressIndicator(
                key: Key('search-progress'),
                minHeight: searchBarProgressThickness,
              ),
            if (aids.isNotEmpty) ...[
              SizedBox(height: theme.gap),
              // Aids are offered, never applied: choosing one is
              // reported and the application decides what it means.
              for (final aid in aids) _aid(theme, aid),
            ],
          ],
        ),
      ),
    );
  }

  /// The entry belongs to the Input: it owns the writing, the input
  /// method and the composition of text.
  Widget _entry(MentoraSearchBarState state) {
    return MentoraInput(
      key: const Key('search-entry'),
      variant: MentoraInputVariant.search,
      availability: widget.enabled
          ? MentoraInputAvailability.editable
          : MentoraInputAvailability.disabled,
      textController: _text,
      focusNode: _focus,
      placeholder: widget.placeholder,
      semanticLabel: widget.semanticLabel,
      keyboardType: TextInputType.text,
      // The bar reports what was written; it decides nothing.
      onChanged: (value) => widget.onQueryChanged(MentoraSearchQuery(value)),
    );
  }

  /// What stands beside the intention: emptying it, speaking it, or
  /// recalling the ones already written. Each is offered only when the
  /// application named it, and none is performed here.
  List<Widget> _acts(MentoraSearchBarTheme theme) {
    final acts = <Widget>[];

    void offer(String key, String label, IconData mark, VoidCallback act) {
      acts
        ..add(SizedBox(width: theme.gap))
        ..add(
          MentoraButton(
            key: Key(key),
            label: label,
            onPressed: widget.enabled ? act : null,
            variant: MentoraButtonVariant.text,
            size: MentoraButtonSize.small,
            icon: mark,
          ),
        );
    }

    final clearLabel = widget.clearLabel;
    if (clearLabel != null && _text.text.isNotEmpty) {
      offer('search-clear', clearLabel, theme.clearMark, () {
        // Emptying is an intention like any other: it is reported.
        widget.onQueryChanged(MentoraSearchQuery.empty);
      });
    }
    final voice = widget.voice;
    if (voice != null) {
      offer('search-voice', voice.label, Icons.mic_none, voice.onInvoke);
    }
    final history = widget.history;
    if (history != null) {
      offer(
        'search-history',
        history.label,
        Icons.history,
        history.onInvoke,
      );
    }
    return acts;
  }

  Widget _aid(MentoraSearchBarTheme theme, MentoraSearchSuggestion aid) {
    final held = _heldAids.contains(aid.id);
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: aid.label,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('search-suggestion-${aid.id}'),
            borderRadius: BorderRadius.circular(searchSuggestionRadius),
            canRequestFocus: widget.enabled,
            onTap: widget.enabled && widget.onSuggestionChosen != null
                ? () => widget.onSuggestionChosen!(aid.id)
                : null,
            onHover: (value) => setState(() {
              value ? _heldAids.add(aid.id) : _heldAids.remove(aid.id);
            }),
            onFocusChange: (value) => setState(() {
              value ? _heldAids.add(aid.id) : _heldAids.remove(aid.id);
            }),
            child: AnimatedContainer(
              duration: theme.transitionDuration,
              curve: theme.curve,
              constraints: BoxConstraints(
                minHeight: theme.suggestionExtent,
              ),
              padding: theme.suggestionPadding,
              decoration: BoxDecoration(
                color: held ? theme.groundOfHeldSuggestion() : null,
                borderRadius: BorderRadius.circular(searchSuggestionRadius),
              ),
              child: Row(
                children: [
                  if (aid.icon != null) ...[
                    Icon(
                      aid.icon,
                      size: searchBarIconSize,
                      color: theme.suggestionMark,
                    ),
                    SizedBox(width: theme.gap),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MentoraText(
                          aid.label,
                          role: theme.suggestionRole,
                          maxLines: 1,
                        ),
                        if (aid.supporting != null)
                          MentoraText(
                            aid.supporting!,
                            role: theme.suggestionSupportingRole,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
