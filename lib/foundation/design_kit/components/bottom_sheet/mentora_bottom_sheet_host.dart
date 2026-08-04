import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import '../design_kit_scope.dart';
import 'mentora_bottom_sheet.dart';
import 'mentora_bottom_sheet_request.dart';
import 'mentora_bottom_sheet_service.dart';
import 'mentora_bottom_sheet_style.dart';
import 'mentora_bottom_sheet_theme.dart';

/// Where the sheet layer lives. Installed once, always mounted: no
/// route is pushed, no Navigator is involved, no
/// showModalBottomSheet is ever called — the accompaniment is a layer
/// of the application, not a page of its history.
///
/// It holds the guarantees a layer owes: the focus is trapped while
/// the sheet lasts and restored where it was, the scene below is
/// silenced for screen readers, Escape steps back, and the gesture
/// settles on a detent — or lets the sheet go.
final class MentoraBottomSheetHost extends StatefulWidget {
  final MentoraBottomSheetService service;
  final MentoraBottomSheetController? controller;
  final Widget child;

  const MentoraBottomSheetHost({
    super.key,
    required this.service,
    required this.child,
    this.controller,
  });

  @override
  State<MentoraBottomSheetHost> createState() => _MentoraBottomSheetHostState();
}

final class _MentoraBottomSheetHostState extends State<MentoraBottomSheetHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: Duration.zero,
  );
  final FocusScopeNode _layerFocus = FocusScopeNode(
    debugLabel: 'mentora-bottom-sheet',
  );

  MentoraBottomSheetTheme? _theme;
  MentoraBottomSheetRequest? _shown;
  FocusNode? _restoreTo;

  /// The fraction held by the finger — null when nothing is held.
  double? _dragFraction;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onDemandChanged);
    widget.controller?.addListener(_onPhaseChanged);
    _animation.addStatusListener(_onStatusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = MentoraBottomSheetTheme.fromScope(DesignKitScope.of(context));
  }

  @override
  void didUpdateWidget(MentoraBottomSheetHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service.removeListener(_onDemandChanged);
      widget.service.addListener(_onDemandChanged);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onPhaseChanged);
      widget.controller?.addListener(_onPhaseChanged);
    }
  }

  @override
  void dispose() {
    widget.service.removeListener(_onDemandChanged);
    widget.controller?.removeListener(_onPhaseChanged);
    _animation.dispose();
    _layerFocus.dispose();
    super.dispose();
  }

  void _onPhaseChanged() {
    if (mounted) setState(() {});
  }

  void _onStatusChanged(AnimationStatus status) {
    if (mounted) setState(() {});
  }

  void _onDemandChanged() {
    if (!mounted) return;
    final demand = widget.service.current;
    if (identical(demand, _shown)) {
      // The detent moved, not the demand.
      setState(() {});
      return;
    }

    if (demand != null) {
      if (_shown == null) _restoreTo = FocusManager.instance.primaryFocus;
      setState(() {
        _shown = demand;
        _dragFraction = null;
      });
      // Every duration comes from the Motion Engine: a None preference
      // makes the arrival instantaneous, never absent.
      _animation.duration = _theme!.transitionDuration;
      _animation.forward(from: 0);
      return;
    }

    _animation.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _shown = null;
        _dragFraction = null;
      });
      final restore = _restoreTo;
      _restoreTo = null;
      // The focus comes home only once the scene is reachable again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restore?.requestFocus();
      });
    });
  }

  /// Exactly one effective state: the layer's life, then the finger,
  /// then the announced work, then where the sheet rests.
  MentoraBottomSheetState get _effectiveState {
    if (_shown == null) return MentoraBottomSheetState.closed;
    switch (_animation.status) {
      case AnimationStatus.forward:
        return MentoraBottomSheetState.opening;
      case AnimationStatus.reverse:
        return MentoraBottomSheetState.closing;
      case AnimationStatus.dismissed:
        return MentoraBottomSheetState.closed;
      case AnimationStatus.completed:
        break;
    }
    if (_dragFraction != null) return MentoraBottomSheetState.dragging;
    if (widget.controller?.phase == MentoraBottomSheetPhase.processing) {
      return MentoraBottomSheetState.processing;
    }
    if (!_shown!.expandable) return MentoraBottomSheetState.opened;
    switch (widget.service.detent) {
      case MentoraBottomSheetDetent.expanded:
        return MentoraBottomSheetState.expanded;
      case MentoraBottomSheetDetent.collapsed:
        return MentoraBottomSheetState.collapsed;
    }
  }

  void _stepBack() {
    if (!widget.service.isBusy) return;
    widget.service.dismiss();
  }

  void _onDragUpdate(DragUpdateDetails details, double available) {
    if (available <= 0) return;
    final current = _dragFraction ?? _restingFraction;
    setState(() {
      _dragFraction = (current - details.primaryDelta! / available).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final theme = _theme!;
    final held = _dragFraction;
    final resting = widget.service.detent;
    setState(() => _dragFraction = null);
    if (held == null) return;

    if (theme.releasesTheSheet(fraction: held, from: resting)) {
      // The gesture said "I am done": the sheet disappears.
      _stepBack();
      return;
    }
    final settled = _shown!.expandable
        ? theme.detentNearest(held)
        : MentoraBottomSheetDetent.collapsed;
    widget.service.settleAt(settled);
  }

  double get _restingFraction =>
      _theme!.fractionOf(widget.service.detent);

  @override
  Widget build(BuildContext context) {
    final demand = _shown;
    final open = demand != null;
    final theme = _theme!;

    return Stack(
      children: [
        // While a sheet is open, the scene below is untouchable and
        // silent: the focus never escapes, the screen reader never
        // wanders.
        ExcludeFocus(
          key: const Key('sheet-scene-focus'),
          excluding: open,
          child: BlockSemantics(
            key: const Key('sheet-scene-semantics'),
            blocking: open,
            child: widget.child,
          ),
        ),
        if (open)
          LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxHeight;
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final progress = theme.curve.transform(
                    _animation.value.clamp(0, 1),
                  );
                  final visuals = theme.visualsOf(
                    variant: demand.variant,
                    state: _effectiveState,
                  );
                  final fraction = _dragFraction ?? _restingFraction;
                  final height = (available * fraction).clamp(0.0, available);

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: progress,
                          child: GestureDetector(
                            key: const Key('sheet-barrier'),
                            behavior: HitTestBehavior.opaque,
                            onTap: _stepBack,
                            child: ColoredBox(color: visuals.scrim),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        // The sheet rises from the bottom: it arrives
                        // from where it belongs.
                        bottom: -height * (1 - progress),
                        height: height,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _layer(demand, available),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _layer(MentoraBottomSheetRequest demand, double available) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _stepBack,
      },
      child: FocusScope(
        node: _layerFocus,
        autofocus: true,
        child: MentoraBottomSheet(
          request: demand,
          state: _effectiveState,
          detent: widget.service.detent,
          onDragUpdate: (details) => _onDragUpdate(details, available),
          onDragEnd: _onDragEnd,
        ),
      ),
    );
  }
}
