import '../core/di/foundation_services.dart';
import '../design_kit/accessibility/accessibility_engine.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../design_kit/components/dialog/mentora_dialog_service.dart';
import '../design_kit/international/international_engine.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/registry/binding_integrity_engine.dart';
import '../design_kit/registry/bound_token_engines.dart';
import '../design_kit/registry/token_engines.dart';
import '../design_kit/registry/token_provider.dart';
import '../design_kit/registry/token_registry.dart';
import '../design_kit/registry/token_validator.dart';
import '../design_kit/responsive/responsive_engine.dart';
import '../design_kit/theme/theme_engine.dart';
import '../design_kit/tokens/surface_elevation_tokens.dart';
import '../design_kit/tokens/token_bindings_phase1.dart';
import '../design_kit/tokens/token_catalog_phase1.dart';
import '../localization/localization_engine.dart';
import 'startup_pipeline.dart';

/// Registers every Design Kit engine into the official container —
/// the single assembly point of the Kit (official stage: Chargement
/// des services).
///
/// Since F1.2 the assembly is token-driven: the 71 Phase 1 Tokens are
/// received into the registry, bound through the provider, validated
/// (fail closed), and every engine consumes them exclusively.
final class DesignKitBootstrapStep implements StartupStep {
  const DesignKitBootstrapStep();

  @override
  String get name => 'services';

  @override
  Future<void> run(FoundationServices services) async {
    services.register<DesignTokenRegistry>(() {
      final registry = DesignTokenRegistry();
      return registry;
    });
    services.register<DesignTokenProvider>(() {
      final registry = services.get<DesignTokenRegistry>();
      final provider = DesignTokenProvider(registry: registry);
      receivePhase1Tokens(registry, provider);
      const TokenValidator().validate(
        registry: registry,
        provider: provider,
        expectedComplete: {
          for (final identity in phase1Identities()) identity.name,
        },
      );
      return provider;
    });

    services.register<ColorTokenEngine>(
      () => BoundColorTokenEngine(
        provider: services.get<DesignTokenProvider>(),
      ),
    );
    services.register<TypographyTokenEngine>(
      () => BoundTypographyTokenEngine(
        provider: services.get<DesignTokenProvider>(),
      ),
    );
    services.register<SpacingTokenEngine>(
      () => BoundSpacingTokenEngine(
        provider: services.get<DesignTokenProvider>(),
      ),
    );
    services.register<SurfaceTokenEngine>(
      () => BoundSurfaceTokenEngine(
        provider: services.get<DesignTokenProvider>(),
      ),
    );
    services.register<ElevationTokenEngine<ElevationExpression>>(
      () => BoundElevationTokenEngine(
        provider: services.get<DesignTokenProvider>(),
      ),
    );
    services.register<BindingIntegrityEngine>(
      () => const BindingIntegrityEngine(),
    );

    services.register<AppearanceEngine>(AppearanceEngine.new);
    services.register<ThemeEngine>(
      () => ThemeEngine(
        colors: services.get<ColorTokenEngine>(),
        typography: services.get<TypographyTokenEngine>(),
        surfaces: services.get<SurfaceTokenEngine>(),
      ),
    );
    services.register<MotionEngine>(() => const MotionEngine());
    services.register<AccessibilityEngine>(() => const AccessibilityEngine());
    services.register<ResponsiveEngine>(() => const ResponsiveEngine());
    services.register<InternationalEngine>(() => const InternationalEngine());
    services.register<LocalizationEngine>(() => const LocalizationEngine());
    services.register<MentoraDialogService>(MentoraDialogService.new);
    services.register<MentoraBottomSheetService>(
      MentoraBottomSheetService.new,
    );
  }
}

/// Resolves every Design Kit engine — used by the Validation stage to
/// prove the container serves its contract before anything starts.
/// Since F1.2 the binding integrity is verified here too: an
/// incomplete token coverage never reaches runApp (fail closed).
void validateDesignKit(FoundationServices services) {
  services
    ..get<AppearanceEngine>()
    ..get<ThemeEngine>()
    ..get<MotionEngine>()
    ..get<AccessibilityEngine>()
    ..get<ResponsiveEngine>()
    ..get<InternationalEngine>()
    ..get<LocalizationEngine>()
    ..get<MentoraDialogService>()
    ..get<MentoraBottomSheetService>()
    ..get<ColorTokenEngine>()
    ..get<TypographyTokenEngine>()
    ..get<SpacingTokenEngine>()
    ..get<SurfaceTokenEngine>()
    ..get<ElevationTokenEngine<ElevationExpression>>();

  services.get<BindingIntegrityEngine>().verify(
    registry: services.get<DesignTokenRegistry>(),
    provider: services.get<DesignTokenProvider>(),
  );
}
