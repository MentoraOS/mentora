import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/button_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/color_internals.dart';

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget button, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
}) async {
  final services = await _services();
  await tester.pumpWidget(
    MaterialApp(
      theme: services.get<ThemeEngine>().themeForVariant(variant),
      home: DesignKitScope(
        colors: services.get<ColorTokenEngine>(),
        typography: services.get<TypographyTokenEngine>(),
        spacing: services.get<SpacingTokenEngine>(),
        surfaces: services.get<SurfaceTokenEngine>(),
        motion: services.get<MotionEngine>(),
        accessibility: services.get<AccessibilityEngine>(),
        appearance: appearance,
        variant: variant,
        child: Scaffold(body: Center(child: button)),
      ),
    ),
  );
  // The element tree survives successive pumps: settle so the state
  // transition (an implicit animation) reaches its resting values.
  await tester.pumpAndSettle();
  return services;
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(MentoraButton),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.decoration! as BoxDecoration;
}

Text _label(WidgetTester tester, String text) {
  return tester.widget<Text>(
    find.descendant(
      of: find.byType(MentoraButton),
      matching: find.text(text),
    ),
  );
}

void main() {
  testWidgets('the label speaks the action typography role — one line, '
      'never a coded size', (tester) async {
    final services = await _pump(
      tester,
      MentoraButton(label: 'Continuer', onPressed: () {}),
    );

    final expected = services
        .get<TypographyTokenEngine>()
        .styleOf(buttonTypographyRole, ThemeVariantId.light);
    final label = _label(tester, 'Continuer');
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.fontSize, expected.fontSize);
    expect(label.style?.fontWeight, expected.fontWeight);
  });

  testWidgets('contained expresses the identity act: primary fill and '
      'identity internals foreground', (tester) async {
    final services = await _pump(
      tester,
      MentoraButton(label: 'Continuer', onPressed: () {}),
    );

    final colors = services.get<ColorTokenEngine>();
    final decoration = _decoration(tester);
    expect(
      decoration.color,
      colors.colorOf(ColorRole.primary, ThemeVariantId.light),
    );
    expect(
      _label(tester, 'Continuer').style?.color,
      identityInternalsFor(ThemeVariantId.light).onPrimary,
    );
  });

  testWidgets('every variant resolves its official roles — nothing '
      'else', (tester) async {
    Future<void> check(
      MentoraButtonVariant variant,
      void Function(ColorTokenEngine colors, BoxDecoration decoration)
      verify,
    ) async {
      final services = await _pump(
        tester,
        MentoraButton(label: 'Agir', onPressed: () {}, variant: variant),
      );
      verify(services.get<ColorTokenEngine>(), _decoration(tester));
    }

    Color role(ColorTokenEngine colors, ColorRole r) =>
        colors.colorOf(r, ThemeVariantId.light);

    await check(MentoraButtonVariant.tonal, (colors, decoration) {
      expect(decoration.color, role(colors, ColorRole.highlight));
      expect(decoration.border, isNull);
    });
    await check(MentoraButtonVariant.outlined, (colors, decoration) {
      expect(decoration.color, isNull);
      expect(
        decoration.border?.top.color,
        role(colors, ColorRole.outline),
      );
    });
    await check(MentoraButtonVariant.text, (colors, decoration) {
      expect(decoration.color, isNull);
      expect(decoration.border, isNull);
    });
    await check(MentoraButtonVariant.danger, (colors, decoration) {
      expect(decoration.color, role(colors, ColorRole.critical));
    });
    await check(MentoraButtonVariant.success, (colors, decoration) {
      expect(decoration.color, role(colors, ColorRole.success));
    });
  });

  testWidgets('disabled is expressed, never hidden — and the act is '
      'unreachable', (tester) async {
    final services = await _pump(
      tester,
      const MentoraButton(label: 'Continuer', onPressed: null),
    );

    final colors = services.get<ColorTokenEngine>();
    expect(
      _decoration(tester).color,
      colors.colorOf(ColorRole.disabled, ThemeVariantId.light),
    );
    expect(
      _label(tester, 'Continuer').style?.color,
      colors.colorOf(ColorRole.unavailable, ThemeVariantId.light),
    );
  });

  testWidgets('the opposable reachable target prevails at every size — '
      'the token proposes, the floor wins', (tester) async {
    for (final size in MentoraButtonSize.values) {
      await _pump(
        tester,
        MentoraButton(label: 'Ok', onPressed: () {}, size: size),
      );
      final rendered = tester.getSize(find.byType(MentoraButton));
      expect(rendered.height, greaterThanOrEqualTo(48));
      expect(rendered.width, greaterThanOrEqualTo(48));
    }

    await _pump(
      tester,
      MentoraButton(
        label: 'Ok',
        onPressed: () {},
        size: MentoraButtonSize.large,
      ),
    );
    expect(
      tester.getSize(find.byType(MentoraButton)).height,
      greaterThanOrEqualTo(largeButtonSpec.height),
    );
  });

  testWidgets('the tap performs the act — once per tap', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      MentoraButton(label: 'Continuer', onPressed: () => taps++),
    );

    await tester.tap(find.byType(MentoraButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('loading blocks the act and shows exactly one sober '
      'signal', (tester) async {
    var taps = 0;
    final controller = MentoraButtonController();
    addTearDown(controller.dispose);
    await _pump(
      tester,
      MentoraButton(
        label: 'Envoyer',
        onPressed: () => taps++,
        controller: controller,
      ),
    );

    controller.beginLoading();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(MentoraButton));
    await tester.pump();
    expect(taps, 0, reason: 'a pending act is never restarted');
  });

  testWidgets('the application phases drive the button: success, '
      'error, then reset', (tester) async {
    final controller = MentoraButtonController();
    addTearDown(controller.dispose);
    final services = await _pump(
      tester,
      MentoraButton(
        label: 'Envoyer',
        onPressed: () {},
        controller: controller,
      ),
    );
    final colors = services.get<ColorTokenEngine>();
    Color role(ColorRole r) => colors.colorOf(r, ThemeVariantId.light);

    controller.showSuccess();
    await tester.pump();
    expect(_decoration(tester).color, role(ColorRole.success));

    controller.showError();
    await tester.pump();
    expect(_decoration(tester).color, role(ColorRole.critical));

    controller.reset();
    await tester.pump();
    expect(_decoration(tester).color, role(ColorRole.primary));
  });

  testWidgets('every duration comes from the Motion Engine: None '
      'silences the transition', (tester) async {
    await _pump(
      tester,
      MentoraButton(label: 'Ok', onPressed: () {}),
      appearance: const AppearanceState(motion: MotionPreference.none),
    );
    AnimatedContainer container() => tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(MentoraButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(container().duration, Duration.zero);

    const appearance = AppearanceState();
    final services = await _pump(
      tester,
      MentoraButton(label: 'Ok', onPressed: () {}),
    );
    expect(
      container().duration,
      services
          .get<MotionEngine>()
          .durationFor(MotionIntention.confirmer, appearance),
    );
  });

  testWidgets('the four theme variants serve the same roles — meaning '
      'never changes with appearance', (tester) async {
    for (final variant in ThemeVariantId.values) {
      final services = await _pump(
        tester,
        MentoraButton(label: 'Ok', onPressed: () {}),
        variant: variant,
      );
      expect(
        _decoration(tester).color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.primary, variant),
      );
    }
  });

  testWidgets('keyboard focus rings with the focus role and Enter '
      'performs the act', (tester) async {
    var taps = 0;
    final services = await _pump(
      tester,
      MentoraButton(label: 'Continuer', onPressed: () => taps++),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final border = _decoration(tester).border?.top;
    expect(
      border?.color,
      services
          .get<ColorTokenEngine>()
          .colorOf(ColorRole.focus, ThemeVariantId.light),
    );
    expect(border?.width, buttonFocusRingWidth);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('the button announces itself: a named, enabled button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, MentoraButton(label: 'Continuer', onPressed: () {}));

    final node = tester.getSemantics(find.byType(MentoraButton));
    expect(node.label, 'Continuer');
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isEnabled, Tristate.isTrue);

    await _pump(
      tester,
      const MentoraButton(label: 'Continuer', onPressed: null),
    );
    final disabled = tester.getSemantics(find.byType(MentoraButton));
    expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
    handle.dispose();
  });

  testWidgets('an icon sits at its declared position, sized by the '
      'token', (tester) async {
    await _pump(
      tester,
      MentoraButton(
        label: 'Suivant',
        onPressed: () {},
        icon: Icons.arrow_forward,
        iconPosition: MentoraButtonIconPosition.trailing,
      ),
    );

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(MentoraButton),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.size, mediumButtonSpec.iconSize);
    final iconX = tester.getCenter(find.byType(Icon)).dx;
    final labelX = tester.getCenter(find.text('Suivant')).dx;
    expect(iconX, greaterThan(labelX));
  });

  testWidgets('outside the Design Kit the button refuses to build — '
      'fail closed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentoraButton(label: 'Ok', onPressed: () {}),
        ),
      ),
    );
    expect(tester.takeException(), isStateError);
  });

  group('Governance — the executable scans ship with the component', () {
    test('no Material button constructor survives anywhere in the '
        'foundation', () {
      final raw = RegExp(
        r'\b(ElevatedButton|FilledButton|OutlinedButton|TextButton)\(',
      );
      final files = Directory('lib/foundation')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        expect(
          raw.hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: only MentoraButton exists — never a raw '
              'Material button',
        );
      }
    });

    test('the components speak roles through the scope — never values, '
        'never the raw sets, never the container', () {
      final files = Directory('lib/foundation/design_kit/components')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'Color(0x',
          'Colors.',
          'Duration(milliseconds',
          'fontSize:',
          'FontWeight.w',
          'tokens/design_tokens.dart',
          'core/di/',
          'foundation_services',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason: '${file.path}: a component never carries $forbidden',
          );
        }
      }
    });
  });
}
