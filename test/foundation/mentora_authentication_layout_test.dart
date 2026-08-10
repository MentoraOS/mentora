import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/authentication_layout/mentora_authentication_layout.dart';
import 'package:mentora/foundation/design_kit/layout/feed_layout/mentora_feed_layout.dart';
import 'package:mentora/foundation/design_kit/layout/form_layout/mentora_form_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_principal_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// What the application owns — recognisable, already built, and never
/// touched by the layout that organises the page. The words carry the
/// marks of a proof on purpose — an address, a code sent, a secret to
/// enter — so the layout must hand them on without understanding any
/// of them.
Widget _content(String id) => MentoraText(
  'awa@exemple.ml — code envoyé, secret à saisir — $id',
  key: Key('zone-$id'),
  role: MentoraTextRole.body,
);

MentoraLayoutZone _zone(String id, {String? semanticLabel, Widget? content}) =>
    MentoraLayoutZone(
      semanticLabel: semanticLabel ?? 'Région $id',
      content: content ?? _content(id),
    );

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

const List<MentoraPrincipalRegion> _optional = [
  MentoraPrincipalRegion.header,
  MentoraPrincipalRegion.introduction,
  MentoraPrincipalRegion.supportingContent,
  MentoraPrincipalRegion.actions,
  MentoraPrincipalRegion.footer,
];

/// An authentication page built the way a product builds one: the
/// proof of identity is always there — the compiler requires it — and
/// every other region is removable on its own.
MentoraAuthenticationLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  bool complete = true,
  Map<MentoraPrincipalRegion, MentoraLayoutZone> replacing = const {},
  Set<MentoraPrincipalRegion> without = const {},
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  MentoraLayoutZone? zoneOf(MentoraPrincipalRegion region) {
    if (replacing.containsKey(region)) return replacing[region];
    if (without.contains(region)) return null;
    return complete ? _zone(region.name) : null;
  }

  return MentoraAuthenticationLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    credentials:
        replacing[MentoraPrincipalRegion.principal] ??
        _zone(MentoraPrincipalRegion.principal.name),
    header: zoneOf(MentoraPrincipalRegion.header),
    introduction: zoneOf(MentoraPrincipalRegion.introduction),
    supportingContent: zoneOf(MentoraPrincipalRegion.supportingContent),
    actions: zoneOf(MentoraPrincipalRegion.actions),
    footer: zoneOf(MentoraPrincipalRegion.footer),
  );
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget layout, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
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
        elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
        motion: services.get<MotionEngine>(),
        accessibility: services.get<AccessibilityEngine>(),
        appearance: appearance,
        variant: variant,
        child: Directionality(textDirection: direction, child: layout),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _regionOf(MentoraPrincipalRegion region) =>
    find.byKey(Key('content-region-${region.name}'));

void main() {
  group('MentoraAuthenticationLayout — the page where a person proves '
      'who they are', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the principal foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraZonedLayout<MentoraPrincipalRegion>>());
      expect(_layout(), isA<MentoraPrincipalLayout>());
      expect(_layout().kind, MentoraLayoutKind.authentication);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-authentication')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('credentials is a pure alias over the one matter: the very '
        'zone given is the very zone held, and there is no second '
        'field anywhere', () {
      final proof = _zone('principal');
      final layout = _layout(
        replacing: {MentoraPrincipalRegion.principal: proof},
      );

      expect(identical(layout.credentials, proof), isTrue);
      expect(identical(layout.credentials, layout.principal), isTrue);
      expect(
        identical(layout.zones[MentoraPrincipalRegion.principal], proof),
        isTrue,
      );
    });

    test('it is the third pure consumer of the principal foundation: '
        'form, feed and authentication speak the very same machinery — '
        'each with its own word over the one holder', () {
      final matter = _zone('principal');
      final form = MentoraFormLayout(
        frame: _frame,
        pageSemanticLabel: 'Page courante',
        form: matter,
      );
      final feed = MentoraFeedLayout(
        frame: _frame,
        pageSemanticLabel: 'Page courante',
        feed: matter,
      );
      final authentication = _layout(
        replacing: {MentoraPrincipalRegion.principal: matter},
      );

      for (final shape in [form, feed, authentication]) {
        expect(shape, isA<MentoraPrincipalLayout>());
        expect(identical(shape.principal, matter), isTrue);
      }
      expect(identical(form.form, matter), isTrue);
      expect(identical(feed.feed, matter), isTrue);
      expect(identical(authentication.credentials, matter), isTrue);
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final region in MentoraPrincipalRegion.values) {
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    testWidgets('the official order is the order read, and it is the '
        'vocabulary itself — no region was added, none was renamed', (
      tester,
    ) async {
      await _pump(tester, _layout());

      var previous = tester
          .getRect(_regionOf(MentoraPrincipalRegion.header))
          .top;
      for (final region in MentoraPrincipalRegion.values.skip(1)) {
        final top = tester.getRect(_regionOf(region)).top;
        expect(top, greaterThan(previous), reason: region.name);
        previous = top;
      }
      // The vocabulary is closed, and it is the order — the six words
      // of every page built around one matter, and not a seventh.
      expect(
        MentoraPrincipalRegion.values.map((region) => region.name).toList(),
        [
          'header',
          'introduction',
          'principal',
          'supportingContent',
          'actions',
          'footer',
        ],
      );
    });

    testWidgets('the identity of a region is the official region: a '
        'product never names one', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-region-principal')), findsOneWidget);
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
      expect(find.byKey(const Key('content-region-credentials')), findsNothing);
    });

    testWidgets('the content of every region is handed on strictly '
        'intact — the marks of a proof it carries are never read', (
      tester,
    ) async {
      await _pump(tester, _layout());

      // An address, a code sent, a secret to enter: what was written
      // is exactly what stands — nothing recognised, nothing examined,
      // nothing accepted or refused.
      for (final region in MentoraPrincipalRegion.values) {
        expect(
          find.text(
            'awa@exemple.ml — code envoyé, secret à saisir — ${region.name}',
          ),
          findsOneWidget,
          reason: region.name,
        );
        expect(
          tester.getTopLeft(find.byKey(Key('zone-${region.name}'))),
          tester.getTopLeft(_regionOf(region)),
          reason: region.name,
        );
      }
    });

    testWidgets('the proof alone is enough: a page built around one '
        'matter stands from the matter on', (tester) async {
      await _pump(tester, _layout(complete: false));

      expect(tester.takeException(), isNull);
      expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
      for (final region in _optional) {
        expect(_regionOf(region), findsNothing, reason: region.name);
      }
      // And what remains starts at the very edge of the page.
      expect(
        tester.getTopLeft(_regionOf(MentoraPrincipalRegion.principal)),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('every other region is optional: what was not given is '
        'not there at all', (tester) async {
      for (final absent in _optional) {
        await _pump(tester, _layout(without: {absent}));

        expect(tester.takeException(), isNull, reason: absent.name);
        expect(_regionOf(absent), findsNothing, reason: absent.name);
        for (final region in MentoraPrincipalRegion.values) {
          if (region == absent) continue;
          expect(_regionOf(region), findsOneWidget, reason: region.name);
        }
      }
    });

    testWidgets('the components stay the owners of what a region is '
        'made of', (tester) async {
      await _pump(
        tester,
        _layout(
          replacing: {
            MentoraPrincipalRegion.principal: _zone(
              'principal',
              content: const MentoraCard(
                key: Key('zone-principal'),
                variant: MentoraCardVariant.surface,
                child: MentoraText(
                  'Ce que vous présentez pour être reconnu.',
                  role: MentoraTextRole.body,
                ),
              ),
            ),
          },
        ),
      );

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(
        find.text('Ce que vous présentez pour être reconnu.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries any proof: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['première preuve', 'seconde preuve']) {
        await _pump(
          tester,
          _layout(
            replacing: {
              MentoraPrincipalRegion.principal: _zone(
                'principal',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            },
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('each region is announced exactly once, and only the '
        'regions announce', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final region in MentoraPrincipalRegion.values) {
        expect(
          find.bySemanticsLabel('Région ${region.name}'),
          findsOneWidget,
          reason: region.name,
        );
      }
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraPrincipalRegion.values) {
        expect(
          find.descendant(
            of: _regionOf(region),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsOneWidget,
          reason: region.name,
        );
      }
    });

    testWidgets('the zones of the page it asks for stay the zones of '
        'the components that own them', (tester) async {
      await _pump(
        tester,
        _layout(
          place: const MentoraAppBar(title: 'Page courante'),
          acts: [
            MentoraButton(
              label: 'Continuer',
              onPressed: () {},
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );

      expect(find.byType(MentoraAppBar), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an authentication page without a contract refuses to '
        'build — fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1..6. A region without a name is not a landmark — each of the
      // six, through the one refusal the zoned foundation owns.
      for (final region in MentoraPrincipalRegion.values) {
        await refuses(
          _layout(replacing: {region: _zone(region.name, semanticLabel: '')}),
        );
      }
      // 7. A page announces itself.
      await refuses(_layout(pageSemanticLabel: ''));
      // 8. The working context announces itself.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
          ),
        ),
      );
      // 9. Outside the Design Kit nothing is resolved.
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
      // 10. A layout is a whole screen: it never carries a second one.
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(
          replacing: {
            MentoraPrincipalRegion.principal: _zone(
              'principal',
              content: _layout(),
            ),
          },
        ),
      );
      FlutterError.onError = reporter;
      expect(refusals.whereType<StateError>(), isNotEmpty);
      expect(
        refusals.whereType<StateError>().first.message,
        contains('never placed inside another'),
      );
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(complete: false),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
      }
    });

    testWidgets('it holds at every reading comfort', (tester) async {
      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _layout(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull, reason: comfort.name);
      }
    });

    testWidgets('it holds in both reading directions, and the proof '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_regionOf(MentoraPrincipalRegion.principal)).width,
          tester.getRect(find.byType(MentoraPageScaffold)).width,
          reason: direction.name,
        );
      }
    });

    testWidgets('every transition still comes from the Motion Engine: '
        'None silences it', (tester) async {
      await _pump(
        tester,
        _layout(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );

      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('workspace-surface')),
            )
            .duration,
        Duration.zero,
      );
    });
  });

  group('Governance — the executable scans ship with the layout', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    /// What a file COMMITS.
    ///
    /// A scan opposes code, and a comment is not code: documenting a
    /// prohibition has never been committing it.
    String codeOf(File file) => file
        .readAsLinesSync()
        .map((line) {
          final comment = line.indexOf('//');
          return comment == -1 ? line : line.substring(0, comment);
        })
        .join('\n');

    /// The shape AND the foundations it is built on: the machinery
    /// lives there, so the scans follow it.
    Iterable<File> authenticationFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/authentication_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_principal_layout.dart',
      ),
      File(
        'lib/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = authenticationFiles().toList();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: $because ${entry.key}',
          );
        }
      }
    }

    test('an authentication layout knows no identity machinery: no '
        'secret, no code, no one who signs in', () {
      // Structural, never lexical: a concept USED carries a
      // constructor, a member or a named argument behind it — the
      // prose may name what the code may not carry.
      refuse({
        'a piece of a proof': RegExp(
          r'(?<![A-Za-z])(Password|Email|Phone|Otp|OTP|Pin|PIN|Token|'
          r'Session|Cookie|Secret|Passcode|Passkey)(?![a-z])',
        ),
        'an act of a proof': RegExp(
          r'(?<![A-Za-z])(password|email|phone|otp|pin|token|session|'
          r'cookie|secret|login|logout|signIn|signUp|signOut|register|'
          r'authenticate\w*)\s*[:.(=]',
        ),
        'someone': RegExp(
          r'(?<![A-Za-z])(User|Identity|Principal\w+|Subject|Claim)'
          r'(?![a-z])',
        ),
        'a factor or a biometric': RegExp(
          r'(?<![A-Za-z])(Mfa|MFA|TwoFactor|Biometric|FaceId|FaceID|'
          r'TouchId|TouchID|Fingerprint)(?![a-z])',
        ),
      }, 'it never carries');
    });

    test('an authentication layout knows no protocol, no security API '
        'and no network', () {
      refuse({
        'a provider or a protocol': RegExp(
          r'(?<![A-Za-z])(CredentialProvider|OAuth|OpenId|OpenID|Saml|'
          r'SAML|Jwt|JWT|Oidc|Sso|SSO|Kerberos|Ldap)(?![a-z])',
        ),
        'a security API': RegExp(
          r'(?<![A-Za-z])(Encryption|Encrypt\w*|Decrypt\w*|Hash|Hmac|'
          r'Sha\d+|Md5|Aes|Rsa|Crypto\w*|Cipher|Salt|Nonce)(?![a-z])',
        ),
        'an identity backend': RegExp(
          r'(?<![A-Za-z])(FirebaseAuth|Firebase|GoogleSignIn|'
          r'AppleSignIn|Auth0|Cognito|Keycloak)(?![a-z])',
        ),
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Dio|Socket|'
          r'WebSocket|Grpc)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('an authentication layout knows no logic, no data and no '
        'state', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand)\s*[(.]',
        ),
        'an arithmetic': RegExp(r'(~/|\.ceil\(|\.floor\(|\.round\()'),
        'a validation of its own': RegExp(
          r'(?<![A-Za-z])(validate\w*|Validator|isValid|matches)\s*[:.(=<]',
        ),
        'a model': RegExp(
          r'(?<![A-Za-z])(Wallet|Expert|Course|Consultation|Invoice|'
          r'Business|Account|Profile|Entity|Model|Repository)(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Provider|Bloc|Cubit|Riverpod|ChangeNotifier|'
          r'StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a state of the proof': RegExp(
          r'(?<![A-Za-z])(loading|error|success|offline|processing|'
          r'waiting|refreshing|authenticated|unauthenticated|expired)'
          r'(?![A-Za-z])',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier)'
          r'(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
        'a serialization': RegExp(r'(?<![A-Za-z])(fromJson|toJson)\s*[(<]'),
      }, 'it never carries');
    });

    test('an authentication layout builds no framework widget, '
        'measures nothing and navigates nowhere', () {
      refuse({
        'a structure of the framework': RegExp(
          r'(?<![A-Za-z])(Scaffold|AppBar|Drawer|NavigationBar|'
          r'NavigationRail|TabBar|Form|FormField|TextField|TextEditing\w*)'
          r'\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'CustomScrollView|ListView|GridView|Sliver\w*|Wrap|Flow)'
          r'\s*[(.<]',
        ),
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer)'
          r'\s*[(.<]',
        ),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)\s*[(.<]',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      }, 'it never carries');
    });

    test('one authentication layout exists in the whole product, it '
        'extends the principal foundation, and it declares nothing '
        'else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraAuthenticationLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/authentication_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(
          r'extends\s+MentoraPrincipalLayout(?![A-Za-z])',
        ).hasMatch(source),
        isTrue,
      );
      // It owns no region, no order, no identity, no surface and no
      // refusal: it owns its official kind, and the word it calls its
      // matter by — which is an alias, never a second field.
      for (final owned in const [
        r'Widget\s+build\(',
        r'surfaceOf\(',
        r'void\s+verify\w*\(',
        r'throw\s',
        r'get\s+zones(?![A-Za-z])',
        r'get\s+vocabulary(?![A-Za-z])',
        r'final\s+MentoraLayoutZone',
        r'enum\s+\w+',
      ]) {
        expect(RegExp(owned).hasMatch(source), isFalse, reason: owned);
      }
      // The alias is a getter over the one matter, and the matter is
      // passed to the foundation as the matter.
      expect(
        RegExp(r'super\(principal:\s*credentials\)').hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'MentoraLayoutZone\s+get\s+credentials\s*=>\s*principal;',
        ).hasMatch(source),
        isTrue,
      );
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
        'MentoraButton(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
      // It reaches exactly the foundation, and nothing else: the three
      // files a pure consumer needs, and not one more.
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .map((line) => line.trim())
          .toList();
      expect(imports, [
        "import '../foundation/mentora_layout_kind.dart';",
        "import '../foundation/mentora_layout_style.dart';",
        "import '../foundation/mentora_principal_layout.dart';",
      ]);
    });

    test('the principal foundation has exactly three consumers — form, '
        'feed and authentication — each with its own word over the one '
        'holder, and no second vocabulary anywhere', () {
      final shapes = <String, String>{};
      for (final file in dartFilesOf('lib')) {
        final source = codeOf(file);
        if (!RegExp(
          r'extends\s+MentoraPrincipalLayout(?![A-Za-z])',
        ).hasMatch(source)) {
          continue;
        }
        final path = file.path.replaceAll(r'\', '/');
        // The alias is a getter over the one matter, never a field of
        // its own, and it is passed to the foundation as the matter.
        final alias = RegExp(
          r'MentoraLayoutZone\s+get\s+(\w+)\s*=>\s*principal;',
        ).firstMatch(source);
        expect(alias, isNotNull, reason: path);
        expect(
          RegExp(r'super\(principal:\s*\w+\)').hasMatch(source),
          isTrue,
          reason: path,
        );
        shapes[path.split('/').last] = alias!.group(1)!;
      }
      expect(shapes, {
        'mentora_form_layout.dart': 'form',
        'mentora_feed_layout.dart': 'feed',
        'mentora_authentication_layout.dart': 'credentials',
      });

      // The machinery exists once — in the foundation they extend: the
      // six words, the map, and the matter that cannot be absent.
      final foundation = codeOf(
        File(
          'lib/foundation/design_kit/layout/foundation/'
          'mentora_principal_layout.dart',
        ),
      );
      expect(
        RegExp(r'final MentoraLayoutZone principal;').hasMatch(foundation),
        isTrue,
      );
      expect(RegExp(r'required this\.principal').hasMatch(foundation), isTrue);
      expect(
        RegExp(
          r'get\s+vocabulary\s*=>\s*MentoraPrincipalRegion\.values;',
        ).hasMatch(foundation),
        isTrue,
      );
    });
  });
}
