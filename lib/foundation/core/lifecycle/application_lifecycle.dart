import 'package:flutter/widgets.dart';

/// Receives the application lifecycle transitions.
abstract interface class ApplicationLifecycleListener {
  void onLifecycleChanged(AppLifecycleState state);
}

/// Publishes the widget-binding lifecycle to registered listeners.
/// One owner, explicit attach/detach — no global observer.
final class ApplicationLifecycle with WidgetsBindingObserver {
  final List<ApplicationLifecycleListener> _listeners = [];
  bool _attached = false;

  void attach(WidgetsBinding binding) {
    if (_attached) {
      return;
    }
    binding.addObserver(this);
    _attached = true;
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
    for (final listener in List.of(_listeners)) {
      listener.onLifecycleChanged(state);
    }
  }
}
