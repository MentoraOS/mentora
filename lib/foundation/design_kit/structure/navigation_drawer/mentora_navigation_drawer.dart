import 'package:flutter/material.dart';
import '../../navigation/mentora_destination.dart';

import '../../components/button/mentora_button.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../composition/list_tile/mentora_list_tile.dart';
import '../../tokens/drawer_tokens.dart';
import 'mentora_navigation_drawer_style.dart';
import 'mentora_navigation_drawer_theme.dart';

/// The official Mentora orientation map — the fifth Structural
/// Component.
///
/// A drawer is not a menu. It is a MAP: it says where the person is,
/// where they may go, and what belongs to their space — and it never
/// decides for them.
///
/// Five things it never does, and each is verified:
/// - it never leads anywhere: it reports an identity, and the
///   application decides;
/// - a destination is an IDENTITY, never a position;
/// - it never knows the platform: the Responsive Engine decides;
/// - it never chooses how it is presented: the application announces
///   permanent, modal or dismissible;
/// - it never opens and never closes itself: it is told, and asking
///   to be put away is only ever reported.
///
/// It composes and never redefines: the person's space is a
/// [MentoraListTile], the acts are [MentoraButton]s, every word is a
/// [MentoraText], and what happens in a place is a badge the
/// destination carries.
final class MentoraNavigationDrawer extends StatefulWidget {
  /// The places of the person's space, in the order the product
  /// presents them.
  final List<MentoraDrawerSection> sections;

  /// What the person meant. The map reports; it never decides.
  final ValueChanged<String> onDestinationSelected;

  /// That the person asked to put the map away — reported, never
  /// performed. A permanent map never asks.
  final VoidCallback? onDismissRequested;

  final MentoraNavigationDrawerController controller;

  /// How the map is presented — announced by the application.
  final MentoraDrawerPresentation presentation;

  /// Whose space this is — the Tile presents the entity, and the
  /// Avatar inside it remains the owner of the identity.
  final MentoraListTile? space;

  /// What can be done from the map — the Button remains their owner.
  final List<MentoraButton> actions;

  /// What the screen reader hears about the map itself.
  final String semanticLabel;

  const MentoraNavigationDrawer({
    super.key,
    required this.sections,
    required this.controller,
    required this.onDestinationSelected,
    required this.semanticLabel,
    this.presentation = MentoraDrawerPresentation.permanent,
    this.onDismissRequested,
    this.space,
    this.actions = const [],
  });

  @override
  State<MentoraNavigationDrawer> createState() =>
      _MentoraNavigationDrawerState();
}

final class _MentoraNavigationDrawerState
    extends State<MentoraNavigationDrawer> {
  final Set<String> _hovered = <String>{};
  final Set<String> _focused = <String>{};

  /// Where the focus was before the map covered the scene — a map
  /// never steals the focus, and always gives it back.
  FocusNode? _restoreTo;
  bool _wasOpened = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAnnounced);
    _wasOpened = widget.controller.isOpened;
  }

  @override
  void didUpdateWidget(MentoraNavigationDrawer oldWidget) {
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
    if (!mounted) return;
    final opened = widget.controller.isOpened;
    if (opened != _wasOpened) {
      if (opened) {
        // Remembered, never taken: the map does not move the focus.
        _restoreTo = FocusManager.instance.primaryFocus;
      } else {
        final restore = _restoreTo;
        _restoreTo = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          restore?.requestFocus();
        });
      }
      _wasOpened = opened;
    }
    setState(() {});
  }

  bool get _opened => widget.controller.isOpened;

  /// The contracts a map must honor — verified once, at build.
  void _verify() {
    if (widget.semanticLabel.isEmpty) {
      throw StateError(
        'A map says what it orients within: without a name it orients '
        'nothing.',
      );
    }
    final places = [
      for (final section in widget.sections) ...section.destinations,
    ];
    if (places.isEmpty) {
      throw StateError(
        'A map shows the places of a space: without one it shows '
        'nothing.',
      );
    }
    final identities = places.map((place) => place.id).toSet();
    if (identities.length != places.length) {
      throw StateError('Two places never share one identity.');
    }
    if (places.any((place) => place.id.isEmpty || place.label.isEmpty)) {
      throw StateError('A place without an identity or a name is not one.');
    }
    final selected = widget.controller.selectedId;
    if (selected != null && !identities.contains(selected)) {
      throw StateError(
        'The place announced is not one this map shows: a map never '
        'guesses where the person is.',
      );
    }
    if (widget.onDismissRequested != null &&
        !acceptsDismissal(widget.presentation)) {
      throw StateError(
        'A permanent map belongs to the chrome: it is never put away.',
      );
    }
  }

  MentoraDrawerState _stateOf(MentoraDestination place) {
    if (!place.enabled) return MentoraDrawerState.disabled;
    if (place.id == widget.controller.selectedId) {
      return MentoraDrawerState.selected;
    }
    if (_focused.contains(place.id)) return MentoraDrawerState.focused;
    if (_hovered.contains(place.id)) return MentoraDrawerState.hovered;
    return MentoraDrawerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraNavigationDrawerTheme.fromScope(
      DesignKitScope.of(context),
    );
    _verify();

    final visuals = theme.visualsOf(widget.presentation);
    final spec = specOf(widget.presentation);
    final panel = _panel(theme, visuals, spec);

    if (standsBeside(widget.presentation)) {
      // A map that stands beside the content gives its room back when
      // it is told to, and takes nothing else.
      return AnimatedContainer(
        key: const Key('drawer-surface'),
        duration: theme.transitionDuration,
        curve: theme.curve,
        width: _opened ? spec.width : 0,
        child: ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            maxWidth: spec.width,
            minWidth: spec.width,
            child: panel,
          ),
        ),
      );
    }

    // A map that comes and goes passes in front of the scene it is
    // placed over — the application places it, as it decides.
    return Stack(
      children: [
        if (spec.dimsScene)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_opened,
              child: AnimatedOpacity(
                key: const Key('drawer-scrim'),
                duration: theme.transitionDuration,
                curve: theme.curve,
                opacity: _opened ? drawerFullOpacity : drawerClosedOpacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Asking to be put away is reported, never performed.
                  onTap: widget.onDismissRequested,
                  child: ColoredBox(color: visuals.scrim),
                ),
              ),
            ),
          ),
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !_opened,
            child: AnimatedSlide(
              key: const Key('drawer-surface'),
              duration: theme.transitionDuration,
              curve: theme.curve,
              offset: Offset(
                _opened ? drawerOpenedOffset : drawerClosedOffset,
                0,
              ),
              child: SizedBox(width: spec.width, child: panel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(
    MentoraNavigationDrawerTheme theme,
    MentoraDrawerVisuals visuals,
    DrawerPresentationSpec spec,
  ) {
    final radius = Radius.circular(spec.radius);

    return Semantics(
      container: true,
      // The map says what it is, and whether it is shown — it never
      // announces itself by taking anything.
      label: widget.semanticLabel,
      expanded: _opened,
      scopesRoute: widget.presentation == MentoraDrawerPresentation.modal,
      explicitChildNodes: true,
      child: ExcludeSemantics(
        excluding: !_opened,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: visuals.surface,
            // A rounded edge and a delimiting line never coexist: a
            // map either rounds itself, or draws the edge it shares.
            borderRadius: visuals.border == null
                ? BorderRadiusDirectional.only(
                    topEnd: radius,
                    bottomEnd: radius,
                  )
                : null,
            border: visuals.border == null
                ? null
                : BorderDirectional(
                    end: BorderSide(
                      color: visuals.border!,
                      width: drawerBorderWidth,
                    ),
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: theme.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.space != null) ...[
                    widget.space!,
                    Divider(
                      height: drawerDividerThickness,
                      thickness: drawerDividerThickness,
                      color: visuals.divider,
                    ),
                    SizedBox(height: theme.gap),
                  ],
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final section in widget.sections)
                          ..._section(theme, section),
                      ],
                    ),
                  ),
                  if (widget.actions.isNotEmpty) ...[
                    SizedBox(height: theme.sectionGap),
                    for (final act in widget.actions) act,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(
    MentoraNavigationDrawerTheme theme,
    MentoraDrawerSection section,
  ) {
    return [
      if (section.title != null) ...[
        SizedBox(height: theme.sectionGap),
        Padding(
          padding: theme.destinationPadding,
          child: MentoraText(
            section.title!,
            role: theme.sectionRole,
            maxLines: 1,
          ),
        ),
        SizedBox(height: theme.gap),
      ],
      for (final place in section.destinations) _destination(theme, place),
    ];
  }

  Widget _destination(
    MentoraNavigationDrawerTheme theme,
    MentoraDestination place,
  ) {
    final state = _stateOf(place);
    final visuals = theme.destinationVisualsOf(state);
    final selected = place.id == widget.controller.selectedId;
    final reachable = place.enabled && !selected;

    return Semantics(
      button: true,
      selected: selected,
      enabled: place.enabled,
      label: place.label,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('drawer-destination-${place.id}'),
            borderRadius: BorderRadius.circular(drawerDestinationRadius),
            canRequestFocus: place.enabled,
            // The map reports the intention; it never leads anywhere.
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
              constraints: BoxConstraints(minHeight: theme.destinationExtent),
              padding: theme.destinationPadding,
              decoration: BoxDecoration(
                color: visuals.ground,
                borderRadius: BorderRadius.circular(drawerDestinationRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? place.selectedIcon : place.icon,
                    size: drawerIconSize,
                    color: visuals.mark,
                  ),
                  SizedBox(width: theme.gap),
                  Expanded(
                    child: MentoraText(
                      place.label,
                      role: theme.destinationRole,
                      color: visuals.wordsRole,
                      maxLines: 1,
                    ),
                  ),
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
