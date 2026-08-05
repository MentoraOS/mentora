import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/snackbar_tokens.dart';
import '../design_kit_scope.dart';
import 'mentora_snackbar.dart';
import 'mentora_snackbar_request.dart';
import 'mentora_snackbar_service.dart';
import 'mentora_snackbar_style.dart';
import 'mentora_snackbar_theme.dart';

/// Where the message layer lives. Installed once, always mounted: no
/// route, and none of the framework's messengers — a transient signal
/// is a layer of the application, not a page of its history.
///
/// It holds the guarantees a message owes: it never traps the focus,
/// never takes it, never blocks a pointer that was not aimed at it —
/// and it counts the reading time itself, so a message that leaves on
/// its own truly does.
final class MentoraSnackbarHost extends StatefulWidget {
  final MentoraSnackbarService service;
  final MentoraSnackbarController? controller;
  final Widget child;

  const MentoraSnackbarHost({
    super.key,
    required this.service,
    required this.child,
    this.controller,
  });

  @override
  State<MentoraSnackbarHost> createState() => _MentoraSnackbarHostState();
}

final class _MentoraSnackbarHostState extends State<MentoraSnackbarHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: Duration.zero,
  );

  MentoraSnackbarTheme? _theme;
  MentoraSnackbarRequest? _shown;
  Timer? _dwell;

  /// Why the message on screen is leaving — a message that served its
  /// time expires; one that was ended is dismissed.
  bool _expiring = false;

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
    _theme = MentoraSnackbarTheme.fromScope(DesignKitScope.of(context));
  }

  @override
  void didUpdateWidget(MentoraSnackbarHost oldWidget) {
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
    _dwell?.cancel();
    widget.service.removeListener(_onDemandChanged);
    widget.controller?.removeListener(_onPhaseChanged);
    _animation.dispose();
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
    if (identical(demand, _shown)) return;

    _dwell?.cancel();
    _dwell = null;

    if (demand != null) {
      // A message that arrives while another is speaking takes its
      // place: the layer updates, it never stacks.
      final updating = _shown != null;
      setState(() {
        _shown = demand;
        _expiring = false;
      });
      // Every duration comes from the Motion Engine: a None
      // preference makes the arrival instantaneous, never absent.
      _animation.duration = _theme!.transitionDurationFor(demand.variant);
      if (updating) {
        _animation.value = 1;
      } else {
        _animation.forward(from: 0);
      }
      _startDwell(demand);
      return;
    }

    _animation.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _shown = null;
        _expiring = false;
      });
    });
  }

  /// The reading time is not motion time: the Motion preference never
  /// shortens it — a message no one had time to read has not been
  /// delivered.
  void _startDwell(MentoraSnackbarRequest demand) {
    final dwell = demand.dwell;
    if (dwell == null) return;
    _dwell = Timer(dwell, () {
      if (!mounted || !identical(widget.service.current, demand)) return;
      setState(() => _expiring = true);
      widget.service.dismiss(const MentoraSnackbarResult.expired());
    });
  }

  /// Exactly one effective state: the layer's life, then how the
  /// message is leaving, then whether it is being replaced in place.
  MentoraSnackbarState get _effectiveState {
    if (_shown == null) return MentoraSnackbarState.hidden;
    switch (_animation.status) {
      case AnimationStatus.forward:
        return MentoraSnackbarState.showing;
      case AnimationStatus.reverse:
        return _expiring
            ? MentoraSnackbarState.expiring
            : MentoraSnackbarState.dismissed;
      case AnimationStatus.dismissed:
        return MentoraSnackbarState.hidden;
      case AnimationStatus.completed:
        break;
    }
    if (widget.controller?.phase == MentoraSnackbarPhase.working) {
      return MentoraSnackbarState.updating;
    }
    return MentoraSnackbarState.visible;
  }

  @override
  Widget build(BuildContext context) {
    final demand = _shown;
    final theme = _theme!;

    return Stack(
      children: [
        // The scene keeps everything: a message never blocks a
        // pointer, never takes the focus, never silences anyone.
        widget.child,
        if (demand != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(theme.sceneMargin),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) {
                      final progress = theme
                          .curveFor(demand.variant)
                          .transform(_animation.value.clamp(0, 1));
                      return Opacity(
                        opacity: progress,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            snackbarEntryOffset * (1 - progress),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: MentoraSnackbar(
                              request: demand,
                              state: _effectiveState,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
