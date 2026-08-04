import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import '../../tokens/dialog_tokens.dart';
import '../design_kit_scope.dart';
import 'mentora_dialog.dart';
import 'mentora_dialog_request.dart';
import 'mentora_dialog_service.dart';
import 'mentora_dialog_style.dart';
import 'mentora_dialog_theme.dart';

/// Where the dialog layer lives. Installed once, above everything:
/// no route is pushed, no showDialog is ever called — the exchange is
/// a layer of the application, not a page of its history.
///
/// It holds the guarantees a layer owes: the focus is trapped while
/// the exchange lasts and restored to where it was, the scene below
/// is silenced for screen readers, Escape steps back where stepping
/// back exists, and Enter performs the recommendation — never a
/// dangerous act.
final class MentoraDialogHost extends StatefulWidget {
  final MentoraDialogService service;
  final MentoraDialogController? controller;
  final Widget child;

  const MentoraDialogHost({
    super.key,
    required this.service,
    required this.child,
    this.controller,
  });

  @override
  State<MentoraDialogHost> createState() => _MentoraDialogHostState();
}

final class _MentoraDialogHostState extends State<MentoraDialogHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: Duration.zero,
  );
  final FocusScopeNode _layerFocus = FocusScopeNode(
    debugLabel: 'mentora-dialog',
  );

  MentoraDialogTheme? _theme;
  MentoraDialogRequest? _shown;
  FocusNode? _restoreTo;

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
    _theme = MentoraDialogTheme.fromScope(DesignKitScope.of(context));
  }

  @override
  void didUpdateWidget(MentoraDialogHost oldWidget) {
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
    if (identical(demand, _shown)) return;

    if (demand != null) {
      if (_shown == null) _restoreTo = FocusManager.instance.primaryFocus;
      setState(() => _shown = demand);
      // Every duration comes from the Motion Engine: a None
      // preference makes the arrival instantaneous, never absent.
      _animation.duration = _theme!.transitionDurationFor(demand.variant);
      _animation.forward(from: 0);
      return;
    }

    _animation.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _shown = null);
      final restore = _restoreTo;
      _restoreTo = null;
      // The focus comes home only once the scene is reachable again:
      // asking before the layer is gone would ask a closed door.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restore?.requestFocus();
      });
    });
  }

  /// Exactly one effective state: the layer's life, and — once it is
  /// settled — the exchange the application announces.
  MentoraDialogState get _effectiveState {
    if (_shown == null) return MentoraDialogState.closed;
    switch (_animation.status) {
      case AnimationStatus.forward:
        return MentoraDialogState.opening;
      case AnimationStatus.reverse:
        return MentoraDialogState.closing;
      case AnimationStatus.dismissed:
        return MentoraDialogState.closed;
      case AnimationStatus.completed:
        break;
    }
    switch (widget.controller?.phase ?? MentoraDialogPhase.waiting) {
      case MentoraDialogPhase.processing:
        return MentoraDialogState.processing;
      case MentoraDialogPhase.success:
        return MentoraDialogState.success;
      case MentoraDialogPhase.error:
        return MentoraDialogState.error;
      case MentoraDialogPhase.waiting:
        return widget.service.current == null
            ? MentoraDialogState.opened
            : MentoraDialogState.waiting;
    }
  }

  void _stepBack() {
    final demand = _shown;
    if (demand == null || !widget.service.isBusy) return;
    if (!MentoraDialogService.allowsStepBack(demand)) return;
    widget.service.dismiss();
  }

  void _performDefault() {
    final demand = _shown;
    if (demand == null || !widget.service.isBusy) return;
    if (_effectiveState == MentoraDialogState.processing) return;
    final action = demand.keyboardDefault;
    if (action == null) return;
    widget.service.answer(action);
  }

  @override
  Widget build(BuildContext context) {
    final demand = _shown;
    final open = demand != null;
    final theme = _theme!;

    return Stack(
      children: [
        // While an exchange is open, the scene below is untouchable
        // and silent: the focus never escapes, the screen reader
        // never wanders.
        ExcludeFocus(
          key: const Key('dialog-scene-focus'),
          excluding: open,
          child: BlockSemantics(
            key: const Key('dialog-scene-semantics'),
            blocking: open,
            child: widget.child,
          ),
        ),
        if (open)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final progress = theme
                  .curveFor(demand.variant)
                  .transform(_animation.value.clamp(0, 1));
              final visuals = theme.visualsOf(
                variant: demand.variant,
                state: _effectiveState,
              );
              return Opacity(
                opacity: progress,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        key: const Key('dialog-barrier'),
                        behavior: HitTestBehavior.opaque,
                        onTap: _stepBack,
                        child: ColoredBox(color: visuals.scrim),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(theme.sceneMargin),
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              dialogEntryOffset * (1 - progress),
                            ),
                            child: _layer(demand),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _layer(MentoraDialogRequest demand) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _stepBack,
        const SingleActivator(LogicalKeyboardKey.enter): _performDefault,
      },
      child: FocusScope(
        node: _layerFocus,
        autofocus: true,
        child: SingleChildScrollView(
          child: MentoraDialog(
            request: demand,
            state: _effectiveState,
            onAction: widget.service.answer,
          ),
        ),
      ),
    );
  }
}
