import 'package:flutter/widgets.dart';

/// The official lifecycle phases of the application. Every framework
/// state maps onto exactly one — the platforms will reason in these
/// phases, never in framework enums.
enum MentoraLifecyclePhase { launch, foreground, background, resume, terminate }

/// Receives the official lifecycle transitions.
abstract interface class ApplicationLifecycleListener {
  void onLifecycleChanged(MentoraLifecyclePhase phase);
}

/// Publishes the widget-binding lifecycle to registered listeners as
/// official phases. One owner, explicit attach/detach — no global
/// observer.
final class ApplicationLifecycle with WidgetsBindingObserver {
  final List<ApplicationLifecycleListener> _listeners = [];
  bool _attached = false;
  bool _wasBackgrounded = false;

  void attach(WidgetsBinding binding) {
    if (_attached) {
      return;
    }
    binding.addObserver(this);
    _attached = true;
    _publish(MentoraLifecyclePhase.launch);
  }

  void detach(WidgetsBinding binding) {
    if (!_attached) {
      return;
    }
    binding.removeObserver(this);
    _attached = false;
  }

  void addListener(ApplicationLifecycleListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ApplicationLifecycleListener listener) {
    _listeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _publish(_phaseFor(state));
  }

  MentoraLifecyclePhase _phaseFor(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_wasBackgrounded) {
          _wasBackgrounded = false;
          return MentoraLifecyclePhase.resume;
        }
        return MentoraLifecyclePhase.foreground;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _wasBackgrounded = true;
        return MentoraLifecyclePhase.background;
      case AppLifecycleState.detached:
        return MentoraLifecyclePhase.terminate;
    }
  }

  void _publish(MentoraLifecyclePhase phase) {
    for (final listener in List.of(_listeners)) {
      listener.onLifecycleChanged(phase);
    }
  }
}
