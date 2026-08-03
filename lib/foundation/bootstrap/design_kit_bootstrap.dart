import '../core/di/foundation_services.dart';
import '../design_kit/accessibility/accessibility_engine.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/international/international_engine.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/responsive/responsive_engine.dart';
import '../design_kit/theme/theme_engine.dart';
import '../localization/localization_engine.dart';
import 'startup_pipeline.dart';

/// Registers every Design Kit engine into the official container —
/// the single assembly point of the Kit (official stage: Chargement
/// des services).
final class DesignKitBootstrapStep implements StartupStep {
  const DesignKitBootstrapStep();

  @override
  String get name => 'services';

  @override
  Future<void> run(FoundationServices services) async {
    services.register<AppearanceEngine>(AppearanceEngine.new);
    services.register<ThemeEngine>(() => const ThemeEngine());
    services.register<MotionEngine>(() => const MotionEngine());
    services.register<AccessibilityEngine>(() => const AccessibilityEngine());
    services.register<ResponsiveEngine>(() => const ResponsiveEngine());
    services.register<InternationalEngine>(() => const InternationalEngine());
    services.register<LocalizationEngine>(() => const LocalizationEngine());
  }
}

/// Resolves every Design Kit engine — used by the Validation stage to
/// prove the container serves its contract before anything starts.
void validateDesignKit(FoundationServices services) {
  services
    ..get<AppearanceEngine>()
    ..get<ThemeEngine>()
    ..get<MotionEngine>()
    ..get<AccessibilityEngine>()
    ..get<ResponsiveEngine>()
    ..get<InternationalEngine>()
    ..get<LocalizationEngine>();
}
