import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/app/mentora_foundation_app.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/tokens/design_tokens.dart';
import 'package:mentora/foundation/navigation/mentora_navigation_bar.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

void main() {
  testWidgets('the foundation app boots into the five-entry shell', (
    tester,
  ) async {
    final services = await _services();

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    expect(find.byType(MentoraNavigationBar), findsOneWidget);
    final bar = tester.widget<MentoraNavigationBar>(
      find.byType(MentoraNavigationBar),
    );
    expect(bar.destinations.length, 5);
  });

  testWidgets('switching tab shows the calm foundation surface of the '
      'selected platform', (tester) async {
    final services = await _services();

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    // The surface title matches the selected entry — an honest,
    // designed placeholder, never a business screen.
    expect(find.text('Account'), findsNWidgets(2));
    expect(find.text('Nothing needs your attention.'), findsOneWidget);
  });

  testWidgets('F1.0.1 — the app boots under a French device locale: '
      'material localizations resolve, strings follow', (tester) async {
    final services = await _services();

    tester.platformDispatcher.localeTestValue = const Locale('fr');
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Surface title + navigation label: the French strings are live.
    expect(find.text('Accueil'), findsNWidgets(2));
    final context = tester.element(find.byType(MentoraNavigationBar));
    // The regression that motivated this sprint: MaterialLocalizations
    // must resolve for every supported locale, not only English.
    expect(MaterialLocalizations.of(context), isNotNull);
  });

  testWidgets('F1.0.1 — the global localization delegates are installed', (
    tester,
  ) async {
    final services = await _services();

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      app.localizationsDelegates,
      containsAll(<Object>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ]),
    );
  });

  testWidgets('F1.0.1 — the shell never overflows on a phone at the '
      'largest font scale', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final services = await _services();
    services.get<AppearanceEngine>().updateFontScale(
      FontScalePreference.extraLarge,
    );

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    // The regression that motivated this sprint: no RenderFlex overflow
    // on the bottom navigation, at any official font scale.
    expect(tester.takeException(), isNull);
    expect(find.byType(MentoraNavigationBar), findsOneWidget);
  });

  testWidgets('F1.0.1 — the chrome scale is bounded, the content scale '
      'is not', (tester) async {
    final services = await _services();
    final accessibility = services.get<AccessibilityEngine>();
    const extraLarge = AppearanceState(
      fontScale: FontScalePreference.extraLarge,
    );

    expect(
      accessibility.textScaleFor(extraLarge),
      greaterThan(maximumChromeFontScale),
    );
    expect(
      accessibility.chromeTextScaleFor(extraLarge),
      maximumChromeFontScale,
    );
    expect(accessibility.chromeTextScaleFor(const AppearanceState()), 1.0);
  });

  testWidgets('the dark preference switches the theme without changing '
      'any meaning', (tester) async {
    final services = await _services();
    final appearance = services.get<AppearanceEngine>();

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    appearance.updateTheme(ThemePreference.dark);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MentoraNavigationBar));
    expect(Theme.of(context).colorScheme.brightness, Brightness.dark);
    // The five entries are untouched by an appearance change (GE-18).
    expect(
      tester
          .widget<MentoraNavigationBar>(find.byType(MentoraNavigationBar))
          .destinations
          .length,
      5,
    );
  });
}
