import 'package:flutter/material.dart';

import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/tabs_tokens.dart';
import 'mentora_tabs_style.dart';
import 'mentora_tabs_theme.dart';

/// The official Mentora tabs — the third Structural Component.
///
/// A tab is not a button. It is a FACET of one context: changing tab
/// never means leaving a space, it reveals another side of the same
/// domain. Tabs organize — they never navigate between modules, and
/// that is why they carry no identity and no way out.
///
/// Four things they never do, and each is verified:
/// - a facet is an IDENTITY: selection travels by identity, and no
///   position exists anywhere in this API;
/// - they know no address, and no page: only which facets exist;
/// - they never decide what is shown: they report an intention, and
///   the application announces the facet it revealed;
/// - they never measure the surface: the application declares what
///   happens when the facets no longer fit.
///
/// Flutter's own tab widgets stay primitives: none is used.
final class MentoraTabs extends StatefulWidget {
  /// The facets of the context — at least two: a single facet reveals
  /// nothing.
  final List<MentoraTab> tabs;

  /// What the person meant. The set reports; it never decides.
  final ValueChanged<String> onTabSelected;

  final MentoraTabsController controller;
  final MentoraTabsEmphasis emphasis;
  final MentoraTabsShape shape;

  /// What happens when the facets no longer fit — declared by the
  /// application, never measured here.
  final MentoraTabsOverflow overflow;

  /// What the screen reader hears about the set itself.
  final String? semanticLabel;

  /// Whether the whole set can be used right now.
  final bool enabled;

  const MentoraTabs({
    super.key,
    required this.tabs,
    required this.controller,
    required this.onTabSelected,
    this.emphasis = MentoraTabsEmphasis.primary,
    this.shape = MentoraTabsShape.underline,
    this.overflow = MentoraTabsOverflow.scroll,
    this.semanticLabel,
    this.enabled = true,
  });

  @override
  State<MentoraTabs> createState() => _MentoraTabsState();
}

final class _MentoraTabsState extends State<MentoraTabs> {
  final Set<String> _hovered = <String>{};
  final Set<String> _focused = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAnnounced);
  }

  @override
  void didUpdateWidget(MentoraTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onAnnounced);
      widget.controller.addListener(_onAnnounced);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAnnounced);
    super.dispose();
  }

  void _onAnnounced() {
    if (mounted) setState(() {});
  }

  String get _selectedId => widget.controller.selectedId;

  /// The contracts a set must honor — verified once, at build.
  void _verify() {
    if (widget.tabs.length < 2) {
      throw StateError(
        'A set of facets reveals another side of the same context: a '
        'single facet reveals nothing.',
      );
    }
    final identities = widget.tabs.map((facet) => facet.id).toSet();
    if (identities.length != widget.tabs.length) {
      throw StateError('Two facets never share one identity.');
    }
    if (widget.tabs.any((facet) => facet.id.isEmpty)) {
      throw StateError('A facet without an identity is not a facet.');
    }
    if (widget.tabs.any((facet) => facet.label.isEmpty)) {
      throw StateError('A facet without a name is never offered.');
    }
    if (!identities.contains(_selectedId)) {
      throw StateError(
        'The facet announced is not one this set presents: a set never '
        'guesses what is shown.',
      );
    }
  }

  /// Exactly one effective state for one facet: availability, then
  /// preparation, then what is shown, then the focus, then the pointer.
  MentoraTabsState _stateOf(MentoraTab facet) {
    if (!widget.enabled || !facet.enabled) return MentoraTabsState.disabled;
    if (facet.loading) return MentoraTabsState.loading;
    if (facet.id == _selectedId) return MentoraTabsState.selected;
    if (_focused.contains(facet.id)) return MentoraTabsState.focused;
    if (_hovered.contains(facet.id)) return MentoraTabsState.hovered;
    return MentoraTabsState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraTabsTheme.fromScope(DesignKitScope.of(context));
    _verify();

    final visuals = theme.visualsOf(
      shape: widget.shape,
      live: widget.enabled,
    );
    final facets = [
      for (final facet in widget.tabs) _facet(theme, facet),
    ];

    // The facets share the room they are given, or keep their own and
    // let the set scroll — the application declared which.
    final Widget strip = widget.overflow == MentoraTabsOverflow.fit
        ? Row(
            children: [
              for (final facet in facets) Expanded(child: facet),
            ],
          )
        : SingleChildScrollView(
            key: const Key('tabs-scroll'),
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: facets),
          );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Opacity(
        key: const Key('tabs-presence'),
        opacity: visuals.opacity,
        child: AnimatedContainer(
          key: const Key('tabs-surface'),
          duration: theme.transitionDuration,
          curve: theme.curve,
          padding: widget.shape == MentoraTabsShape.segmented
              ? theme.enclosurePadding
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: visuals.enclosure,
            borderRadius: widget.shape == MentoraTabsShape.segmented
                ? BorderRadius.circular(theme.radiusOf(widget.shape))
                : null,
            border: visuals.border == null
                ? null
                : Border.all(
                    color: visuals.border!,
                    width: tabsBorderWidth,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Arrow keys travel between facets through the framework's
              // own directional traversal: geometric, so a right arrow
              // is the reading direction, in every language.
              FocusTraversalGroup(child: strip),
              if (visuals.baseline != null)
                Divider(
                  key: const Key('tabs-baseline'),
                  height: tabIndicatorThickness,
                  thickness: tabIndicatorThickness,
                  color: visuals.baseline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _facet(MentoraTabsTheme theme, MentoraTab facet) {
    final state = _stateOf(facet);
    final visuals = theme.facetVisualsOf(
      emphasis: widget.emphasis,
      shape: widget.shape,
      state: state,
    );
    final reachable =
        widget.enabled && facet.reachable && facet.id != _selectedId;
    final radius = BorderRadius.circular(theme.radiusOf(widget.shape));

    return Semantics(
      button: true,
      selected: facet.id == _selectedId,
      enabled: widget.enabled && facet.reachable,
      label: facet.label,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('tab-${facet.id}'),
            borderRadius: radius,
            canRequestFocus: widget.enabled && facet.reachable,
            // The set reports the intention; it never decides.
            onTap: reachable ? () => widget.onTabSelected(facet.id) : null,
            onHover: (value) => setState(() {
              value ? _hovered.add(facet.id) : _hovered.remove(facet.id);
            }),
            onFocusChange: (value) => setState(() {
              value ? _focused.add(facet.id) : _focused.remove(facet.id);
            }),
            child: AnimatedContainer(
              duration: theme.transitionDuration,
              curve: theme.curve,
              constraints: BoxConstraints(
                minHeight: theme.facetExtent,
                minWidth: tabMinimumWidth,
              ),
              padding: theme.facetPadding,
              decoration: BoxDecoration(
                color: visuals.ground,
                borderRadius: radius,
                border: visuals.indicator == null
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: visuals.indicator!,
                          width: tabIndicatorThickness,
                        ),
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _content(theme, facet, state, visuals),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    MentoraTabsTheme theme,
    MentoraTab facet,
    MentoraTabsState state,
    MentoraTabVisuals visuals,
  ) {
    final content = <Widget>[];

    if (state == MentoraTabsState.loading) {
      // A facet still being prepared shows exactly one sober signal.
      content.add(
        SizedBox(
          width: tabProgressExtent,
          height: tabProgressExtent,
          child: CircularProgressIndicator(
            strokeWidth: tabProgressStroke,
            color: visuals.mark,
          ),
        ),
      );
    } else if (facet.icon != null) {
      content.add(
        Icon(facet.icon, size: tabIconSize, color: visuals.mark),
      );
    }

    if (content.isNotEmpty) content.add(SizedBox(width: theme.gap));
    content.add(
      Flexible(
        child: MentoraText(
          facet.label,
          role: theme.wordsRole,
          color: visuals.wordsRole,
          maxLines: 1,
        ),
      ),
    );

    if (facet.badge != null && state != MentoraTabsState.loading) {
      content
        ..add(SizedBox(width: theme.gap))
        ..add(facet.badge!);
    }
    return content;
  }
}
