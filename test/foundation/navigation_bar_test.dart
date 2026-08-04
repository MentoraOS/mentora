import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/app/mentora_foundation_app.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/tokens/navigation_bar_tokens.dart';
import 'package:mentora/foundation/navigation/mentora_navigation_bar.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pumpApp(WidgetTester tester) async {
  final services = await _services();
  await tester.pumpWidget(MentoraFoundationApp(services: services));
  await tester.pumpAndSettle();
  return services;
}

void main() {
  testWidgets('the bar is compact: its height is the official token, '
      'inside the 60–64 dp band', (tester) async {
    await _pumpApp(tester);

    final size = tester.getSize(find.byType(MentoraNavigationBar));
    expect(size.height, navigationBarTokens.height);
    expect(size.height, greaterThanOrEqualTo(60));
    expect(size.height, lessThanOrEqualTo(64));
  });

  testWidgets('labels are one line at the official 11 sp token — never '
      'a coded size', (tester) async {
    await _pumpApp(tester);

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(MentoraNavigationBar),
        matching: find.text('Home'),
      ),
    );
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.fontSize, navigationBarTokens.labelSize);
    expect(navigationBarTokens.labelSize, 11);
  });

  testWidgets('the active capsule is the discreet highlight role — the '
      'inactive entries carry none', (tester) async {
    await _pumpApp(tester);

    final capsules = tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: find.byType(MentoraNavigationBar),
            matching: find.byType(AnimatedContainer),
          ),
        )
        .toList();
    expect(capsules.length, 5);

    final context = tester.element(find.byType(MentoraNavigationBar));
    final highlight = Theme.of(context).highlightColor;
    Color? capsuleColor(AnimatedContainer capsule) =>
        (capsule.decoration as BoxDecoration?)?.color;

    expect(capsuleColor(capsules.first), highlight);
    for (final capsule in capsules.skip(1)) {
      expect(capsuleColor(capsule), isNull);
    }
  });

  testWidgets('tapping an entry moves the capsule — one selection at a '
      'time', (tester) async {
    await _pumpApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(MentoraNavigationBar),
        matching: find.text('Business'),
      ),
    );
    await tester.pumpAndSettle();

    final bar = tester.widget<MentoraNavigationBar>(
      find.byType(MentoraNavigationBar),
    );
    expect(bar.selectedIndex, 2);
  });

  testWidgets('the capsule motion is sober and honors the Motion '
      'preference: None silences it', (tester) async {
    final services = await _services();
    services.get<AppearanceEngine>().updateMotion(MotionPreference.none);
    await tester.pumpWidget(MentoraFoundationApp(services: services));
    await tester.pumpAndSettle();

    final capsule = tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: find.byType(MentoraNavigationBar),
            matching: find.byType(AnimatedContainer),
          ),
        )
        .first;
    expect(capsule.duration, Duration.zero);
  });

  testWidgets('each entry stays a reachable target: the full-height '
      'item meets the interaction token', (tester) async {
    await _pumpApp(tester);

    final item = tester.getSize(
      find
          .descendant(
            of: find.byType(MentoraNavigationBar),
            matching: find.byType(InkWell),
          )
          .first,
    );
    // Height minus the divider still exceeds the 48 dp reachable target.
    expect(item.height, greaterThanOrEqualTo(48));
    expect(item.width, greaterThanOrEqualTo(48));
  });
}
