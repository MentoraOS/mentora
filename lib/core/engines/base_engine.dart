import 'engine_state.dart';

abstract class BaseEngine {
  EngineState _state = EngineState.created;

  EngineState get state => _state;

  bool get isRunning => _state == EngineState.running;

  bool get isInitialized => _state == EngineState.initialized;

  Future<void> initialize() async {
    _state = EngineState.initialized;
  }

  Future<void> start() async {
    _state = EngineState.running;
  }

  Future<void> pause() async {
    _state = EngineState.paused;
  }

  Future<void> stop() async {
    _state = EngineState.stopped;
  }

  Future<void> dispose() async {
    _state = EngineState.disposed;
  }
}
