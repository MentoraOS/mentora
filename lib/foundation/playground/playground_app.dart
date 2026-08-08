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
import '../design_kit/components/text/mentora_text.dart';
import '../design_kit/components/text/mentora_text_role.dart';
import '../design_kit/structure/app_bar/mentora_app_bar.dart';
import '../design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import '../design_kit/international/international_engine.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/registry/binding_integrity_engine.dart';
import '../design_kit/registry/semantic_roles.dart';
import '../design_kit/registry/token_engines.dart';
import '../design_kit/registry/token_provider.dart';
import '../design_kit/registry/token_registry.dart';
import '../design_kit/responsive/responsive_engine.dart';
import '../design_kit/theme/theme_engine.dart';
import '../design_kit/theme/theme_resolver.dart';
import '../design_kit/tokens/surface_elevation_tokens.dart';
import '../localization/localization_engine.dart';
import '../localization/mentora_strings.dart';
import 'playground_controller.dart';
import 'playground_galleries.dart';
import 'playground_labels.dart';
import 'playground_panels.dart';

/// The internal Design Kit laboratory. Development only — the entry
/// point guards against release. It exercises the REAL engines from
/// the REAL bootstrap: nothing is duplicated, nothing is simulated.
final class PlaygroundApp extends StatefulWidget {
  final FoundationServices services;

  const PlaygroundApp({super.key, required this.services});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

final class _PlaygroundAppState extends State<PlaygroundApp> {
  final PlaygroundController _controller = PlaygroundController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = widget.services.get<AppearanceEngine>();
    final themeEngine = widget.services.get<ThemeEngine>();
    return ListenableBuilder(
      listenable: Listenable.merge([appearance, _controller]),
      builder: (context, _) {
        final state = appearance.state;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (_) => playgroundTitle,
          themeMode: themeEngine.resolveMode(state),
          theme: themeEngine.lightTheme(state),
          darkTheme: themeEngine.darkTheme(state),
          locale: _controller.locale,
          supportedLocales: LocalizationEngine.supportedLocales,
          localizationsDelegates: const [
            MentoraStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final accessibility = widget.services.get<AccessibilityEngine>();
            // The laboratory consumes the components through the same
            // official channel as the production app.
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
                colors: widget.services.get<ColorTokenEngine>(),
                typography: widget.services.get<TypographyTokenEngine>(),
                spacing: widget.services.get<SpacingTokenEngine>(),
                surfaces: widget.services.get<SurfaceTokenEngine>(),
                elevation: widget.services
                    .get<ElevationTokenEngine<ElevationExpression>>(),
                motion: widget.services.get<MotionEngine>(),
                accessibility: accessibility,
                appearance: state,
                variant: variant,
                // The contextual layers live above the application
                // and below nothing: installed once, never pushed.
                child: MentoraDialogHost(
                  service: widget.services.get<MentoraDialogService>(),
                  child: MentoraBottomSheetHost(
                    service: widget.services.get<MentoraBottomSheetService>(),
                    child: MentoraSnackbarHost(
                      service: widget.services.get<MentoraSnackbarService>(),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
          home: _PlaygroundShell(
            services: widget.services,
            controller: _controller,
          ),
        );
      },
    );
  }
}

final class _PlaygroundShell extends StatelessWidget {
  final FoundationServices services;
  final PlaygroundController controller;

  const _PlaygroundShell({required this.services, required this.controller});

  @override
  Widget build(BuildContext context) {
    final appearance = services.get<AppearanceEngine>();
    final state = appearance.state;
    final international = services.get<InternationalEngine>();
    final variant = const ThemeResolver().resolve(
      theme: state.theme,
      contrast: state.contrast,
      platformBrightness: MediaQuery.platformBrightnessOf(context),
    );
    final registry = services.get<DesignTokenRegistry>();
    final provider = services.get<DesignTokenProvider>();
    final report = const BindingIntegrityEngine().report(
      registry: registry,
      provider: provider,
    );
    final spacing = services.get<SpacingTokenEngine>();
    // Spacing through the relation, never a distance.
    final pad = spacing.spaceOf(SpacingRelation.separationDistincte);

    return Directionality(
      textDirection: international.directionFor(controller.locale),
      // The laboratory is a page like every other: the official
      // container assembles it, and the framework one is never used.
      child: MentoraPageScaffold(
        semanticLabel: playgroundTitle,
        place: const MentoraAppBar(title: playgroundTitle),
        // A laboratory shows everything: no lazy building — every
        // gallery is always mounted and verifiable.
        content: SingleChildScrollView(
          key: const Key('playground-scroll'),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Controls(appearance: appearance, controller: controller),
              TokenCoveragePanel(report: report),
              BindingIntegrityPanel(
                report: report,
                unknownTokens: 0,
                missingBindings: report.orphanTokens.length,
              ),
              RuntimeVerificationPanel(registry: registry, provider: provider),
              ThemeInspectorPanel(
                themeEngine: services.get<ThemeEngine>(),
                variant: variant,
              ),
              ColorGallery(
                colors: services.get<ColorTokenEngine>(),
                variant: variant,
              ),
              const TextGallery(),
              SpacingGallery(spacing: spacing),
              SurfaceGallery(
                surfaces: services.get<SurfaceTokenEngine>(),
                spacing: spacing,
                variant: variant,
              ),
              ElevationGallery(
                elevation: services
                    .get<ElevationTokenEngine<ElevationExpression>>(),
                variant: variant,
              ),
              MotionPreviewPanel(
                motion: services.get<MotionEngine>(),
                appearance: state,
                replayTick: controller.motionReplays,
                onReplay: controller.replayMotion,
              ),
              const ButtonGallery(),
              const CardGallery(),
              const InputGallery(),
              DialogGallery(
                service: services.get<MentoraDialogService>(),
              ),
              BottomSheetGallery(
                service: services.get<MentoraBottomSheetService>(),
              ),
              SnackbarGallery(
                service: services.get<MentoraSnackbarService>(),
              ),
              const BadgeGallery(),
              const AvatarGallery(),
              const ListTileGallery(),
              const NarrowAdaptationGallery(),
              const AppBarGallery(),
              const NavigationRailGallery(),
              const TabsGallery(),
              const SearchBarGallery(),
              const NavigationDrawerGallery(),
              const BottomNavigationGallery(),
              const MasterDetailGallery(),
              const SplitViewGallery(),
              const WorkspaceGallery(),
              const WorkspaceLayoutGallery(),
              const ContentLayoutGallery(),
              const SectionLayoutGallery(),
              const ListLayoutGallery(),
              const GridLayoutGallery(),
              const TabbedContentLayoutGallery(),
              const FormLayoutGallery(),
              const DetailLayoutGallery(),
              const FeedLayoutGallery(),
              const WizardLayoutGallery(),
              const DashboardLayoutGallery(),
              const NavigationLayoutGallery(),
              const SplitWorkspaceLayoutGallery(),
              const MasterDetailLayoutGallery(),
              const PageScaffoldGallery(),
              ResponsiveGallery(responsive: services.get<ResponsiveEngine>()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle rows: appearance and locale — every switch drives the real
/// engines; the render updates immediately.
final class _Controls extends StatelessWidget {
  final AppearanceEngine appearance;
  final PlaygroundController controller;

  const _Controls({required this.appearance, required this.controller});

  @override
  Widget build(BuildContext context) {
    final state = appearance.state;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<ThemePreference>(
          key: const Key('toggle-theme'),
          segments: [
            for (final preference in ThemePreference.values)
              ButtonSegment(
                value: preference,
                label: MentoraText(
                  preference.name,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {state.theme},
          onSelectionChanged: (selection) =>
              appearance.updateTheme(selection.single),
        ),
        SegmentedButton<ContrastPreference>(
          key: const Key('toggle-contrast'),
          segments: [
            for (final preference in ContrastPreference.values)
              ButtonSegment(
                value: preference,
                label: MentoraText(
                  preference.name,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {state.contrast},
          onSelectionChanged: (selection) =>
              appearance.updateContrast(selection.single),
        ),
        SegmentedButton<FontScalePreference>(
          key: const Key('toggle-font-scale'),
          segments: [
            for (final preference in FontScalePreference.values)
              ButtonSegment(
                value: preference,
                label: MentoraText(
                  preference.name,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {state.fontScale},
          onSelectionChanged: (selection) =>
              appearance.updateFontScale(selection.single),
        ),
        SegmentedButton<MotionPreference>(
          key: const Key('toggle-motion'),
          segments: [
            for (final preference in MotionPreference.values)
              ButtonSegment(
                value: preference,
                label: MentoraText(
                  preference.name,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {state.motion},
          onSelectionChanged: (selection) =>
              appearance.updateMotion(selection.single),
        ),
        SegmentedButton<ReadingComfortPreference>(
          key: const Key('toggle-reading-comfort'),
          segments: [
            for (final preference in ReadingComfortPreference.values)
              ButtonSegment(
                value: preference,
                label: MentoraText(
                  preference.name,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {state.readingComfort},
          onSelectionChanged: (selection) =>
              appearance.updateReadingComfort(selection.single),
        ),
        SegmentedButton<Locale>(
          key: const Key('toggle-locale'),
          segments: [
            for (final locale in const [
              Locale('fr'),
              Locale('en'),
              Locale('ar'),
            ])
              ButtonSegment(
                value: locale,
                label: MentoraText(
                  locale.languageCode,
                  role: MentoraTextRole.caption,
                ),
              ),
          ],
          selected: {controller.locale},
          onSelectionChanged: (selection) =>
              controller.selectLocale(selection.single),
        ),
      ],
    );
  }
}
