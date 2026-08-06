import 'package:flutter/material.dart';

import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/bottom_navigation_tokens.dart';
import 'mentora_bottom_navigation_style.dart';
import 'mentora_bottom_navigation_theme.dart';

/// The official Mentora bottom navigation — the seventh Structural
/// Component, and the only bottom navigation of the product.
///
/// A bottom navigation is not a menu. It expresses the principal
/// destinations of the application: where the person is, where they
/// may go, and what constitutes the principal level of the product.
/// It expresses — it never decides.
///
/// Five things it never does, and each is verified:
/// - it never knows an address: it knows destinations, and a
///   destination is an IDENTITY — never a position, never an index;
/// - it never navigates: it reports the identity that was asked for,
///   and the application decides what happens;
/// - it never knows the surface it lives on, nor the platform: it
///   receives a configuration already decided;
/// - it never decides the selection: it is told where the person is;
/// - it never carries business.
///
/// Flutter's own bottom navigations stay primitives: none is used.
final class MentoraBottomNavigation extends StatefulWidget {
  /// The principal places of the product — identities, in the order
  /// the product presents them.
  final List<MentoraBottomNavigationDestination> destinations;

  /// Where the person is. The application announces it; the structure
  /// never guesses it and never decides it.
  final String? selectedDestinationId;

  /// What the person asked for. The structure reports the identity —
  /// nothing else, and never a consequence.
  final ValueChanged<String> onDestinationRequested;

  /// What the screen reader hears about the structure itself.
  final String? semanticLabel;

  const MentoraBottomNavigation({
    super.key,
    required this.destinations,
    required this.onDestinationRequested,
    this.selectedDestinationId,
    this.semanticLabel,
  });

  @override
  State<MentoraBottomNavigation> createState() =>
      _MentoraBottomNavigationState();
}

final class _MentoraBottomNavigationState
    extends State<MentoraBottomNavigation> {
  final Set<String> _hovered = <String>{};
  final Set<String> _focused = <String>{};

  /// The contracts a principal level must honor — verified once, at
  /// build, and refused when they are not met.
  void _verify() {
    final places = widget.destinations;
    if (places.length < bottomNavigationMinimumDestinations) {
      throw StateError(
        'A principal level expresses a choice: below '
        '$bottomNavigationMinimumDestinations destinations there is '
        'no choice to express.',
      );
    }
    if (places.length > bottomNavigationMaximumDestinations) {
      throw StateError(
        'A principal level stays principal: beyond '
        '$bottomNavigationMaximumDestinations destinations it is no '
        'longer a level, it is a menu.',
      );
    }
    final identities = places.map((place) => place.id).toSet();
    if (identities.length != places.length) {
      throw StateError('Two places never share one identity.');
    }
    if (places.any((place) => place.id.isEmpty)) {
      throw StateError('A place without an identity is not a place.');
    }
    if (places.any((place) => place.label.isEmpty)) {
      throw StateError('A place without a name is never offered.');
    }
    final selected = widget.selectedDestinationId;
    if (selected != null && !identities.contains(selected)) {
      throw StateError(
        'The place announced is not one this structure presents: a '
        'structure never guesses where the person is.',
      );
    }
  }

  /// Exactly one effective state for one destination: availability,
  /// then where the person is, then the focus, then the pointer.
  MentoraBottomNavigationState _stateOf(
    MentoraBottomNavigationDestination place,
  ) {
    if (!place.enabled) return MentoraBottomNavigationState.disabled;
    if (place.id == widget.selectedDestinationId) {
      return MentoraBottomNavigationState.selected;
    }
    if (_focused.contains(place.id)) {
      return MentoraBottomNavigationState.focused;
    }
    if (_hovered.contains(place.id)) {
      return MentoraBottomNavigationState.hovered;
    }
    return MentoraBottomNavigationState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraBottomNavigationTheme.fromScope(
      DesignKitScope.of(context),
    );
    _verify();

    final visuals = theme.visuals;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: AnimatedContainer(
        key: const Key('bottom-navigation-surface'),
        duration: theme.transitionDuration,
        curve: theme.curve,
        decoration: BoxDecoration(color: visuals.surface),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The principal level stands against the content: it
                // delimits the edge it shares with it.
                Divider(
                  key: const Key('bottom-navigation-divider'),
                  height: bottomNavigationTokens.dividerThickness,
                  thickness: bottomNavigationTokens.dividerThickness,
                  color: visuals.divider,
                ),
                // The band is asked for as a minimum: when the words
                // grow, the structure grows with them.
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: theme.extent),
                  child: Row(
                    children: [
                      // Every place is given the same room: none of
                      // them is more principal than the others.
                      for (final place in widget.destinations)
                        Expanded(child: _destination(theme, place)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _destination(
    MentoraBottomNavigationTheme theme,
    MentoraBottomNavigationDestination place,
  ) {
    final state = _stateOf(place);
    final visuals = theme.destinationVisualsOf(state);
    final selected = place.id == widget.selectedDestinationId;
    // Where the person already is is not a place to ask for.
    final reachable = place.enabled && !selected;

    return Semantics(
      button: true,
      selected: selected,
      enabled: place.enabled,
      label: place.label,
      child: ExcludeSemantics(
        child: InkWell(
          key: Key('bottom-navigation-destination-${place.id}'),
          canRequestFocus: place.enabled,
          // The structure reports the intention; it never decides.
          onTap: reachable
              ? () => widget.onDestinationRequested(place.id)
              : null,
          onHover: (value) => setState(() {
            value ? _hovered.add(place.id) : _hovered.remove(place.id);
          }),
          onFocusChange: (value) => setState(() {
            value ? _focused.add(place.id) : _focused.remove(place.id);
          }),
          child: Opacity(
            key: Key('bottom-navigation-presence-${place.id}'),
            opacity: visuals.opacity,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: theme.destinationExtent),
              child: Padding(
                padding: theme.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _mark(theme, place, visuals),
                    SizedBox(height: bottomNavigationTokens.iconLabelGap),
                    MentoraText(
                      place.label,
                      role: theme.wordsRole,
                      color: visuals.wordsRole,
                      maxLines: 1,
                      align: TextAlign.center,
                      // The place is already announced by the control
                      // it belongs to: never twice.
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The mark of the place, and what is happening there.
  ///
  /// The discreet active capsule carries the highlight role — never a
  /// filled shout; the Badge stays the owner of what it announces, and
  /// stands at the corner the reading direction puts it in.
  Widget _mark(
    MentoraBottomNavigationTheme theme,
    MentoraBottomNavigationDestination place,
    MentoraBottomNavigationDestinationVisuals visuals,
  ) {
    final capsule = AnimatedContainer(
      key: Key('bottom-navigation-capsule-${place.id}'),
      duration: theme.transitionDuration,
      curve: theme.curve,
      padding: EdgeInsets.symmetric(
        horizontal: bottomNavigationTokens.capsuleHorizontalPadding,
        vertical: bottomNavigationTokens.capsuleVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: visuals.indicator,
        borderRadius: BorderRadius.circular(
          bottomNavigationTokens.capsuleRadius,
        ),
      ),
      child: Icon(
        place.id == widget.selectedDestinationId
            ? place.selectedIcon
            : place.icon,
        size: bottomNavigationTokens.iconSize,
        color: visuals.mark,
      ),
    );

    if (place.badge == null) return capsule;
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topEnd,
      children: [capsule, place.badge!],
    );
  }
}
