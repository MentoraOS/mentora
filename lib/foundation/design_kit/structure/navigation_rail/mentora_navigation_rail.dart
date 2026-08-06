import 'package:flutter/material.dart';

import '../../components/avatar/mentora_avatar.dart';
import '../../components/button/mentora_button.dart';
import '../../components/button/mentora_button_style.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/navigation_rail_tokens.dart';
import 'mentora_navigation_rail_style.dart';
import 'mentora_navigation_rail_theme.dart';

/// The official Mentora rail — the second Structural Component.
///
/// A rail is not a column. It expresses the principal navigation of
/// the product, where the person is inside it, and the stability of
/// that place. It accompanies: it never competes with the content,
/// and it never becomes a menu.
///
/// Four things it never does, and each is verified:
/// - it never decides where to go: it reports an intention, and the
///   application announces the place that was reached;
/// - it never knows an address: it knows destinations, and a
///   destination is an IDENTITY — never an icon, never a position;
/// - it never measures the surface it lives on: the application
///   decides how much it shows;
/// - it never carries business.
///
/// Flutter's own rails stay primitives: none is used.
final class MentoraNavigationRail extends StatefulWidget {
  /// The places of the product — identities, in the order the product
  /// presents them.
  final List<MentoraNavigationRailDestination> destinations;

  /// What the person meant. The structure reports; it never decides.
  final ValueChanged<String> onDestinationSelected;

  /// How much of itself the structure shows — decided by the
  /// application, never measured here.
  final MentoraNavigationRailDisplay display;

  final MentoraNavigationRailChrome chrome;

  /// The identity this structure belongs to — the Avatar remains its
  /// owner.
  final MentoraAvatar? leading;

  /// What can be done from the structure — the Button remains their
  /// owner.
  final List<MentoraButton> trailing;

  /// The act that changes how much the structure shows. The
  /// application performs it; the structure only offers it.
  final MentoraNavigationRailToggle? displayToggle;

  /// What the screen reader hears about the structure itself.
  final String? semanticLabel;

  final MentoraNavigationRailController? controller;

  const MentoraNavigationRail({
    super.key,
    required this.destinations,
    required this.onDestinationSelected,
    this.display = MentoraNavigationRailDisplay.compact,
    this.chrome = MentoraNavigationRailChrome.surface,
    this.leading,
    this.trailing = const [],
    this.displayToggle,
    this.semanticLabel,
    this.controller,
  });

  @override
  State<MentoraNavigationRail> createState() => _MentoraNavigationRailState();
}

final class _MentoraNavigationRailState extends State<MentoraNavigationRail> {
  final Set<String> _hovered = <String>{};
  final Set<String> _focused = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onAnnounced);
  }

  @override
  void didUpdateWidget(MentoraNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onAnnounced);
      widget.controller?.addListener(_onAnnounced);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onAnnounced);
    super.dispose();
  }

  void _onAnnounced() {
    if (mounted) setState(() {});
  }

  String? get _selectedId => widget.controller?.selectedId;

  bool get _live => widget.controller?.enabled ?? true;

  /// The contracts a structure must honor — verified once, at build.
  void _verify() {
    if (widget.destinations.isEmpty) {
      throw StateError(
        'A structure presents the places of the product: without one '
        'it presents nothing.',
      );
    }
    final identities = widget.destinations.map((place) => place.id).toSet();
    if (identities.length != widget.destinations.length) {
      throw StateError('Two places never share one identity.');
    }
    if (widget.destinations.any((place) => place.id.isEmpty)) {
      throw StateError('A place without an identity is not a place.');
    }
    if (widget.destinations.any((place) => place.label.isEmpty)) {
      throw StateError('A place without a name is never offered.');
    }
    final selected = _selectedId;
    if (selected != null && !identities.contains(selected)) {
      throw StateError(
        'The place announced is not one this structure presents: a '
        'structure never guesses where the person is.',
      );
    }
  }

  /// Exactly one effective state for one destination: availability,
  /// then where the person is, then the focus, then the pointer.
  MentoraNavigationRailState _stateOf(
    MentoraNavigationRailDestination place,
  ) {
    if (!_live || !place.enabled) {
      return MentoraNavigationRailState.disabled;
    }
    if (place.id == _selectedId) return MentoraNavigationRailState.selected;
    if (_focused.contains(place.id)) {
      return MentoraNavigationRailState.focused;
    }
    if (_hovered.contains(place.id)) {
      return MentoraNavigationRailState.hovered;
    }
    return MentoraNavigationRailState.idle;
  }

  MentoraNavigationRailState get _railState {
    if (!_live) return MentoraNavigationRailState.disabled;
    return widget.display == MentoraNavigationRailDisplay.expanded
        ? MentoraNavigationRailState.expanded
        : MentoraNavigationRailState.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraNavigationRailTheme.fromScope(
      DesignKitScope.of(context),
    );
    _verify();

    final railState = _railState;
    final visuals = theme.visualsOf(chrome: widget.chrome, state: railState);
    final floating = widget.chrome == MentoraNavigationRailChrome.floating;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Opacity(
        key: const Key('rail-presence'),
        opacity: visuals.opacity,
        child: AnimatedContainer(
          key: const Key('rail-surface'),
          duration: theme.transitionDuration,
          curve: theme.curve,
          width: theme.widthOf(widget.display),
          padding: theme.padding,
          decoration: BoxDecoration(
            color: visuals.surface,
            borderRadius: floating
                ? BorderRadius.circular(navigationRailFloatingRadius)
                : null,
            border: visuals.border == null
                ? null
                : Border.all(
                    color: visuals.border!,
                    width: navigationRailBorderWidth,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A structure standing against the content delimits the
              // edge it shares with it — a floating one never needs to.
              if (visuals.divider != null)
                Divider(
                  key: const Key('rail-divider'),
                  height: navigationRailDividerThickness,
                  thickness: navigationRailDividerThickness,
                  color: visuals.divider,
                ),
              if (widget.leading != null) ...[
                Align(child: widget.leading),
                SizedBox(height: theme.sectionGap),
              ],
              if (widget.displayToggle != null) ...[
                _toggle(theme),
                SizedBox(height: theme.gap),
              ],
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final place in widget.destinations)
                      _destination(theme, place),
                  ],
                ),
              ),
              if (widget.trailing.isNotEmpty) ...[
                SizedBox(height: theme.sectionGap),
                for (final act in widget.trailing) act,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(MentoraNavigationRailTheme theme) {
    final toggle = widget.displayToggle!;
    return MentoraButton(
      key: const Key('rail-display-toggle'),
      label: toggle.label,
      onPressed: _live ? toggle.onInvoke : null,
      variant: MentoraButtonVariant.text,
      size: MentoraButtonSize.small,
      icon: widget.display == MentoraNavigationRailDisplay.expanded
          ? Icons.chevron_left
          : Icons.chevron_right,
    );
  }

  Widget _destination(
    MentoraNavigationRailTheme theme,
    MentoraNavigationRailDestination place,
  ) {
    final state = _stateOf(place);
    final visuals = theme.destinationVisualsOf(state);
    final reachable =
        _live && place.enabled && place.id != _selectedId;
    final showsWords = specOf(widget.display).showsWords;

    return Semantics(
      button: true,
      selected: place.id == _selectedId,
      enabled: _live && place.enabled,
      label: place.label,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('rail-destination-${place.id}'),
            borderRadius: BorderRadius.circular(
              navigationRailIndicatorRadius,
            ),
            canRequestFocus: _live && place.enabled,
            // The structure reports the intention; it never decides.
            onTap: reachable
                ? () => widget.onDestinationSelected(place.id)
                : null,
            onHover: (value) => setState(() {
              value ? _hovered.add(place.id) : _hovered.remove(place.id);
            }),
            onFocusChange: (value) => setState(() {
              value ? _focused.add(place.id) : _focused.remove(place.id);
            }),
            child: AnimatedContainer(
              duration: theme.transitionDuration,
              curve: theme.curve,
              constraints: BoxConstraints(
                minHeight: theme.destinationExtent,
              ),
              decoration: BoxDecoration(
                color: visuals.indicator,
                borderRadius: BorderRadius.circular(
                  navigationRailIndicatorRadius,
                ),
              ),
              padding: theme.padding,
              child: Row(
                mainAxisAlignment: showsWords
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(
                    place.id == _selectedId ? place.selectedIcon : place.icon,
                    size: navigationRailIconSize,
                    color: visuals.mark,
                  ),
                  if (showsWords) ...[
                    SizedBox(width: theme.gap),
                    Expanded(
                      child: MentoraText(
                        place.label,
                        role: theme.wordsRole,
                        color: visuals.wordsRole,
                        maxLines: 1,
                      ),
                    ),
                  ],
                  if (place.badge != null) ...[
                    SizedBox(width: theme.gap),
                    place.badge!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
