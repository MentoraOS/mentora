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
/// the single assembly point of the Kit (its composition root).
final class DesignKitBootstrapStep implements StartupStep {
  const DesignKitBootstrapStep();

  @override
  String get name => 'design-kit';

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
