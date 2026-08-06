import 'package:flutter/material.dart';

import '../../components/design_kit_scope.dart';
import 'mentora_split_view_style.dart';
import 'mentora_split_view_theme.dart';

/// The official Mentora shared workspace — the ninth Structural
/// Component, and the only way a space is shared between regions.
///
/// A split view is not a responsive layout. It is a spatial RELATION:
/// several regions share one room, separations say where one region
/// ends and the next begins, and the workspace decides none of it.
///
/// Seven things it never does, and each is verified:
/// - it never knows the screen: no measure, no orientation, no
///   breakpoint, no proportion exists here;
/// - it never knows a position: a region is an IDENTITY, and every
///   API of this component travels by identity;
/// - it never decides the room: it is given a specification, already
///   computed, and it expresses it;
/// - a separation is never a border and never a decoration: it says
///   that two regions exist, and nothing else;
/// - moving a separation is an intention, never a decision: it is
///   reported, and the application decides;
/// - a region that is hidden does not exist: it is not built, it takes
///   no focus, it says nothing and it receives nothing;
/// - it never knows the business.
final class MentoraSplitView extends StatefulWidget {
  /// The regions sharing the workspace — identities, in the order the
  /// application presents them.
  final List<MentoraSplitRegion> regions;

  /// The room each region takes, already decided by the application.
  final MentoraSplitLayoutSpecification layout;

  /// What a person asked of a separation. The workspace reports the
  /// intention; the application decides. Given none, the separations
  /// are fixed: they say that two regions exist, and offer nothing.
  final ValueChanged<MentoraSplitResizeIntention>? onResizeRequested;

  const MentoraSplitView({
    super.key,
    required this.regions,
    required this.layout,
    this.onResizeRequested,
  });

  @override
  State<MentoraSplitView> createState() => _MentoraSplitViewState();
}

final class _MentoraSplitViewState extends State<MentoraSplitView> {
  /// Which separation the pointer is over, and which one is being
  /// moved — by identity, never by rank.
  String? _hoveredRegionId;
  String? _movedRegionId;

  bool get _movable => widget.onResizeRequested != null;

  /// The regions that exist right now, in the order they were given.
  List<MentoraSplitRegion> get _shown {
    final shown = <MentoraSplitRegion>[];
    for (final region in widget.regions) {
      if (region.isShown) shown.add(region);
    }
    return shown;
  }

  /// The contracts a workspace must honor — verified once, at build,
  /// and refused when they are not met.
  void _verify(List<MentoraSplitRegion> shown) {
    final regions = widget.regions;
    if (regions.length < 2) {
      throw StateError(
        'A shared workspace needs regions to share it: below two, '
        'nothing is shared.',
      );
    }
    final identities = <String>{};
    for (final region in regions) {
      if (region.id.isEmpty) {
        throw StateError('A region without an identity is not a region.');
      }
      if (region.semanticLabel.isEmpty) {
        throw StateError(
          'A region without a name is not a landmark: a person always '
          'knows which region they are in.',
        );
      }
      if (!identities.add(region.id)) {
        throw StateError('Two regions never share one identity.');
      }
    }
    if (shown.isEmpty) {
      throw StateError(
        'A workspace where no region exists is not a workspace.',
      );
    }

    final layout = widget.layout;
    layout.verify();
    for (final entry in layout.extents.entries) {
      if (!identities.contains(entry.key)) {
        throw StateError(
          'A room was announced for "${entry.key}", which is not a '
          'region of this workspace.',
        );
      }
    }

    var fills = false;
    for (final region in shown) {
      if (region.id == layout.fillsRemainingRegionId) {
        fills = true;
        continue;
      }
      if (layout.extentOf(region.id) == null) {
        throw StateError(
          'The region "${region.id}" exists and takes no announced '
          'room: a workspace never decides a room for itself.',
        );
      }
      if (_movable && region.resizeSemanticLabel == null) {
        throw StateError(
          'A separation one can move is a control: without a name for '
          'the region "${region.id}" it is never offered.',
        );
      }
    }
    if (!fills) {
      throw StateError(
        'The region that takes what is left is not one this workspace '
        'shows: a workspace never guesses where the room goes.',
      );
    }
  }

  MentoraSplitSeparatorState _separatorStateOf(String regionId) {
    if (!_movable) return MentoraSplitSeparatorState.fixed;
    if (_movedRegionId == regionId) return MentoraSplitSeparatorState.dragged;
    if (_hoveredRegionId == regionId) {
      return MentoraSplitSeparatorState.hovered;
    }
    return MentoraSplitSeparatorState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraSplitViewTheme.fromScope(DesignKitScope.of(context));
    final shown = _shown;
    _verify(shown);

    final layout = widget.layout;
    final thickness = theme.separatorThickness;
    final spaces = <Widget>[];
    final separations = <Widget>[];

    // The regions announced before the one that takes what is left are
    // placed from the start of the room, one after the other.
    var fromStart = 0.0;
    for (final region in shown) {
      if (region.id == layout.fillsRemainingRegionId) break;
      final extent = layout.extentOf(region.id)!;
      spaces.add(
        _place(
          fromStart: fromStart,
          extent: extent,
          child: _region(theme, region),
        ),
      );
      fromStart += extent;
      separations.add(
        _separation(theme, region: region, at: fromStart, fromTheStart: true),
      );
      fromStart += thickness;
    }

    // The ones announced after it are placed from the end of the room,
    // walking back — so the room is never totalled, and never measured.
    var fromEnd = 0.0;
    for (final region in shown.reversed) {
      if (region.id == layout.fillsRemainingRegionId) break;
      final extent = layout.extentOf(region.id)!;
      spaces.add(
        _place(fromEnd: fromEnd, extent: extent, child: _region(theme, region)),
      );
      fromEnd += extent;
      separations.add(
        _separation(theme, region: region, at: fromEnd, fromTheStart: false),
      );
      fromEnd += thickness;
    }

    // What is left is exactly what is left: never a share of anything.
    for (final region in shown) {
      if (region.id != layout.fillsRemainingRegionId) continue;
      spaces.add(
        _place(
          fromStart: fromStart,
          fromEnd: fromEnd,
          child: _region(theme, region),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        key: const Key('split-view'),
        children: [
          ...spaces,
          // The separations stand above the regions: what a person
          // takes hold of is never covered by what it separates.
          ...separations,
        ],
      ),
    );
  }

  /// Where one thing stands along the shared axis.
  ///
  /// A start, an end, an announced extent — and nothing else. The
  /// reading direction places it; the workspace never mirrors by hand.
  Widget _place({
    double? fromStart,
    double? fromEnd,
    double? extent,
    required Widget child,
  }) {
    if (widget.layout.axis == MentoraSplitAxis.vertical) {
      // A shared height has no start and no end: it spans the room
      // whatever the reading direction is.
      return Positioned(
        left: 0,
        right: 0,
        top: fromStart,
        bottom: fromEnd,
        height: extent,
        child: child,
      );
    }
    return PositionedDirectional(
      top: 0,
      bottom: 0,
      start: fromStart,
      end: fromEnd,
      width: extent,
      child: child,
    );
  }

  /// One region of the workspace: a named landmark, its own focus
  /// group, and the ground the regions share.
  Widget _region(MentoraSplitViewTheme theme, MentoraSplitRegion region) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: region.semanticLabel,
      // Each region travels as its own focus group: moving through a
      // workspace follows its regions, and never wanders between them.
      child: FocusTraversalGroup(
        child: AnimatedContainer(
          key: Key('split-view-region-${region.id}'),
          duration: theme.transitionDuration,
          curve: theme.curve,
          decoration: BoxDecoration(color: theme.regionSurface),
          child: region.content,
        ),
      ),
    );
  }

  /// The separation that follows one region.
  ///
  /// It says that two regions exist. When a person may move it, it
  /// offers the room to take hold of it — never a decoration.
  Widget _separation(
    MentoraSplitViewTheme theme, {
    required MentoraSplitRegion region,
    required double at,
    required bool fromTheStart,
  }) {
    final state = _separatorStateOf(region.id);
    final visuals = theme.separatorVisualsOf(state);
    final vertical = widget.layout.axis == MentoraSplitAxis.vertical;
    final line = AnimatedContainer(
      key: Key('split-view-separator-${region.id}'),
      duration: theme.transitionDuration,
      curve: theme.curve,
      width: vertical ? null : theme.separatorThickness,
      height: vertical ? theme.separatorThickness : null,
      decoration: BoxDecoration(color: visuals.line),
    );

    if (!_movable) {
      return _place(
        fromStart: fromTheStart ? at : null,
        fromEnd: fromTheStart ? null : at,
        extent: theme.separatorThickness,
        child: line,
      );
    }

    // The room to take hold of surrounds the line, and is never
    // painted: it stays centred on what it lets a person move.
    final grab = theme.separatorGrabExtent;
    final margin = (grab - theme.separatorThickness) / 2;
    return _place(
      fromStart: fromTheStart ? at - margin : null,
      fromEnd: fromTheStart ? null : at - margin,
      extent: grab,
      child: Semantics(
        slider: true,
        label: region.resizeSemanticLabel,
        // A separation is reachable without a pointer: each step asks
        // for exactly one step of room.
        onIncrease: () => _report(region, theme.resizeStep, fromTheStart),
        onDecrease: () => _report(region, -theme.resizeStep, fromTheStart),
        child: MouseRegion(
          cursor: vertical
              ? SystemMouseCursors.resizeRow
              : SystemMouseCursors.resizeColumn,
          onEnter: (_) => setState(() => _hoveredRegionId = region.id),
          onExit: (_) => setState(() => _hoveredRegionId = null),
          child: GestureDetector(
            key: Key('split-view-grab-${region.id}'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: vertical
                ? null
                : (_) => setState(() => _movedRegionId = region.id),
            onHorizontalDragUpdate: vertical
                ? null
                : (details) =>
                      _reportRaw(region, details.delta.dx, fromTheStart),
            onHorizontalDragEnd: vertical
                ? null
                : (_) => setState(() => _movedRegionId = null),
            onVerticalDragStart: vertical
                ? (_) => setState(() => _movedRegionId = region.id)
                : null,
            onVerticalDragUpdate: vertical
                ? (details) =>
                      _reportRaw(region, details.delta.dy, fromTheStart)
                : null,
            onVerticalDragEnd: vertical
                ? (_) => setState(() => _movedRegionId = null)
                : null,
            child: Center(child: line),
          ),
        ),
      ),
    );
  }

  /// A movement of the pointer, read in the reading direction, becomes
  /// the room the person asked for.
  void _reportRaw(MentoraSplitRegion region, double raw, bool fromTheStart) {
    final mirrored =
        widget.layout.axis == MentoraSplitAxis.horizontal &&
            Directionality.of(context) == TextDirection.rtl
        ? -raw
        : raw;
    _report(region, mirrored, fromTheStart);
  }

  /// The workspace reports the identity and the room asked for — never
  /// a new size, and never a decision.
  void _report(
    MentoraSplitRegion region,
    double towardTheEnd,
    bool fromTheStart,
  ) {
    // A region placed before its separation grows when the separation
    // moves away from the start; one placed after it grows when the
    // separation moves toward the start.
    final delta = fromTheStart ? towardTheEnd : -towardTheEnd;
    widget.onResizeRequested?.call(
      MentoraSplitResizeIntention(regionId: region.id, delta: delta),
    );
  }
}
