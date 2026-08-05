import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/foundation_services.dart';
import '../design_kit/accessibility/accessibility_engine.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/components/design_kit_scope.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_host.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../design_kit/components/dialog/mentora_dialog_host.dart';
import '../design_kit/components/snackbar/mentora_snackbar_host.dart';
import '../design_kit/components/snackbar/mentora_snackbar_service.dart';
import '../design_kit/components/dialog/mentora_dialog_service.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/registry/token_engines.dart';
import '../design_kit/theme/theme_engine.dart';
import '../design_kit/theme/theme_resolver.dart';
import '../design_kit/tokens/surface_elevation_tokens.dart';
import '../localization/localization_engine.dart';
import '../localization/mentora_strings.dart';
import '../navigation/navigation_shell.dart';

/// The root widget of the foundation application. It receives the
/// service container built by the bootstrap and wires the engines —
/// no logic, no business, no decision lives here.
final class MentoraFoundationApp extends StatelessWidget {
  final FoundationServices services;

  const MentoraFoundationApp({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final appearance = services.get<AppearanceEngine>();
    final themeEngine = services.get<ThemeEngine>();
    final accessibility = services.get<AccessibilityEngine>();
    final localization = services.get<LocalizationEngine>();

    return ListenableBuilder(
      listenable: appearance,
      builder: (context, _) {
        final state = appearance.state;
        return MaterialApp(
          onGenerateTitle: (context) => MentoraStrings.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: themeEngine.resolveMode(state),
          theme: themeEngine.lightTheme(state),
          darkTheme: themeEngine.darkTheme(state),
          supportedLocales: LocalizationEngine.supportedLocales,
          localizationsDelegates: const [
            MentoraStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (systemLocale, supported) {
            return localization.resolve(systemLocale: systemLocale);
          },
          builder: (context, child) {
            final media = MediaQuery.of(context);
            // The scope is the official consumption channel of the
            // Core Components: engines, appearance and the variant
            // resolved exactly once, for the whole tree.
            final variant = const ThemeResolver().resolve(
              theme: state.theme,
              contrast: state.contrast,
              platformBrightness: media.platformBrightness,
            );
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  accessibility.textScaleFor(state),
                ),
              ),
              child: DesignKitScope(
                colors: services.get<ColorTokenEngine>(),
                typography: services.get<TypographyTokenEngine>(),
                spacing: services.get<SpacingTokenEngine>(),
                surfaces: services.get<SurfaceTokenEngine>(),
                elevation: services
                    .get<ElevationTokenEngine<ElevationExpression>>(),
                motion: services.get<MotionEngine>(),
                accessibility: accessibility,
                appearance: state,
                variant: variant,
                // The contextual layers live above the application
                // and below nothing: installed once, never pushed.
                child: MentoraDialogHost(
                  service: services.get<MentoraDialogService>(),
                  child: MentoraBottomSheetHost(
                    service: services.get<MentoraBottomSheetService>(),
                    child: MentoraSnackbarHost(
                      service: services.get<MentoraSnackbarService>(),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
          home: NavigationShell(
            appearance: appearance,
            accessibility: accessibility,
            motion: services.get<MotionEngine>(),
          ),
        );
      },
    );
  }
}
