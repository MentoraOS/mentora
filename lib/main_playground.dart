import 'package:flutter/widgets.dart';

import 'foundation/bootstrap/app_bootstrap.dart';
import 'foundation/playground/playground_app.dart';
import 'foundation/playground/playground_guard.dart';

/// The developer entry point of the Design Kit Playground (F1.2A).
/// Launch with: flutter run -t lib/main_playground.dart
///
/// Development only — the guard refuses release builds, fail closed.
Future<void> main() async {
  guardPlaygroundAccess();
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppBootstrap().initialize();
  runApp(PlaygroundApp(services: services));
}
