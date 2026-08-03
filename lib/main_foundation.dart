import 'foundation/bootstrap/app_bootstrap.dart';

/// The official entrypoint of the Mentora foundation application
/// (F1.0). Launch with: flutter run -t lib/main_foundation.dart
///
/// The legacy entrypoint (lib/main.dart) remains untouched — frozen
/// module; the default switch will be an explicit future decision.
Future<void> main() async {
  await AppBootstrap().launch();
}
