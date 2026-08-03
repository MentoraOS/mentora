import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/foundation_services.dart';
import '../design_kit/accessibility/accessibility_engine.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/theme/theme_engine.dart';
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
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  accessibility.textScaleFor(state),
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: NavigationShell(
            appearance: appearance,
            accessibility: accessibility,
          ),
        );
      },
    );
  }
}
