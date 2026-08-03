import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/app/mentora_foundation_app.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';

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

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
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

  testWidgets('the dark preference switches the theme without changing '
      'any meaning', (tester) async {
    final services = await _services();
    final appearance = services.get<AppearanceEngine>();

    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    appearance.updateTheme(ThemePreference.dark);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NavigationBar));
    expect(Theme.of(context).colorScheme.brightness, Brightness.dark);
    // The five entries are untouched by an appearance change (GE-18).
    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });
}
