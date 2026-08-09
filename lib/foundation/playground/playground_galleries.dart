import 'package:flutter/material.dart';

import '../design_kit/components/button/mentora_button.dart';
import '../design_kit/components/button/mentora_button_style.dart';
import '../design_kit/components/card/mentora_card.dart';
import '../design_kit/components/card/mentora_card_style.dart';
import '../design_kit/structure/app_bar/mentora_app_bar.dart';
import '../design_kit/structure/bottom_navigation/mentora_bottom_navigation.dart';
import '../design_kit/structure/master_detail/mentora_master_detail.dart';
import '../design_kit/structure/master_detail/mentora_master_detail_style.dart';
import '../design_kit/structure/split_view/mentora_split_view.dart';
import '../design_kit/structure/split_view/mentora_split_view_style.dart';
import '../design_kit/structure/workspace/mentora_workspace.dart';
import '../design_kit/structure/workspace/mentora_workspace_style.dart';
import '../design_kit/layout/analytics_layout/mentora_analytics_layout.dart';
import '../design_kit/layout/catalog_layout/mentora_catalog_layout.dart';
import '../design_kit/layout/content_layout/mentora_content_layout.dart';
import '../design_kit/layout/dashboard_layout/mentora_dashboard_layout.dart';
import '../design_kit/layout/master_detail_layout/mentora_master_detail_layout.dart';
import '../design_kit/navigation/mentora_destination.dart';
import '../design_kit/layout/foundation/mentora_layout_context.dart';
import '../design_kit/layout/foundation/mentora_layout_style.dart';
import '../design_kit/layout/detail_layout/mentora_detail_layout.dart';
import '../design_kit/layout/feed_layout/mentora_feed_layout.dart';
import '../design_kit/layout/form_layout/mentora_form_layout.dart';
import '../design_kit/layout/grid_layout/mentora_grid_layout.dart';
import '../design_kit/layout/tabbed_content_layout/mentora_tabbed_content_layout.dart';
import '../design_kit/layout/wizard_layout/mentora_wizard_layout.dart';
import '../design_kit/layout/list_layout/mentora_list_layout.dart';
import '../design_kit/layout/navigation_layout/mentora_navigation_layout.dart';
import '../design_kit/layout/section_layout/mentora_section_layout.dart';
import '../design_kit/layout/settings_layout/mentora_settings_layout.dart';
import '../design_kit/layout/split_workspace_layout/mentora_split_workspace_layout.dart';
import '../design_kit/layout/workspace_layout/mentora_workspace_layout.dart';
import '../design_kit/tokens/split_view_tokens.dart';
import '../design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import '../design_kit/structure/navigation_drawer/mentora_navigation_drawer.dart';
import '../design_kit/structure/navigation_drawer/mentora_navigation_drawer_style.dart';
import '../design_kit/structure/search_bar/mentora_search_bar.dart';
import '../design_kit/structure/search_bar/mentora_search_bar_style.dart';
import '../design_kit/structure/tabs/mentora_tabs.dart';
import '../design_kit/structure/tabs/mentora_tabs_style.dart';
import '../design_kit/structure/navigation_rail/mentora_navigation_rail.dart';
import '../design_kit/structure/navigation_rail/mentora_navigation_rail_style.dart';
import '../design_kit/structure/app_bar/mentora_app_bar_style.dart';
import '../design_kit/composition/list_tile/mentora_list_tile.dart';
import '../design_kit/composition/list_tile/mentora_list_tile_style.dart';
import '../design_kit/components/avatar/mentora_avatar.dart';
import '../design_kit/components/avatar/mentora_avatar_style.dart';
import '../design_kit/components/badge/mentora_badge.dart';
import '../design_kit/components/badge/mentora_badge_style.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_request.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../design_kit/components/bottom_sheet/mentora_bottom_sheet_style.dart';
import '../design_kit/components/design_kit_scope.dart';
import '../design_kit/components/dialog/mentora_dialog.dart';
import '../design_kit/components/dialog/mentora_dialog_request.dart';
import '../design_kit/components/dialog/mentora_dialog_service.dart';
import '../design_kit/components/dialog/mentora_dialog_style.dart';
import '../design_kit/components/input/mentora_input.dart';
import '../design_kit/components/snackbar/mentora_snackbar.dart';
import '../design_kit/components/snackbar/mentora_snackbar_request.dart';
import '../design_kit/components/snackbar/mentora_snackbar_service.dart';
import '../design_kit/components/snackbar/mentora_snackbar_style.dart';
import '../design_kit/components/input/mentora_input_style.dart';
import '../design_kit/components/input/mentora_input_validator.dart';
import '../design_kit/components/text/mentora_text.dart';
import '../design_kit/components/text/mentora_text_role.dart';
import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/registry/semantic_roles.dart';
import '../design_kit/registry/token_engines.dart';
import '../design_kit/responsive/responsive_engine.dart';
import '../design_kit/theme/theme_variant.dart';
import '../design_kit/tokens/surface_elevation_tokens.dart';
import 'playground_labels.dart';

/// Shared section chrome for every gallery.
final class GallerySection extends StatelessWidget {
  final String title;
  final Widget child;

  const GallerySection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(title, role: MentoraTextRole.subtitle),
        child,
        Divider(color: scope.colors.colorOf(ColorRole.divider, scope.variant)),
      ],
    );
  }
}

/// The 27 color roles — always the role, never a raw color.
final class ColorGallery extends StatelessWidget {
  final ColorTokenEngine colors;
  final ThemeVariantId variant;

  const ColorGallery({super.key, required this.colors, required this.variant});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: colorGalleryTitle,
      child: Wrap(
        children: [
          for (final role in ColorRole.values)
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: Key('color-swatch-${role.name}'),
                    width: kMinInteractiveDimension,
                    height: kMinInteractiveDimension,
                    color: colors.colorOf(role, variant),
                  ),
                  MentoraText(role.name, role: MentoraTextRole.caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The official Typography catalogue — the 27 admitted roles, the four
/// theme variants, the font scales, the reading comfort and both
/// reading directions, rendered by the REAL component. It closes with
/// the component's own documentation, written with itself.
final class TextGallery extends StatelessWidget {
  const TextGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);
    final sample = textGalleryTitle.split('—').first.trim();

    Widget heading(String label) =>
        MentoraText(label, role: MentoraTextRole.label);

    return GallerySection(
      title: textGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The 27 admitted roles, each rendered in its own role.
          for (final role in TypographyRole.values)
            MentoraText(
              role.name,
              key: Key('typography-sample-${role.name}'),
              role: MentoraTextRole.of(role),
            ),
          // The ten official behaviors — named doors onto the roles.
          for (final entry in MentoraTextRole.officialBehaviors.entries)
            MentoraText(
              entry.key,
              key: Key('text-behavior-${entry.key}'),
              role: entry.value,
            ),
          // The four theme variants, including both high contrasts.
          heading(themeInspectorTitle),
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: MentoraText(
                variant.name,
                key: Key('text-variant-${variant.name}'),
                role: MentoraTextRole.body,
              ),
            ),
          // The font scales — applied by the application's scaler, the
          // single authority, exactly as in production.
          for (final scale in FontScalePreference.values)
            Builder(
              builder: (context) {
                final state = scope.appearance.copyWith(fontScale: scale);
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      scope.accessibility.textScaleFor(state),
                    ),
                  ),
                  child: DesignKitScope.deriving(
                    scope,
                    appearance: state,
                    child: MentoraText(
                      scale.name,
                      key: Key('text-scale-${scale.name}'),
                      role: MentoraTextRole.body,
                    ),
                  ),
                );
              },
            ),
          // The reading comfort, served as it is admitted.
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: MentoraText(
                comfort.name,
                key: Key('text-comfort-${comfort.name}'),
                role: MentoraTextRole.body,
              ),
            ),
          // Both directions — no screen ever handles them specially.
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraText(
                sample,
                key: Key('text-direction-${direction.name}'),
                role: MentoraTextRole.body,
              ),
            ),
          const _TextDocumentation(),
        ],
      ),
    );
  }
}

/// The component's living documentation — written with the component
/// itself: what it offers, what it demands, what it refuses.
final class _TextDocumentation extends StatelessWidget {
  const _TextDocumentation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(
          textDocHeading,
          key: const Key('text-doc-heading'),
          role: MentoraTextRole.subtitle,
        ),
        _DocumentationSection(
          title: textDocRolesTitle,
          lines: MentoraTextRole.officialBehaviors.entries
              .map((entry) => '${entry.key} → ${entry.value.role.name}')
              .toList(),
          keyPrefix: 'text-doc-role',
        ),
        const _DocumentationSection(
          title: textDocRulesTitle,
          lines: textDocRules,
          keyPrefix: 'text-doc-rule',
        ),
        const _DocumentationSection(
          title: textDocForbiddenTitle,
          lines: textDocForbidden,
          keyPrefix: 'text-doc-forbidden',
        ),
        const _DocumentationSection(
          title: textDocTokensTitle,
          lines: textDocTokens,
          keyPrefix: 'text-doc-token',
        ),
        const _DocumentationSection(
          title: textDocEnginesTitle,
          lines: textDocEngines,
          keyPrefix: 'text-doc-engine',
        ),
      ],
    );
  }
}

/// The 8 spacing relations — bars sized by the relation, labeled by
/// the relation, never by the value.
final class SpacingGallery extends StatelessWidget {
  final SpacingTokenEngine spacing;

  const SpacingGallery({super.key, required this.spacing});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);
    return GallerySection(
      title: spacingGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final relation in SpacingRelation.values)
            Row(
              children: [
                Container(
                  key: Key('spacing-bar-${relation.name}'),
                  width: spacing.spaceOf(relation) * 4,
                  height: spacing.spaceOf(SpacingRelation.proximiteLiee),
                  color: scope.colors.colorOf(ColorRole.primary, scope.variant),
                ),
                SizedBox(width: spacing.spaceOf(SpacingRelation.proximiteLiee)),
                MentoraText(relation.name, role: MentoraTextRole.caption),
              ],
            ),
        ],
      ),
    );
  }
}

/// The five official surfaces.
final class SurfaceGallery extends StatelessWidget {
  final SurfaceTokenEngine surfaces;
  final SpacingTokenEngine spacing;
  final ThemeVariantId variant;

  const SurfaceGallery({
    super.key,
    required this.surfaces,
    required this.spacing,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: surfaceGalleryTitle,
      child: Wrap(
        children: [
          for (final role in SurfaceRole.values)
            Container(
              key: Key('surface-tile-${role.name}'),
              width: spacing.spaceOf(SpacingRelation.espaceFocus) * 3,
              height: spacing.spaceOf(SpacingRelation.espaceFocus),
              color: surfaces.surfaceOf(role, variant),
              alignment: Alignment.center,
              child: MentoraText(role.name, role: MentoraTextRole.caption),
            ),
        ],
      ),
    );
  }
}

/// The four elevation meanings — properties of meaning, never heights.
final class ElevationGallery extends StatelessWidget {
  final ElevationTokenEngine<ElevationExpression> elevation;
  final ThemeVariantId variant;

  const ElevationGallery({
    super.key,
    required this.elevation,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: elevationGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final meaning in ElevationMeaning.values)
            Builder(
              builder: (context) {
                final expression = elevation.expressionOf(meaning, variant);
                return MentoraText(
                  '${meaning.name} — blocks: ${expression.blocksBelow}, '
                  'dims: ${expression.dimsScene}, '
                  'exclusive: ${expression.isExclusive}',
                  key: Key('elevation-${meaning.name}'),
                  role: MentoraTextRole.caption,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// The official Buttons catalogue — every variant, every size and the
/// application phases of the REAL component.
final class ButtonGallery extends StatefulWidget {
  const ButtonGallery({super.key});

  @override
  State<ButtonGallery> createState() => _ButtonGalleryState();
}

final class _ButtonGalleryState extends State<ButtonGallery> {
  final MentoraButtonController _loading = MentoraButtonController();
  final MentoraButtonController _success = MentoraButtonController();
  final MentoraButtonController _error = MentoraButtonController();

  @override
  void initState() {
    super.initState();
    _loading.beginLoading();
    _success.showSuccess();
    _error.showError();
  }

  @override
  void dispose() {
    _loading.dispose();
    _success.dispose();
    _error.dispose();
    super.dispose();
  }

  void _noop() {}

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: buttonGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraButtonVariant.values)
            MentoraButton(
              key: Key('button-variant-${variant.name}'),
              label: variant.name,
              onPressed: _noop,
              variant: variant,
            ),
          for (final size in MentoraButtonSize.values)
            MentoraButton(
              key: Key('button-size-${size.name}'),
              label: size.name,
              onPressed: _noop,
              size: size,
            ),
          const MentoraButton(
            key: Key('button-state-disabled'),
            label: 'disabled',
            onPressed: null,
          ),
          MentoraButton(
            key: const Key('button-state-loading'),
            label: 'loading',
            onPressed: _noop,
            controller: _loading,
          ),
          MentoraButton(
            key: const Key('button-state-success'),
            label: 'success',
            onPressed: _noop,
            controller: _success,
          ),
          MentoraButton(
            key: const Key('button-state-error'),
            label: 'error',
            onPressed: _noop,
            controller: _error,
          ),
        ],
      ),
    );
  }
}

/// The official Cards catalogue — every variant and every state of the
/// REAL component. The laboratory duplicates nothing: what is shown
/// here is exactly what the screens will use.
///
/// The interaction states (pressed, focused, hovered) are shown as
/// live cards: the engineer presses, tabs and hovers them to verify
/// the expression — a catalogue of claims would prove nothing.
final class CardGallery extends StatefulWidget {
  const CardGallery({super.key});

  @override
  State<CardGallery> createState() => _CardGalleryState();
}

final class _CardGalleryState extends State<CardGallery> {
  final MentoraCardController _loading = MentoraCardController();
  final MentoraCardController _error = MentoraCardController();

  @override
  void initState() {
    super.initState();
    _loading.beginLoading();
    _error.showError();
  }

  @override
  void dispose() {
    _loading.dispose();
    _error.dispose();
    super.dispose();
  }

  /// The act served to every inviting sample of the catalogue: the
  /// laboratory observes the expression, it performs no business.
  void _noop() {}

  @override
  Widget build(BuildContext context) {
    Widget caption(String text) =>
        MentoraText(text, role: MentoraTextRole.caption);

    return GallerySection(
      title: cardGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraCardVariant.values)
            MentoraCard(
              key: Key('card-variant-${variant.name}'),
              variant: variant,
              onTap: variant == MentoraCardVariant.interactive ? _noop : null,
              child: caption(variant.name),
            ),
          // The states, on the official interactive variant.
          MentoraCard(
            key: const Key('card-state-idle'),
            child: caption(MentoraCardState.idle.name),
          ),
          MentoraCard(
            key: const Key('card-state-pressed'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.pressed.name),
          ),
          MentoraCard(
            key: const Key('card-state-focused'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.focused.name),
          ),
          MentoraCard(
            key: const Key('card-state-hovered'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.hovered.name),
          ),
          MentoraCard(
            key: const Key('card-state-selected'),
            variant: MentoraCardVariant.selected,
            child: caption(MentoraCardState.selected.name),
          ),
          MentoraCard(
            key: const Key('card-state-disabled'),
            variant: MentoraCardVariant.outlined,
            enabled: false,
            child: caption(MentoraCardState.disabled.name),
          ),
          MentoraCard(
            key: const Key('card-state-loading'),
            variant: MentoraCardVariant.outlined,
            controller: _loading,
            child: caption(MentoraCardState.loading.name),
          ),
          MentoraCard(
            key: const Key('card-state-error'),
            variant: MentoraCardVariant.outlined,
            controller: _error,
            child: caption(MentoraCardState.error.name),
          ),
        ],
      ),
    );
  }
}

/// The official Inputs catalogue — every chrome, every availability,
/// every size and every state of the REAL component, plus its living
/// documentation, built only with Mentora components.
final class InputGallery extends StatefulWidget {
  const InputGallery({super.key});

  @override
  State<InputGallery> createState() => _InputGalleryState();
}

/// A laboratory judge: it publishes a verdict without carrying any
/// business rule — an empty value is simply not yet a value.
final class _LaboratoryJudge implements MentoraInputValidator {
  final String message;

  const _LaboratoryJudge(this.message);

  @override
  MentoraValidation validate(String value) {
    return value.isEmpty
        ? MentoraValidation.invalid(message: message)
        : const MentoraValidation.valid();
  }
}

final class _InputGalleryState extends State<InputGallery> {
  final MentoraInputController _loading = MentoraInputController();
  final MentoraInputController _success = MentoraInputController();
  final MentoraInputController _error = MentoraInputController();
  final MentoraInputController _invalid = MentoraInputController();
  final MentoraInputController _valid = MentoraInputController();

  @override
  void initState() {
    super.initState();
    _loading.beginLoading();
    _success.showSuccess();
    _error.showError();
    _invalid.publishValidation(
      const MentoraValidation.invalid(message: 'invalid'),
    );
    _valid.publishValidation(const MentoraValidation.valid(message: 'valid'));
  }

  @override
  void dispose() {
    _loading.dispose();
    _success.dispose();
    _error.dispose();
    _invalid.dispose();
    _valid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: inputGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraInputVariant.values)
            MentoraInput(
              key: Key('input-variant-${variant.name}'),
              variant: variant,
              label: variant.name,
              placeholder: variant.name,
              secureRevealLabel: variant == MentoraInputVariant.secure
                  ? 'reveal'
                  : null,
            ),
          for (final availability in MentoraInputAvailability.values)
            MentoraInput(
              key: Key('input-availability-${availability.name}'),
              availability: availability,
              label: availability.name,
            ),
          for (final size in MentoraInputSize.values)
            MentoraInput(
              key: Key('input-size-${size.name}'),
              size: size,
              label: size.name,
            ),
          // The announced phases and the published verdicts.
          MentoraInput(
            key: const Key('input-state-loading'),
            controller: _loading,
            label: MentoraInputState.loading.name,
          ),
          MentoraInput(
            key: const Key('input-state-success'),
            controller: _success,
            label: MentoraInputState.success.name,
          ),
          MentoraInput(
            key: const Key('input-state-error'),
            controller: _error,
            label: MentoraInputState.error.name,
          ),
          MentoraInput(
            key: const Key('input-state-invalid'),
            controller: _invalid,
            label: MentoraInputState.invalid.name,
          ),
          MentoraInput(
            key: const Key('input-state-valid'),
            controller: _valid,
            label: MentoraInputState.valid.name,
          ),
          // A live judge: type, and the verdict follows the value.
          MentoraInput(
            key: const Key('input-state-judged'),
            label: 'judged',
            validator: const _LaboratoryJudge('a value is expected'),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: MentoraInput(
                key: Key('input-theme-${variant.name}'),
                label: variant.name,
              ),
            ),
          // The font scales, applied by the application's scaler.
          for (final scale in FontScalePreference.values)
            Builder(
              builder: (context) {
                final state = scope.appearance.copyWith(fontScale: scale);
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      scope.accessibility.textScaleFor(state),
                    ),
                  ),
                  child: DesignKitScope.deriving(
                    scope,
                    appearance: state,
                    child: MentoraInput(
                      key: Key('input-scale-${scale.name}'),
                      label: scale.name,
                    ),
                  ),
                );
              },
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: MentoraInput(
                key: Key('input-comfort-${comfort.name}'),
                label: comfort.name,
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraInput(
                key: Key('input-direction-${direction.name}'),
                label: direction.name,
              ),
            ),
          const _InputDocumentation(),
        ],
      ),
    );
  }
}

/// The Input's living documentation — architecture, responsibilities,
/// Tokens, Engines, prohibitions and scans, written only with Mentora
/// components.
final class _InputDocumentation extends StatelessWidget {
  const _InputDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('input-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(inputDocHeading, role: MentoraTextRole.subtitle),
          _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: inputDocArchitecture,
            keyPrefix: 'input-doc-architecture',
          ),
          _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: inputDocResponsibilities,
            keyPrefix: 'input-doc-responsibility',
          ),
          _DocumentationSection(
            title: textDocTokensTitle,
            lines: inputDocTokens,
            keyPrefix: 'input-doc-token',
          ),
          _DocumentationSection(
            title: textDocEnginesTitle,
            lines: inputDocEngines,
            keyPrefix: 'input-doc-engine',
          ),
          _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: inputDocForbidden,
            keyPrefix: 'input-doc-forbidden',
          ),
          _DocumentationSection(
            title: inputDocScansTitle,
            lines: inputDocScans,
            keyPrefix: 'input-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// One documented chapter — the shared shape of every living
/// documentation of the catalogue.
final class _DocumentationSection extends StatelessWidget {
  final String title;
  final List<String> lines;
  final String keyPrefix;

  const _DocumentationSection({
    required this.title,
    required this.lines,
    required this.keyPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(title, role: MentoraTextRole.label),
        for (final (index, line) in lines.indexed)
          MentoraText(
            line,
            key: Key('$keyPrefix-$index'),
            role: MentoraTextRole.caption,
          ),
      ],
    );
  }
}

/// The official Dialogs catalogue — every variant and every state of
/// the REAL component, shown in place (the exchanges of the laboratory
/// never take the screen hostage), plus the live service and its
/// living documentation.
final class DialogGallery extends StatefulWidget {
  /// The official service of the laboratory — the same one the host
  /// listens to: the catalogue duplicates nothing.
  final MentoraDialogService service;

  const DialogGallery({super.key, required this.service});

  @override
  State<DialogGallery> createState() => _DialogGalleryState();
}

final class _DialogGalleryState extends State<DialogGallery> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onExchangeChanged);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onExchangeChanged);
    super.dispose();
  }

  void _onExchangeChanged() {
    if (mounted) setState(() {});
  }

  /// Every catalogued demand honors the contracts of the request: a
  /// critical exchange states its consequence, an exchange that asks
  /// offers two ways out.
  static MentoraDialogRequest demandOf(MentoraDialogVariant variant) {
    final asks =
        variant == MentoraDialogVariant.confirmation ||
        variant == MentoraDialogVariant.decision ||
        variant == MentoraDialogVariant.critical;
    return MentoraDialogRequest(
      variant: variant,
      title: variant.name,
      message: 'What this exchange holds.',
      consequence: variant == MentoraDialogVariant.critical
          ? 'What it will cost.'
          : null,
      actions: asks
          ? const [
              MentoraDialogAction(id: 'step-back', label: 'step back'),
              MentoraDialogAction(
                id: 'proceed',
                label: 'proceed',
                intent: MentoraDialogActionIntent.recommended,
              ),
            ]
          : const [
              MentoraDialogAction(
                id: 'understood',
                label: 'understood',
                intent: MentoraDialogActionIntent.recommended,
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: dialogGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Every variant, in place: the catalogue shows the layer
          // itself, not a promise of it.
          for (final variant in MentoraDialogVariant.values)
            MentoraDialog(
              key: Key('dialog-variant-${variant.name}'),
              request: demandOf(variant),
              state: MentoraDialogState.opened,
              onAction: (_) {},
            ),
          // Every state, on the confirmation exchange.
          for (final state in MentoraDialogState.values)
            MentoraDialog(
              key: Key('dialog-state-${state.name}'),
              request: demandOf(MentoraDialogVariant.confirmation),
              state: state,
              onAction: (_) {},
            ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              DesignKitScope.of(context),
              variant: variant,
              child: MentoraDialog(
                key: Key('dialog-theme-${variant.name}'),
                request: demandOf(MentoraDialogVariant.information),
                state: MentoraDialogState.opened,
                onAction: (_) {},
              ),
            ),
          // Both reading directions.
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraDialog(
                key: Key('dialog-direction-${direction.name}'),
                request: demandOf(MentoraDialogVariant.information),
                state: MentoraDialogState.opened,
                onAction: (_) {},
              ),
            ),
          // The live service: the layer opens above the laboratory,
          // traps the focus, answers the keyboard, and queues.
          MentoraButton(
            key: const Key('dialog-open'),
            label: 'open',
            onPressed: () => widget.service.queue(
              demandOf(MentoraDialogVariant.confirmation),
            ),
          ),
          MentoraButton(
            key: const Key('dialog-queue'),
            label: 'queue',
            onPressed: () => widget.service.queue(
              demandOf(MentoraDialogVariant.information),
            ),
          ),
          MentoraText(
            'open: ${widget.service.isBusy} — '
            'pending: ${widget.service.pendingCount}',
            key: const Key('dialog-service-state'),
            role: MentoraTextRole.caption,
          ),
          const _DialogDocumentation(),
        ],
      ),
    );
  }
}

/// The Dialog's living documentation — built only with Mentora
/// components.
final class _DialogDocumentation extends StatelessWidget {
  const _DialogDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('dialog-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(dialogDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: dialogDocArchitecture,
            keyPrefix: 'dialog-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: dialogDocResponsibilities,
            keyPrefix: 'dialog-doc-responsibility',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: dialogDocTokens,
            keyPrefix: 'dialog-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: dialogDocEngines,
            keyPrefix: 'dialog-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: dialogDocForbidden,
            keyPrefix: 'dialog-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: dialogDocScans,
            keyPrefix: 'dialog-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Bottom Sheets catalogue — every variant and every
/// state of the REAL component, shown in place, plus the live service
/// and its living documentation.
final class BottomSheetGallery extends StatefulWidget {
  /// The official service of the laboratory — the same one the host
  /// listens to: the catalogue duplicates nothing.
  final MentoraBottomSheetService service;

  const BottomSheetGallery({super.key, required this.service});

  @override
  State<BottomSheetGallery> createState() => _BottomSheetGalleryState();
}

final class _BottomSheetGalleryState extends State<BottomSheetGallery> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onAccompanimentChanged);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onAccompanimentChanged);
    super.dispose();
  }

  void _onAccompanimentChanged() {
    if (mounted) setState(() {});
  }

  static MentoraBottomSheetRequest demandOf(
    MentoraBottomSheetVariant variant,
  ) {
    return MentoraBottomSheetRequest(
      variant: variant,
      title: variant.name,
      content: const MentoraText(
        'What this sheet accompanies.',
        role: MentoraTextRole.body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: sheetGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraBottomSheetVariant.values)
            MentoraBottomSheet(
              key: Key('sheet-variant-${variant.name}'),
              request: demandOf(variant),
              state: MentoraBottomSheetState.opened,
              detent: initialDetentOf(variant),
            ),
          // Every state, on the standard accompaniment.
          for (final state in MentoraBottomSheetState.values)
            MentoraBottomSheet(
              key: Key('sheet-state-${state.name}'),
              request: demandOf(MentoraBottomSheetVariant.standard),
              state: state,
              detent: MentoraBottomSheetDetent.collapsed,
            ),
          // Both detents, expressed side by side.
          for (final detent in MentoraBottomSheetDetent.values)
            MentoraBottomSheet(
              key: Key('sheet-detent-${detent.name}'),
              request: demandOf(MentoraBottomSheetVariant.selection),
              state: detent == MentoraBottomSheetDetent.expanded
                  ? MentoraBottomSheetState.expanded
                  : MentoraBottomSheetState.collapsed,
              detent: detent,
            ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: MentoraBottomSheet(
                key: Key('sheet-theme-${variant.name}'),
                request: demandOf(MentoraBottomSheetVariant.standard),
                state: MentoraBottomSheetState.opened,
                detent: MentoraBottomSheetDetent.collapsed,
              ),
            ),
          // Both reading directions.
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraBottomSheet(
                key: Key('sheet-direction-${direction.name}'),
                request: demandOf(MentoraBottomSheetVariant.standard),
                state: MentoraBottomSheetState.opened,
                detent: MentoraBottomSheetDetent.collapsed,
              ),
            ),
          // The live service: the layer rises above the laboratory,
          // traps the focus, answers the keyboard, and settles.
          MentoraButton(
            key: const Key('sheet-open'),
            label: 'open',
            onPressed: () => widget.service.queue(
              demandOf(MentoraBottomSheetVariant.selection),
            ),
          ),
          MentoraButton(
            key: const Key('sheet-expand'),
            label: 'expand',
            onPressed: widget.service.isBusy ? widget.service.expand : null,
          ),
          MentoraButton(
            key: const Key('sheet-collapse'),
            label: 'collapse',
            onPressed: widget.service.isBusy ? widget.service.collapse : null,
          ),
          MentoraText(
            'open: ${widget.service.isBusy} — '
            'detent: ${widget.service.detent.name} — '
            'pending: ${widget.service.pendingCount}',
            key: const Key('sheet-service-state'),
            role: MentoraTextRole.caption,
          ),
          const _BottomSheetDocumentation(),
        ],
      ),
    );
  }
}

/// The Bottom Sheet's living documentation — built only with Mentora
/// components.
final class _BottomSheetDocumentation extends StatelessWidget {
  const _BottomSheetDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('sheet-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(sheetDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: sheetDocArchitecture,
            keyPrefix: 'sheet-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: sheetDocResponsibilities,
            keyPrefix: 'sheet-doc-responsibility',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: sheetDocTokens,
            keyPrefix: 'sheet-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: sheetDocEngines,
            keyPrefix: 'sheet-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: sheetDocForbidden,
            keyPrefix: 'sheet-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: sheetDocScans,
            keyPrefix: 'sheet-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Snackbars catalogue — every variant and every state of
/// the REAL component, shown in place, plus the live service and its
/// living documentation.
final class SnackbarGallery extends StatefulWidget {
  /// The official service of the laboratory — the same one the host
  /// listens to: the catalogue duplicates nothing.
  final MentoraSnackbarService service;

  const SnackbarGallery({super.key, required this.service});

  @override
  State<SnackbarGallery> createState() => _SnackbarGalleryState();
}

final class _SnackbarGalleryState extends State<SnackbarGallery> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onMessageChanged);
    super.dispose();
  }

  void _onMessageChanged() {
    if (mounted) setState(() {});
  }

  static MentoraSnackbarRequest demandOf(MentoraSnackbarVariant variant) {
    return MentoraSnackbarRequest(
      variant: variant,
      message: 'One message, one idea — ${variant.name}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: snackbarGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraSnackbarVariant.values)
            MentoraSnackbar(
              key: Key('snackbar-variant-${variant.name}'),
              request: demandOf(variant),
              state: MentoraSnackbarState.visible,
            ),
          // Every state, on the information message.
          for (final state in MentoraSnackbarState.values)
            MentoraSnackbar(
              key: Key('snackbar-state-${state.name}'),
              request: demandOf(MentoraSnackbarVariant.information),
              state: state,
            ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: MentoraSnackbar(
                key: Key('snackbar-theme-${variant.name}'),
                request: demandOf(MentoraSnackbarVariant.information),
                state: MentoraSnackbarState.visible,
              ),
            ),
          // Both reading directions.
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraSnackbar(
                key: Key('snackbar-direction-${direction.name}'),
                request: demandOf(MentoraSnackbarVariant.information),
                state: MentoraSnackbarState.visible,
              ),
            ),
          // The live service: the message speaks above the laboratory,
          // queues, replaces, and leaves on its own.
          MentoraButton(
            key: const Key('snackbar-say'),
            label: 'say',
            onPressed: () => widget.service.queue(
              demandOf(MentoraSnackbarVariant.success),
            ),
          ),
          MentoraButton(
            key: const Key('snackbar-replace'),
            label: 'replace',
            onPressed: widget.service.isShowing
                ? () => widget.service.replace(
                    demandOf(MentoraSnackbarVariant.warning),
                  )
                : null,
          ),
          MentoraButton(
            key: const Key('snackbar-clear'),
            label: 'clear',
            onPressed: widget.service.isShowing ? widget.service.clear : null,
          ),
          MentoraText(
            'showing: ${widget.service.isShowing} — '
            'pending: ${widget.service.pendingCount}',
            key: const Key('snackbar-service-state'),
            role: MentoraTextRole.caption,
          ),
          const _SnackbarDocumentation(),
        ],
      ),
    );
  }
}

/// The Snackbar's living documentation — built only with Mentora
/// components.
final class _SnackbarDocumentation extends StatelessWidget {
  const _SnackbarDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('snackbar-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(snackbarDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: snackbarDocArchitecture,
            keyPrefix: 'snackbar-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: snackbarDocResponsibilities,
            keyPrefix: 'snackbar-doc-responsibility',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: snackbarDocTokens,
            keyPrefix: 'snackbar-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: snackbarDocEngines,
            keyPrefix: 'snackbar-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: snackbarDocForbidden,
            keyPrefix: 'snackbar-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: snackbarDocScans,
            keyPrefix: 'snackbar-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Badges catalogue — every variant, form, size and
/// state of the REAL component, across the four themes, the font
/// scales, the reading comfort and both directions.
final class BadgeGallery extends StatelessWidget {
  const BadgeGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: badgeGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              for (final variant in MentoraBadgeVariant.values)
                MentoraBadge(
                  key: Key('badge-variant-${variant.name}'),
                  variant: variant,
                  label: variant.name,
                ),
            ],
          ),
          Wrap(
            children: [
              for (final shape in MentoraBadgeShape.values)
                MentoraBadge(
                  key: Key('badge-shape-${shape.name}'),
                  variant: MentoraBadgeVariant.verified,
                  shape: shape,
                  label: shape.name,
                  // A form without words states its meaning: never
                  // colour alone.
                  semanticLabel: 'Vérifié — ${shape.name}',
                ),
            ],
          ),
          Wrap(
            children: [
              for (final size in MentoraBadgeSize.values)
                MentoraBadge(
                  key: Key('badge-size-${size.name}'),
                  variant: MentoraBadgeVariant.information,
                  size: size,
                  label: size.name,
                ),
            ],
          ),
          Wrap(
            children: [
              for (final state in MentoraBadgeState.values)
                MentoraBadge(
                  key: Key('badge-state-${state.name}'),
                  variant: MentoraBadgeVariant.success,
                  shape: MentoraBadgeShape.compact,
                  state: state,
                  label: state.name,
                ),
            ],
          ),
          // The four theme variants, high contrasts included.
          Wrap(
            children: [
              for (final variant in ThemeVariantId.values)
                DesignKitScope.deriving(
                  scope,
                  variant: variant,
                  child: MentoraBadge(
                    key: Key('badge-theme-${variant.name}'),
                    variant: MentoraBadgeVariant.premium,
                    label: variant.name,
                  ),
                ),
            ],
          ),
          // The font scales, applied by the application's scaler.
          for (final scale in FontScalePreference.values)
            Builder(
              builder: (context) {
                final state = scope.appearance.copyWith(fontScale: scale);
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      scope.accessibility.textScaleFor(state),
                    ),
                  ),
                  child: DesignKitScope.deriving(
                    scope,
                    appearance: state,
                    child: MentoraBadge(
                      key: Key('badge-scale-${scale.name}'),
                      variant: MentoraBadgeVariant.ai,
                      label: scale.name,
                    ),
                  ),
                );
              },
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: MentoraBadge(
                key: Key('badge-comfort-${comfort.name}'),
                variant: MentoraBadgeVariant.neutral,
                label: comfort.name,
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraBadge(
                key: Key('badge-direction-${direction.name}'),
                variant: MentoraBadgeVariant.offline,
                shape: MentoraBadgeShape.extended,
                label: direction.name,
              ),
            ),
          const _BadgeDocumentation(),
        ],
      ),
    );
  }
}

/// The Badge's living documentation — built only with Mentora
/// components.
final class _BadgeDocumentation extends StatelessWidget {
  const _BadgeDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('badge-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(badgeDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: badgeDocArchitecture,
            keyPrefix: 'badge-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: badgeDocResponsibilities,
            keyPrefix: 'badge-doc-responsibility',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: badgeDocTokens,
            keyPrefix: 'badge-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: badgeDocEngines,
            keyPrefix: 'badge-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: badgeDocForbidden,
            keyPrefix: 'badge-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: badgeDocScans,
            keyPrefix: 'badge-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Avatars catalogue — every identity, form, extent and
/// state of the REAL component, across the four themes, the font
/// scales, the reading comfort and both directions.
final class AvatarGallery extends StatelessWidget {
  const AvatarGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: avatarGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              for (final identity in MentoraAvatarIdentity.values)
                MentoraAvatar(
                  key: Key('avatar-identity-${identity.name}'),
                  identity: identity,
                  name: identity.name,
                  initials: 'AM',
                ),
            ],
          ),
          Wrap(
            children: [
              for (final shape in MentoraAvatarShape.values)
                MentoraAvatar(
                  key: Key('avatar-shape-${shape.name}'),
                  identity: MentoraAvatarIdentity.initials,
                  shape: shape,
                  name: shape.name,
                  initials: 'AM',
                ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final size in MentoraAvatarSize.values)
                MentoraAvatar(
                  key: Key('avatar-size-${size.name}'),
                  identity: MentoraAvatarIdentity.user,
                  size: size,
                  name: size.name,
                  initials: 'AM',
                ),
            ],
          ),
          Wrap(
            children: [
              for (final state in MentoraAvatarState.values)
                MentoraAvatar(
                  key: Key('avatar-state-${state.name}'),
                  identity: MentoraAvatarIdentity.organisation,
                  state: state,
                  name: state.name,
                  initials: 'MO',
                ),
            ],
          ),
          // The four theme variants, high contrasts included.
          Wrap(
            children: [
              for (final variant in ThemeVariantId.values)
                DesignKitScope.deriving(
                  scope,
                  variant: variant,
                  child: MentoraAvatar(
                    key: Key('avatar-theme-${variant.name}'),
                    identity: MentoraAvatarIdentity.ai,
                    name: variant.name,
                  ),
                ),
            ],
          ),
          // The font scales, applied by the application's scaler.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final scale in FontScalePreference.values)
                Builder(
                  builder: (context) {
                    final state = scope.appearance.copyWith(fontScale: scale);
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(
                          scope.accessibility.textScaleFor(state),
                        ),
                      ),
                      child: DesignKitScope.deriving(
                        scope,
                        appearance: state,
                        child: MentoraAvatar(
                          key: Key('avatar-scale-${scale.name}'),
                          identity: MentoraAvatarIdentity.initials,
                          name: scale.name,
                          initials: 'AM',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: MentoraAvatar(
                key: Key('avatar-comfort-${comfort.name}'),
                identity: MentoraAvatarIdentity.system,
                name: comfort.name,
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: MentoraAvatar(
                key: Key('avatar-direction-${direction.name}'),
                identity: MentoraAvatarIdentity.company,
                name: direction.name,
                initials: 'شم',
              ),
            ),
          const _AvatarDocumentation(),
        ],
      ),
    );
  }
}

/// The Avatar's living documentation — built only with Mentora
/// components.
final class _AvatarDocumentation extends StatelessWidget {
  const _AvatarDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('avatar-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(avatarDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: avatarDocArchitecture,
            keyPrefix: 'avatar-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: avatarDocResponsibilities,
            keyPrefix: 'avatar-doc-responsibility',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: avatarDocTokens,
            keyPrefix: 'avatar-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: avatarDocEngines,
            keyPrefix: 'avatar-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: avatarDocForbidden,
            keyPrefix: 'avatar-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: avatarDocScans,
            keyPrefix: 'avatar-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official List Tiles catalogue — every density, chrome, state
/// and composition of the REAL component, across the four themes, the
/// reading comfort and both directions.
final class ListTileGallery extends StatelessWidget {
  const ListTileGallery({super.key});

  static void _noop() {}

  static MentoraListTile entity({
    Key? key,
    MentoraListTileDensity density = MentoraListTileDensity.standard,
    MentoraListTileChrome chrome = MentoraListTileChrome.plain,
    MentoraListTileController? controller,
    VoidCallback? onTap,
    bool composed = true,
  }) {
    return MentoraListTile(
      key: key,
      density: density,
      chrome: chrome,
      controller: controller,
      onTap: onTap,
      leading: composed
          ? MentoraAvatar(
              identity: MentoraAvatarIdentity.initials,
              name: 'Awa Mensah',
              initials: 'AM',
              size: avatarSizeOf(density),
            )
          : null,
      headline: 'Awa Mensah',
      supporting: composed ? 'Consultation de suivi' : null,
      metadata: composed ? '11:00 — 45 min' : null,
      badges: composed
          ? const [
              MentoraBadge(
                variant: MentoraBadgeVariant.success,
                shape: MentoraBadgeShape.compact,
                label: 'Confirmée',
              ),
            ]
          : const [],
      trailing: composed
          ? MentoraButton(
              label: 'Ouvrir',
              onPressed: _noop,
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            )
          : null,
      footer: composed ? 'Dernier échange il y a 2 jours' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: listTileGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final density in MentoraListTileDensity.values)
            entity(
              key: Key('list-tile-density-${density.name}'),
              density: density,
            ),
          for (final chrome in MentoraListTileChrome.values)
            entity(
              key: Key('list-tile-chrome-${chrome.name}'),
              chrome: chrome,
            ),
          // The announced states of the entity.
          for (final status in MentoraListTileStatus.values)
            entity(
              key: Key('list-tile-status-${status.name}'),
              controller: MentoraListTileController(status),
              onTap: _noop,
            ),
          // An entity that invites an act — press, tab and hover it.
          entity(key: const Key('list-tile-interactive'), onTap: _noop),
          // The barest entity: a name is always enough.
          entity(key: const Key('list-tile-bare'), composed: false),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: entity(key: Key('list-tile-theme-${variant.name}')),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: entity(key: Key('list-tile-comfort-${comfort.name}')),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: entity(key: Key('list-tile-direction-${direction.name}')),
            ),
          const _ListTileDocumentation(),
        ],
      ),
    );
  }
}

/// The List Tile's living documentation — built only with Mentora
/// components.
final class _ListTileDocumentation extends StatelessWidget {
  const _ListTileDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('list-tile-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(listTileDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: listTileDocArchitecture,
            keyPrefix: 'list-tile-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: listTileDocResponsibilities,
            keyPrefix: 'list-tile-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: listTileDocComponents,
            keyPrefix: 'list-tile-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: listTileDocTokens,
            keyPrefix: 'list-tile-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: listTileDocEngines,
            keyPrefix: 'list-tile-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: listTileDocForbidden,
            keyPrefix: 'list-tile-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: listTileDocScans,
            keyPrefix: 'list-tile-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official App Bars catalogue — every variant, every announced
/// state and every scroll declaration of the REAL component, across
/// the four themes, the reading comfort and both directions.
final class AppBarGallery extends StatelessWidget {
  const AppBarGallery({super.key});

  static void _noop() {}

  static MentoraAppBar context({
    Key? key,
    MentoraAppBarVariant variant = MentoraAppBarVariant.standard,
    MentoraAppBarController? controller,
    MentoraAppBarScrollBehaviour scrollBehaviour =
        MentoraAppBarScrollBehaviour.pinned,
  }) {
    return MentoraAppBar(
      key: key,
      variant: variant,
      scrollBehaviour: scrollBehaviour,
      controller: controller,
      title: 'Consultations',
      subtitle: 'Aujourd’hui',
      navigation: MentoraAppBarNavigation.back(
        label: 'Retour',
        onInvoke: _noop,
      ),
      badge: const MentoraBadge(
        variant: MentoraBadgeVariant.information,
        shape: MentoraBadgeShape.pill,
        label: '4',
        semanticLabel: '4 consultations',
      ),
      actions: [
        MentoraButton(
          label: 'Filtrer',
          onPressed: _noop,
          variant: MentoraButtonVariant.text,
          size: MentoraButtonSize.small,
        ),
      ],
      search: variant == MentoraAppBarVariant.search
          ? const MentoraInput(
              variant: MentoraInputVariant.search,
              placeholder: 'Rechercher',
              semanticLabel: 'Rechercher une consultation',
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: appBarGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraAppBarVariant.values)
            AppBarGallery.context(
              key: Key('app-bar-variant-${variant.name}'),
              variant: variant,
              controller: variant == MentoraAppBarVariant.search
                  ? MentoraAppBarController(MentoraAppBarStatus.searching)
                  : null,
            ),
          // The announced states of the context.
          for (final status in MentoraAppBarStatus.values)
            AppBarGallery.context(
              key: Key('app-bar-status-${status.name}'),
              variant: status == MentoraAppBarStatus.searching
                  ? MentoraAppBarVariant.search
                  : MentoraAppBarVariant.standard,
              controller: MentoraAppBarController(status),
            ),
          // A large title, expanded then collapsed by an announced
          // progress — the structure measures nothing itself.
          AppBarGallery.context(
            key: const Key('app-bar-expanded'),
            variant: MentoraAppBarVariant.largeTitle,
            scrollBehaviour: MentoraAppBarScrollBehaviour.collapsible,
          ),
          AppBarGallery.context(
            key: const Key('app-bar-collapsed'),
            variant: MentoraAppBarVariant.largeTitle,
            scrollBehaviour: MentoraAppBarScrollBehaviour.collapsible,
            controller: MentoraAppBarController()..reportProgress(1),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: AppBarGallery.context(
                key: Key('app-bar-theme-${variant.name}'),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: AppBarGallery.context(
                key: Key('app-bar-comfort-${comfort.name}'),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: AppBarGallery.context(
                key: Key('app-bar-direction-${direction.name}'),
              ),
            ),
          const _AppBarDocumentation(),
        ],
      ),
    );
  }
}

/// The App Bar's living documentation — built only with Mentora
/// components.
final class _AppBarDocumentation extends StatelessWidget {
  const _AppBarDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('app-bar-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(appBarDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: appBarDocArchitecture,
            keyPrefix: 'app-bar-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: appBarDocResponsibilities,
            keyPrefix: 'app-bar-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: appBarDocComponents,
            keyPrefix: 'app-bar-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: appBarDocTokens,
            keyPrefix: 'app-bar-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: appBarDocEngines,
            keyPrefix: 'app-bar-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: appBarDocForbidden,
            keyPrefix: 'app-bar-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: appBarDocScans,
            keyPrefix: 'app-bar-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Navigation Rails catalogue — every display, chrome
/// and state of the REAL component, across the four themes, the
/// reading comfort and both directions.
final class NavigationRailGallery extends StatefulWidget {
  const NavigationRailGallery({super.key});

  @override
  State<NavigationRailGallery> createState() => _NavigationRailGalleryState();
}

final class _NavigationRailGalleryState extends State<NavigationRailGallery> {
  final MentoraNavigationRailController _controller =
      MentoraNavigationRailController('home');
  MentoraNavigationRailDisplay _display = MentoraNavigationRailDisplay.compact;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<MentoraDestination> places = [
    MentoraDestination(
      id: 'home',
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    MentoraDestination(
      id: 'consultation',
      label: 'Consultation',
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note,
      badge: MentoraBadge(
        variant: MentoraBadgeVariant.information,
        shape: MentoraBadgeShape.dot,
        semanticLabel: 'Nouvelles consultations',
      ),
    ),
    MentoraDestination(
      id: 'business',
      label: 'Activité',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
    MentoraDestination(
      id: 'archive',
      label: 'Archives',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      enabled: false,
    ),
  ];

  static Widget framed(Widget rail) =>
      SizedBox(height: kMinInteractiveDimension * 6, child: rail);

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget rail({
      Key? key,
      MentoraNavigationRailDisplay display =
          MentoraNavigationRailDisplay.compact,
      MentoraNavigationRailChrome chrome = MentoraNavigationRailChrome.surface,
      MentoraNavigationRailController? controller,
    }) {
      return framed(
        MentoraNavigationRail(
          key: key,
          display: display,
          chrome: chrome,
          controller: controller ?? MentoraNavigationRailController('home'),
          destinations: places,
          onDestinationSelected: (_) {},
        ),
      );
    }

    return GallerySection(
      title: navigationRailGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final display in MentoraNavigationRailDisplay.values)
            rail(key: Key('rail-display-${display.name}'), display: display),
          for (final chrome in MentoraNavigationRailChrome.values)
            rail(key: Key('rail-chrome-${chrome.name}'), chrome: chrome),
          // A structure the application put to rest.
          rail(
            key: const Key('rail-disabled'),
            controller: MentoraNavigationRailController('home')
              ..announceAvailability(enabled: false),
          ),
          // The live structure: the application announces the place,
          // and performs the change of display itself.
          framed(
            MentoraNavigationRail(
              key: const Key('rail-live'),
              display: _display,
              controller: _controller,
              destinations: places,
              onDestinationSelected: _controller.announceSelection,
              displayToggle: MentoraNavigationRailToggle(
                label: 'Afficher',
                onInvoke: () => setState(() {
                  _display = _display == MentoraNavigationRailDisplay.compact
                      ? MentoraNavigationRailDisplay.expanded
                      : MentoraNavigationRailDisplay.compact;
                }),
              ),
            ),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: rail(key: Key('rail-theme-${variant.name}')),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: rail(key: Key('rail-comfort-${comfort.name}')),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: rail(
                key: Key('rail-direction-${direction.name}'),
                display: MentoraNavigationRailDisplay.expanded,
              ),
            ),
          const _NavigationRailDocumentation(),
        ],
      ),
    );
  }
}

/// The Navigation Rail's living documentation — built only with
/// Mentora components.
final class _NavigationRailDocumentation extends StatelessWidget {
  const _NavigationRailDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('rail-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(navigationRailDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: navigationRailDocArchitecture,
            keyPrefix: 'rail-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: navigationRailDocResponsibilities,
            keyPrefix: 'rail-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: navigationRailDocComponents,
            keyPrefix: 'rail-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: navigationRailDocTokens,
            keyPrefix: 'rail-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: navigationRailDocEngines,
            keyPrefix: 'rail-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: navigationRailDocForbidden,
            keyPrefix: 'rail-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: navigationRailDocScans,
            keyPrefix: 'rail-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Tabs catalogue — every emphasis, shape, overflow and
/// state of the REAL component, across the four themes, the reading
/// comfort and both directions.
final class TabsGallery extends StatefulWidget {
  const TabsGallery({super.key});

  @override
  State<TabsGallery> createState() => _TabsGalleryState();
}

final class _TabsGalleryState extends State<TabsGallery> {
  final MentoraTabsController _controller = MentoraTabsController('overview');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<MentoraTab> facets = [
    MentoraTab(
      id: 'overview',
      label: 'Vue d’ensemble',
      icon: Icons.dashboard_outlined,
    ),
    MentoraTab(
      id: 'sessions',
      label: 'Séances',
      icon: Icons.event_note_outlined,
      badge: MentoraBadge(
        variant: MentoraBadgeVariant.information,
        shape: MentoraBadgeShape.pill,
        label: '3',
        semanticLabel: '3 séances',
      ),
    ),
    MentoraTab(id: 'documents', label: 'Documents', loading: true),
    MentoraTab(id: 'archive', label: 'Archives', enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget tabs({
      Key? key,
      MentoraTabsEmphasis emphasis = MentoraTabsEmphasis.primary,
      MentoraTabsShape shape = MentoraTabsShape.underline,
      MentoraTabsOverflow overflow = MentoraTabsOverflow.scroll,
      bool enabled = true,
      MentoraTabsController? controller,
    }) {
      return MentoraTabs(
        key: key,
        emphasis: emphasis,
        shape: shape,
        overflow: overflow,
        enabled: enabled,
        controller: controller ?? MentoraTabsController('overview'),
        tabs: facets,
        onTabSelected: (_) {},
      );
    }

    return GallerySection(
      title: tabsGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final emphasis in MentoraTabsEmphasis.values)
            tabs(key: Key('tabs-emphasis-${emphasis.name}'), emphasis: emphasis),
          for (final shape in MentoraTabsShape.values)
            tabs(key: Key('tabs-shape-${shape.name}'), shape: shape),
          for (final overflow in MentoraTabsOverflow.values)
            tabs(key: Key('tabs-overflow-${overflow.name}'), overflow: overflow),
          tabs(key: const Key('tabs-disabled'), enabled: false),
          // The live set: the application announces the facet it
          // revealed — the set only reported the intention.
          MentoraTabs(
            key: const Key('tabs-live'),
            controller: _controller,
            tabs: facets,
            onTabSelected: _controller.announceSelection,
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: tabs(key: Key('tabs-theme-${variant.name}')),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: tabs(key: Key('tabs-comfort-${comfort.name}')),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: tabs(key: Key('tabs-direction-${direction.name}')),
            ),
          const _TabsDocumentation(),
        ],
      ),
    );
  }
}

/// The Tabs' living documentation — built only with Mentora
/// components.
final class _TabsDocumentation extends StatelessWidget {
  const _TabsDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('tabs-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(tabsDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: tabsDocArchitecture,
            keyPrefix: 'tabs-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: tabsDocResponsibilities,
            keyPrefix: 'tabs-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: tabsDocComponents,
            keyPrefix: 'tabs-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: tabsDocTokens,
            keyPrefix: 'tabs-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: tabsDocEngines,
            keyPrefix: 'tabs-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: tabsDocForbidden,
            keyPrefix: 'tabs-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: tabsDocScans,
            keyPrefix: 'tabs-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Search Bars catalogue — every variant and every
/// announced state of the REAL component, with its aids and its
/// prepared acts, across the four themes and both directions.
final class SearchBarGallery extends StatefulWidget {
  const SearchBarGallery({super.key});

  @override
  State<SearchBarGallery> createState() => _SearchBarGalleryState();
}

final class _SearchBarGalleryState extends State<SearchBarGallery> {
  final MentoraSearchController _live = MentoraSearchController();

  @override
  void initState() {
    super.initState();
    // The aids are PUBLISHED by the application — the laboratory plays
    // that part; the bar computes none of them.
    _live.publishSuggestions(const [
      MentoraSearchSuggestion(
        id: 'awa',
        label: 'Awa Mensah',
        supporting: 'Experte — Nutrition',
        icon: Icons.person_outline,
      ),
      MentoraSearchSuggestion(
        id: 'sessions',
        label: 'Séances de cette semaine',
        icon: Icons.event_note_outlined,
      ),
    ]);
  }

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget bar({
      Key? key,
      MentoraSearchBarVariant variant = MentoraSearchBarVariant.standard,
      MentoraSearchController? controller,
      bool enabled = true,
    }) {
      return MentoraSearchBar(
        key: key,
        variant: variant,
        enabled: enabled,
        controller: controller ?? MentoraSearchController(),
        placeholder: 'Rechercher',
        semanticLabel: 'Rechercher dans Mentora',
        clearLabel: 'Effacer',
        onQueryChanged: (_) {},
      );
    }

    return GallerySection(
      title: searchBarGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraSearchBarVariant.values)
            bar(key: Key('search-variant-${variant.name}'), variant: variant),
          // The announced phases — the application says what it is
          // doing with the intention it received.
          for (final phase in MentoraSearchPhase.values)
            bar(
              key: Key('search-phase-${phase.name}'),
              controller: MentoraSearchController()..announcePhase(phase),
            ),
          bar(key: const Key('search-disabled'), enabled: false),
          // The live bar: aids published by the application, and acts
          // it prepared but the Kit never performs.
          MentoraSearchBar(
            key: const Key('search-live'),
            controller: _live,
            placeholder: 'Rechercher',
            semanticLabel: 'Rechercher dans Mentora',
            clearLabel: 'Effacer',
            voice: const MentoraSearchAffordance(
              label: 'Dicter',
              onInvoke: _noop,
            ),
            history: const MentoraSearchAffordance(
              label: 'Historique',
              onInvoke: _noop,
            ),
            onQueryChanged: _live.announceQuery,
            onSuggestionChosen: (_) {},
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: bar(key: Key('search-theme-${variant.name}')),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: bar(key: Key('search-comfort-${comfort.name}')),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: bar(key: Key('search-direction-${direction.name}')),
            ),
          const _SearchBarDocumentation(),
        ],
      ),
    );
  }
}

/// The Search Bar's living documentation — built only with Mentora
/// components.
final class _SearchBarDocumentation extends StatelessWidget {
  const _SearchBarDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('search-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(searchBarDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: searchBarDocArchitecture,
            keyPrefix: 'search-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: searchBarDocResponsibilities,
            keyPrefix: 'search-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: searchBarDocComponents,
            keyPrefix: 'search-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: searchBarDocTokens,
            keyPrefix: 'search-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: searchBarDocEngines,
            keyPrefix: 'search-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: searchBarDocForbidden,
            keyPrefix: 'search-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: searchBarDocScans,
            keyPrefix: 'search-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Navigation Drawers catalogue — every presentation,
/// both visibilities and every destination state of the REAL
/// component, across the four themes and both directions.
final class NavigationDrawerGallery extends StatefulWidget {
  const NavigationDrawerGallery({super.key});

  @override
  State<NavigationDrawerGallery> createState() =>
      _NavigationDrawerGalleryState();
}

final class _NavigationDrawerGalleryState
    extends State<NavigationDrawerGallery> {
  final MentoraNavigationDrawerController _live =
      MentoraNavigationDrawerController(
        selectedId: 'home',
        visibility: MentoraDrawerVisibility.opened,
      );

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  static void _noop() {}

  static const List<MentoraDrawerSection> sections = [
    MentoraDrawerSection(
      destinations: [
        MentoraDestination(
          id: 'home',
          label: 'Accueil',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        MentoraDestination(
          id: 'consultation',
          label: 'Consultations',
          icon: Icons.event_note_outlined,
          selectedIcon: Icons.event_note,
          badge: MentoraBadge(
            variant: MentoraBadgeVariant.information,
            shape: MentoraBadgeShape.dot,
            semanticLabel: 'Nouvelles consultations',
          ),
        ),
      ],
    ),
    MentoraDrawerSection(
      title: 'Espace professionnel',
      destinations: [
        MentoraDestination(
          id: 'business',
          label: 'Activité',
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights,
        ),
        MentoraDestination(
          id: 'archive',
          label: 'Archives',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          enabled: false,
        ),
      ],
    ),
  ];

  static MentoraListTile get space => MentoraListTile(
    leading: const MentoraAvatar(
      identity: MentoraAvatarIdentity.initials,
      name: 'Awa Mensah',
      initials: 'AM',
    ),
    headline: 'Awa Mensah',
    supporting: 'Experte — Nutrition',
  );

  static Widget framed(Widget map) =>
      SizedBox(height: kMinInteractiveDimension * 7, child: map);

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget map({
      Key? key,
      MentoraDrawerPresentation presentation =
          MentoraDrawerPresentation.permanent,
      MentoraDrawerVisibility visibility = MentoraDrawerVisibility.opened,
    }) {
      return framed(
        MentoraNavigationDrawer(
          key: key,
          presentation: presentation,
          controller: MentoraNavigationDrawerController(
            selectedId: 'home',
            visibility: visibility,
          ),
          sections: sections,
          space: space,
          semanticLabel: 'Espace de Awa Mensah',
          onDestinationSelected: (_) {},
          onDismissRequested:
              presentation == MentoraDrawerPresentation.permanent
              ? null
              : _noop,
          actions: [
            MentoraButton(
              label: 'Paramètres',
              onPressed: _noop,
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );
    }

    return GallerySection(
      title: drawerGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final presentation in MentoraDrawerPresentation.values)
            map(
              key: Key('drawer-presentation-${presentation.name}'),
              presentation: presentation,
            ),
          for (final visibility in MentoraDrawerVisibility.values)
            map(
              key: Key('drawer-visibility-${visibility.name}'),
              presentation: MentoraDrawerPresentation.dismissible,
              visibility: visibility,
            ),
          // The live map: the application announces where the person
          // is — the map only reported the intention.
          framed(
            MentoraNavigationDrawer(
              key: const Key('drawer-live'),
              controller: _live,
              sections: sections,
              space: space,
              semanticLabel: 'Espace de Awa Mensah',
              onDestinationSelected: _live.announceSelection,
            ),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: map(key: Key('drawer-theme-${variant.name}')),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: map(key: Key('drawer-comfort-${comfort.name}')),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: map(key: Key('drawer-direction-${direction.name}')),
            ),
          const _NavigationDrawerDocumentation(),
        ],
      ),
    );
  }
}

/// The Navigation Drawer's living documentation — built only with
/// Mentora components.
final class _NavigationDrawerDocumentation extends StatelessWidget {
  const _NavigationDrawerDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('drawer-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(drawerDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: drawerDocArchitecture,
            keyPrefix: 'drawer-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: drawerDocResponsibilities,
            keyPrefix: 'drawer-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: drawerDocComponents,
            keyPrefix: 'drawer-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: drawerDocTokens,
            keyPrefix: 'drawer-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: drawerDocEngines,
            keyPrefix: 'drawer-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: drawerDocForbidden,
            keyPrefix: 'drawer-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: drawerDocScans,
            keyPrefix: 'drawer-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Page Scaffolds catalogue — every zone and every
/// assembly of the REAL container, from the barest page to the one
/// that gathers all the structures at once.
final class PageScaffoldGallery extends StatelessWidget {
  const PageScaffoldGallery({super.key});

  static void _noop() {}

  // A page gathers up to six structures: the catalogue gives each
  // scene the room the assembled one needs.
  static Widget framed(Widget page) =>
      SizedBox(height: kMinInteractiveDimension * 8, child: page);

  static MentoraPageScaffold page({
    Key? key,
    MentoraAppBar? place,
    MentoraNavigationRail? rail,
    MentoraNavigationDrawer? orientation,
    MentoraTabs? facets,
    MentoraSearchBar? intention,
    MentoraBottomNavigation? bottomNavigation,
    List<MentoraButton> acts = const [],
  }) {
    return MentoraPageScaffold(
      key: key,
      semanticLabel: 'Consultations',
      place: place,
      rail: rail,
      orientation: orientation,
      facets: facets,
      intention: intention,
      bottomNavigation: bottomNavigation,
      acts: acts,
      content: const MentoraText(
        'Le contenu appartient entièrement à l’application.',
        role: MentoraTextRole.body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: pageScaffoldGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          framed(page(key: const Key('page-simple'))),
          framed(
            page(
              key: const Key('page-place'),
              place: const MentoraAppBar(title: 'Consultations'),
            ),
          ),
          framed(
            page(
              key: const Key('page-rail'),
              rail: MentoraNavigationRail(
                destinations: _NavigationRailGalleryState.places,
                controller: MentoraNavigationRailController('home'),
                onDestinationSelected: (_) {},
              ),
            ),
          ),
          framed(
            page(
              key: const Key('page-orientation'),
              orientation: MentoraNavigationDrawer(
                controller: MentoraNavigationDrawerController(
                  selectedId: 'home',
                  visibility: MentoraDrawerVisibility.opened,
                ),
                sections: _NavigationDrawerGalleryState.sections,
                semanticLabel: 'Espace de Awa Mensah',
                onDestinationSelected: (_) {},
              ),
            ),
          ),
          framed(
            page(
              key: const Key('page-facets'),
              facets: MentoraTabs(
                controller: MentoraTabsController('overview'),
                tabs: _TabsGalleryState.facets,
                onTabSelected: (_) {},
              ),
            ),
          ),
          framed(
            page(
              key: const Key('page-intention'),
              intention: MentoraSearchBar(
                controller: MentoraSearchController(),
                placeholder: 'Rechercher',
                semanticLabel: 'Rechercher dans Mentora',
                onQueryChanged: (_) {},
              ),
            ),
          ),
          framed(
            page(
              key: const Key('page-bottom-navigation'),
              bottomNavigation: MentoraBottomNavigation(
                destinations: _BottomNavigationGalleryState.places(5),
                selectedDestinationId: 'home',
                semanticLabel: 'Navigation principale',
                onDestinationRequested: (_) {},
              ),
            ),
          ),
          framed(
            page(
              key: const Key('page-acts'),
              acts: [
                MentoraButton(
                  label: 'Confirmer',
                  onPressed: _noop,
                  size: MentoraButtonSize.small,
                ),
              ],
            ),
          ),
          // Everything at once: a page gathers, and stays a context.
          framed(
            page(
              key: const Key('page-assembled'),
              place: const MentoraAppBar(title: 'Consultations'),
              intention: MentoraSearchBar(
                controller: MentoraSearchController(),
                placeholder: 'Rechercher',
                semanticLabel: 'Rechercher dans Mentora',
                onQueryChanged: (_) {},
              ),
              facets: MentoraTabs(
                controller: MentoraTabsController('overview'),
                tabs: _TabsGalleryState.facets,
                onTabSelected: (_) {},
              ),
              rail: MentoraNavigationRail(
                destinations: _NavigationRailGalleryState.places,
                controller: MentoraNavigationRailController('home'),
                onDestinationSelected: (_) {},
              ),
              bottomNavigation: MentoraBottomNavigation(
                destinations: _BottomNavigationGalleryState.places(5),
                selectedDestinationId: 'home',
                semanticLabel: 'Navigation principale',
                onDestinationRequested: (_) {},
              ),
              acts: [
                MentoraButton(
                  label: 'Confirmer',
                  onPressed: _noop,
                  size: MentoraButtonSize.small,
                ),
              ],
            ),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: framed(page(key: Key('page-theme-${variant.name}'))),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: framed(page(key: Key('page-comfort-${comfort.name}'))),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: framed(page(key: Key('page-direction-${direction.name}'))),
            ),
          const _PageScaffoldDocumentation(),
        ],
      ),
    );
  }
}

/// The Page Scaffold's living documentation — built only with Mentora
/// components.
final class _PageScaffoldDocumentation extends StatelessWidget {
  const _PageScaffoldDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('page-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(pageScaffoldDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: pageScaffoldDocArchitecture,
            keyPrefix: 'page-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: pageScaffoldDocResponsibilities,
            keyPrefix: 'page-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: pageScaffoldDocComponents,
            keyPrefix: 'page-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: pageScaffoldDocTokens,
            keyPrefix: 'page-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: pageScaffoldDocEngines,
            keyPrefix: 'page-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: pageScaffoldDocForbidden,
            keyPrefix: 'page-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: pageScaffoldDocScans,
            keyPrefix: 'page-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Bottom Navigations catalogue — every admitted number
/// of destinations, every state, and the badges a place may carry.
final class BottomNavigationGallery extends StatefulWidget {
  const BottomNavigationGallery({super.key});

  @override
  State<BottomNavigationGallery> createState() =>
      _BottomNavigationGalleryState();
}

final class _BottomNavigationGalleryState
    extends State<BottomNavigationGallery> {
  /// The principal places of the catalogue — identities, never
  /// positions.
  static const List<
    ({String id, String label, IconData icon, IconData selectedIcon})
  >
  catalogue = [
    (
      id: 'home',
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    (
      id: 'consultation',
      label: 'Consultation',
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note,
    ),
    (
      id: 'business',
      label: 'Activité',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
    (
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
    ),
    (
      id: 'account',
      label: 'Compte',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  static List<MentoraDestination> places(
    int count, {
    bool badges = false,
    Set<String> unavailable = const {},
  }) {
    return [
      for (final place in catalogue.take(count))
        MentoraDestination(
          id: place.id,
          label: place.label,
          icon: place.icon,
          selectedIcon: place.selectedIcon,
          enabled: !unavailable.contains(place.id),
          badge: badges && place.id == 'notifications'
              ? const MentoraBadge(
                  variant: MentoraBadgeVariant.information,
                  shape: MentoraBadgeShape.compact,
                  size: MentoraBadgeSize.small,
                  label: '3',
                  semanticLabel: '3 notifications non lues',
                )
              : null,
        ),
    ];
  }

  /// Where the person is in the live scene — the gallery is the
  /// application here: the structure only reports.
  String _selectedId = 'home';

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget scene(
      String name,
      List<MentoraDestination> destinations, {
      String? selectedId = 'home',
    }) {
      return MentoraBottomNavigation(
        key: Key('bottom-navigation-$name'),
        destinations: destinations,
        selectedDestinationId: selectedId,
        semanticLabel: 'Navigation principale',
        onDestinationRequested: (_) {},
      );
    }

    return GallerySection(
      title: bottomNavigationGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          scene('three', places(3)),
          scene('four', places(4)),
          scene('five', places(5)),
          scene('badges', places(5, badges: true)),
          // A place that cannot be reached stays visible: the person
          // keeps seeing that it exists.
          scene('unavailable', places(5, unavailable: const {'business'})),
          // Nowhere announced: a structure never guesses where the
          // person is.
          scene('unselected', places(5), selectedId: null),
          // The live scene: the structure reports, the gallery decides.
          MentoraBottomNavigation(
            key: const Key('bottom-navigation-live'),
            destinations: places(5, badges: true),
            selectedDestinationId: _selectedId,
            semanticLabel: 'Navigation principale',
            onDestinationRequested: (id) => setState(() => _selectedId = id),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: scene('theme-${variant.name}', places(5)),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: scene('comfort-${comfort.name}', places(5)),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: scene('direction-${direction.name}', places(5)),
            ),
          const _BottomNavigationDocumentation(),
        ],
      ),
    );
  }
}

/// The Bottom Navigation's living documentation — built only with
/// Mentora components.
final class _BottomNavigationDocumentation extends StatelessWidget {
  const _BottomNavigationDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('bottom-navigation-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(
            bottomNavigationDocHeading,
            role: MentoraTextRole.subtitle,
          ),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: bottomNavigationDocArchitecture,
            keyPrefix: 'bottom-navigation-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: bottomNavigationDocResponsibilities,
            keyPrefix: 'bottom-navigation-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: bottomNavigationDocComponents,
            keyPrefix: 'bottom-navigation-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: bottomNavigationDocTokens,
            keyPrefix: 'bottom-navigation-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: bottomNavigationDocEngines,
            keyPrefix: 'bottom-navigation-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: bottomNavigationDocForbidden,
            keyPrefix: 'bottom-navigation-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: bottomNavigationDocScans,
            keyPrefix: 'bottom-navigation-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Catalog Layout catalogue - an offer gone through, its
/// entries announced by the application and never interpreted.
final class CatalogLayoutGallery extends StatelessWidget {
  const CatalogLayoutGallery({super.key});

  static const List<String> _entries = [
    catalogAdviceId,
    catalogTrainingId,
    catalogSupportId,
  ];

  // Three entries and their cards: the frame is sized by what it
  // shows.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 12);

  /// What an entry of an offer is - built by components, never by the
  /// layout, and never understood by it.
  static MentoraIdentifiedContent entry(String id) => MentoraIdentifiedContent(
    id: id,
    content: MentoraCard(
      key: Key('catalog-entry-$id'),
      variant: MentoraCardVariant.surface,
      child: const MentoraListTile(
        headline: catalogEntryName,
        supporting: catalogEntrySupporting,
        semanticLabel: catalogEntryName,
        leading: MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: catalogEntryName,
          initials: catalogEntryInitials,
        ),
        badges: [
          MentoraBadge(
            variant: MentoraBadgeVariant.verified,
            label: catalogMentionLabel,
            semanticLabel: catalogMentionLabel,
          ),
        ],
      ),
    ),
  );

  static MentoraCatalogLayout shape({Key? key, bool complete = true}) {
    return MentoraCatalogLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      catalogId: catalogId,
      catalogSemanticLabel: catalogLabel,
      entries: [
        for (final id in _entries)
          if (complete || id == catalogAdviceId) entry(id),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: catalogLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-catalog'))),
          // One entry alone: an offer stands from the first entry on.
          _scene(shape(key: const Key('layout-catalog-bare'), complete: false)),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(shape(key: Key('layout-catalog-${variant.name}'))),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(shape(key: Key('layout-catalog-${comfort.name}'))),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(
                shape(key: Key('layout-catalog-${direction.name}')),
              ),
            ),
          const _CatalogLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Catalog Layout's living documentation - built only with Mentora
/// components.
final class _CatalogLayoutDocumentation extends StatelessWidget {
  const _CatalogLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('catalog-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(catalogLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: catalogLayoutDocArchitecture,
            keyPrefix: 'catalog-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: catalogLayoutDocResponsibilities,
            keyPrefix: 'catalog-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: catalogLayoutDocComponents,
            keyPrefix: 'catalog-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: catalogLayoutDocTokens,
            keyPrefix: 'catalog-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: catalogLayoutDocEngines,
            keyPrefix: 'catalog-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: catalogLayoutDocForbidden,
            keyPrefix: 'catalog-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: catalogLayoutDocScans,
            keyPrefix: 'catalog-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Analytics Layout catalogue - a space where a system is
/// observed. The views are announced; nothing is computed, compared or
/// rearranged.
final class AnalyticsLayoutGallery extends StatelessWidget {
  const AnalyticsLayoutGallery({super.key});

  static const Map<String, String> _names = {
    analyticsRevenueId: analyticsRevenueLabel,
    analyticsActivityId: analyticsActivityLabel,
    analyticsQualityId: analyticsQualityLabel,
  };

  // Three observed views and their cards: the frame is sized by what
  // it shows.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 12);

  static MentoraAnalyticsLayout shape({Key? key, bool complete = true}) {
    return MentoraAnalyticsLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      views: [
        for (final entry in _names.entries)
          if (complete || entry.key == analyticsRevenueId)
            MentoraContentRegion(
              id: entry.key,
              semanticLabel: entry.value,
              // What there is to observe belongs to the components:
              // the layout places it and understands none of it.
              content: MentoraCard(
                key: Key('analytics-view-${entry.key}'),
                variant: MentoraCardVariant.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MentoraText(entry.value, role: MentoraTextRole.subtitle),
                    const MentoraText(
                      analyticsObservationBody,
                      role: MentoraTextRole.body,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: analyticsLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-analytics'))),
          // One view alone: a space observes from the first view on.
          _scene(
            shape(key: const Key('layout-analytics-bare'), complete: false),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(
                shape(key: Key('layout-analytics-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(
                shape(key: Key('layout-analytics-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(
                shape(key: Key('layout-analytics-${direction.name}')),
              ),
            ),
          const _AnalyticsLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Analytics Layout's living documentation - built only with
/// Mentora components.
final class _AnalyticsLayoutDocumentation extends StatelessWidget {
  const _AnalyticsLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('analytics-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(
            analyticsLayoutDocHeading,
            role: MentoraTextRole.subtitle,
          ),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: analyticsLayoutDocArchitecture,
            keyPrefix: 'analytics-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: analyticsLayoutDocResponsibilities,
            keyPrefix: 'analytics-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: analyticsLayoutDocComponents,
            keyPrefix: 'analytics-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: analyticsLayoutDocTokens,
            keyPrefix: 'analytics-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: analyticsLayoutDocEngines,
            keyPrefix: 'analytics-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: analyticsLayoutDocForbidden,
            keyPrefix: 'analytics-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: analyticsLayoutDocScans,
            keyPrefix: 'analytics-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Settings Layout catalogue - a space where a system is
/// configured. The laboratory announces which categories are open: the
/// layout opens none of them by itself.
final class SettingsLayoutGallery extends StatefulWidget {
  const SettingsLayoutGallery({super.key});

  @override
  State<SettingsLayoutGallery> createState() => _SettingsLayoutGalleryState();
}

final class _SettingsLayoutGalleryState extends State<SettingsLayoutGallery> {
  /// Which categories the APPLICATION announces as open. They are
  /// identities, and the laboratory is what changes them.
  Set<String> _open = const {settingsAccountId};

  static const Map<String, String> _names = {
    settingsAccountId: settingsAccountLabel,
    settingsSecurityId: settingsSecurityLabel,
    settingsNoticesId: settingsNoticesLabel,
  };

  // Three categories, all open, hold three ways in and three sets of
  // options: the frame is sized by the most it can ever show.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 16);

  void _ask(String id) {
    setState(() {
      _open = _open.contains(id)
          ? {
              for (final open in _open)
                if (open != id) open,
            }
          : {..._open, id};
    });
  }

  MentoraSettingsLayout shape({Key? key, required Set<String> open}) {
    return MentoraSettingsLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      categories: [
        for (final entry in _names.entries)
          MentoraSettingsCategory(
            id: entry.key,
            semanticLabel: entry.value,
            // The way in belongs to the components: the layout builds
            // no header, and reports nothing in their place.
            summary: MentoraListTile(
              key: Key('settings-summary-${entry.key}'),
              headline: entry.value,
              semanticLabel: entry.value,
              onTap: () => _ask(entry.key),
            ),
            options: MentoraCard(
              key: Key('settings-options-${entry.key}'),
              variant: MentoraCardVariant.surface,
              child: const MentoraInput(
                label: settingsOptionLabel,
                semanticLabel: settingsOptionLabel,
              ),
            ),
            unfolded: open.contains(entry.key),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: settingsLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-settings'), open: _open)),
          // Every category closed, then every one of them open: what is
          // closed is not hidden - it is not there.
          _scene(
            shape(key: const Key('layout-settings-closed'), open: const {}),
          ),
          _scene(
            shape(
              key: const Key('layout-settings-open'),
              open: _names.keys.toSet(),
            ),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(
                shape(key: Key('layout-settings-${variant.name}'), open: _open),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(
                shape(key: Key('layout-settings-${comfort.name}'), open: _open),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(
                shape(
                  key: Key('layout-settings-${direction.name}'),
                  open: _open,
                ),
              ),
            ),
          const _SettingsLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Settings Layout's living documentation - built only with Mentora
/// components.
final class _SettingsLayoutDocumentation extends StatelessWidget {
  const _SettingsLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('settings-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(settingsLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: settingsLayoutDocArchitecture,
            keyPrefix: 'settings-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: settingsLayoutDocResponsibilities,
            keyPrefix: 'settings-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: settingsLayoutDocComponents,
            keyPrefix: 'settings-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: settingsLayoutDocTokens,
            keyPrefix: 'settings-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: settingsLayoutDocEngines,
            keyPrefix: 'settings-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: settingsLayoutDocForbidden,
            keyPrefix: 'settings-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: settingsLayoutDocScans,
            keyPrefix: 'settings-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Wizard Layout catalogue - a work cut into steps, of
/// which exactly one is revealed. The laboratory announces the step:
/// the layout never moves to another on its own.
final class WizardLayoutGallery extends StatefulWidget {
  const WizardLayoutGallery({super.key});

  @override
  State<WizardLayoutGallery> createState() => _WizardLayoutGalleryState();
}

final class _WizardLayoutGalleryState extends State<WizardLayoutGallery> {
  /// Which step the APPLICATION announces. It is an identity, and the
  /// laboratory is the one that changes it.
  String _revealed = wizardStepIdentity;

  static const List<String> _steps = [
    wizardStepIdentity,
    wizardStepReach,
    wizardStepConfirmation,
  ];

  static const Map<String, String> _names = {
    wizardStepIdentity: wizardIdentityLabel,
    wizardStepReach: wizardReachLabel,
    wizardStepConfirmation: wizardConfirmationLabel,
  };

  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 8);

  MentoraWizardLayout shape({Key? key, required String revealed}) {
    return MentoraWizardLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      wizardId: 'travail',
      wizardSemanticLabel: wizardWorkLabel,
      revealedStepId: revealed,
      steps: [
        for (final step in _steps)
          MentoraIdentifiedContent(
            id: step,
            content: MentoraCard(
              key: Key('wizard-step-$step'),
              variant: MentoraCardVariant.surface,
              child: MentoraText(_names[step]!, role: MentoraTextRole.body),
            ),
          ),
      ],
      acts: [
        for (final step in _steps)
          MentoraButton(
            key: Key('wizard-ask-$step'),
            label: _names[step]!,
            // The act reports an intention; the answer is the
            // laboratory's, never the layout's.
            onPressed: () => setState(() => _revealed = step),
            size: MentoraButtonSize.small,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: wizardLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(
            shape(key: const Key('layout-shape-wizard'), revealed: _revealed),
          ),
          // Every step, announced one by one: the shape reveals what it
          // was told, and hides nothing - the others are not there.
          for (final step in _steps)
            _scene(shape(key: Key('layout-wizard-$step'), revealed: step)),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(
                shape(
                  key: Key('layout-wizard-${variant.name}'),
                  revealed: _revealed,
                ),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(
                shape(
                  key: Key('layout-wizard-${comfort.name}'),
                  revealed: _revealed,
                ),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(
                shape(
                  key: Key('layout-wizard-${direction.name}'),
                  revealed: _revealed,
                ),
              ),
            ),
          const _WizardLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Wizard Layout's living documentation - built only with Mentora
/// components.
final class _WizardLayoutDocumentation extends StatelessWidget {
  const _WizardLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('wizard-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(wizardLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: wizardLayoutDocArchitecture,
            keyPrefix: 'wizard-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: wizardLayoutDocResponsibilities,
            keyPrefix: 'wizard-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: wizardLayoutDocComponents,
            keyPrefix: 'wizard-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: wizardLayoutDocTokens,
            keyPrefix: 'wizard-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: wizardLayoutDocEngines,
            keyPrefix: 'wizard-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: wizardLayoutDocForbidden,
            keyPrefix: 'wizard-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: wizardLayoutDocScans,
            keyPrefix: 'wizard-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Feed Layout catalogue - the six regions of a page
/// built around a flow, and the flow made of components alone.
final class FeedLayoutGallery extends StatelessWidget {
  const FeedLayoutGallery({super.key});

  // Six regions ask for more room than a single one: the frame is
  // sized by what it shows.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 12);

  static MentoraLayoutZone zone(String label, Widget content) =>
      MentoraLayoutZone(semanticLabel: label, content: content);

  static Widget words(String heading) =>
      MentoraText(heading, role: MentoraTextRole.body);

  /// What an element of a flow is - built by components, never by the
  /// layout, and never counted by it.
  static Widget element(String id) => MentoraListTile(
    key: Key('feed-element-$id'),
    headline: feedElementName,
    supporting: feedElementSupporting,
    semanticLabel: feedElementName,
    leading: const MentoraAvatar(
      identity: MentoraAvatarIdentity.initials,
      name: feedElementName,
      initials: feedElementInitials,
    ),
  );

  static MentoraFeedLayout shape({Key? key, bool complete = true}) {
    return MentoraFeedLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      header: complete ? zone(feedHeaderLabel, words(feedHeaderLabel)) : null,
      introduction: complete
          ? zone(feedIntroductionLabel, words(layoutContentBody))
          : null,
      // The flow itself: a succession the application already decided,
      // handed on whole.
      feed: zone(
        feedFlowLabel,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [element('premier'), element('second')],
        ),
      ),
      supportingContent: complete
          ? zone(feedSupportingLabel, words(layoutContentBody))
          : null,
      actions: complete
          ? zone(
              feedActionsLabel,
              MentoraButton(
                label: feedActLabel,
                onPressed: () {},
                size: MentoraButtonSize.small,
              ),
            )
          : null,
      footer: complete ? zone(feedFooterLabel, words(layoutContentBody)) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: feedLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-feed'))),
          // The flow alone: every other region is optional.
          _scene(shape(key: const Key('layout-feed-bare'), complete: false)),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(shape(key: Key('layout-feed-${variant.name}'))),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(shape(key: Key('layout-feed-${comfort.name}'))),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(shape(key: Key('layout-feed-${direction.name}'))),
            ),
          const _FeedLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Feed Layout's living documentation - built only with Mentora
/// components.
final class _FeedLayoutDocumentation extends StatelessWidget {
  const _FeedLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('feed-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(feedLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: feedLayoutDocArchitecture,
            keyPrefix: 'feed-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: feedLayoutDocResponsibilities,
            keyPrefix: 'feed-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: feedLayoutDocComponents,
            keyPrefix: 'feed-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: feedLayoutDocTokens,
            keyPrefix: 'feed-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: feedLayoutDocEngines,
            keyPrefix: 'feed-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: feedLayoutDocForbidden,
            keyPrefix: 'feed-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: feedLayoutDocScans,
            keyPrefix: 'feed-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Detail Layout catalogue - the seven regions of a
/// consultation, in the official order, and nothing else.
final class DetailLayoutGallery extends StatelessWidget {
  const DetailLayoutGallery({super.key});

  // Seven regions ask for more room than a single one: the frame is
  // sized by what it shows.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 14);

  static MentoraLayoutZone zone(String label, Widget content) =>
      MentoraLayoutZone(semanticLabel: label, content: content);

  static Widget words(String heading) =>
      MentoraText(heading, role: MentoraTextRole.body);

  static MentoraDetailLayout shape({Key? key, bool complete = true}) {
    return MentoraDetailLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      hero: complete
          ? zone(
              detailHeroLabel,
              const MentoraAvatar(
                identity: MentoraAvatarIdentity.initials,
                name: detailIdentityName,
                initials: detailIdentityInitials,
              ),
            )
          : null,
      // What the thing IS: the only region kept when everything else
      // is taken away - a detail always informs.
      identity: zone(
        detailIdentityLabel,
        const MentoraBadge(
          variant: MentoraBadgeVariant.verified,
          label: detailMentionLabel,
          semanticLabel: detailMentionLabel,
        ),
      ),
      summary: complete
          ? zone(
              detailSummaryLabel,
              const MentoraCard(
                variant: MentoraCardVariant.surface,
                child: MentoraText(
                  layoutContentBody,
                  role: MentoraTextRole.body,
                ),
              ),
            )
          : null,
      details: complete
          ? zone(detailDetailsLabel, words(layoutContentBody))
          : null,
      supportingContent: complete
          ? zone(detailSupportingLabel, words(layoutContentBody))
          : null,
      actions: complete
          ? zone(
              detailActionsLabel,
              MentoraButton(
                label: detailActLabel,
                onPressed: () {},
                size: MentoraButtonSize.small,
              ),
            )
          : null,
      footer: complete
          ? zone(detailFooterLabel, words(layoutContentBody))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: detailLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-detail'))),
          // What the thing is, alone: every other region is optional.
          _scene(shape(key: const Key('layout-detail-bare'), complete: false)),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(shape(key: Key('layout-detail-${variant.name}'))),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(shape(key: Key('layout-detail-${comfort.name}'))),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(shape(key: Key('layout-detail-${direction.name}'))),
            ),
          const _DetailLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Detail Layout's living documentation - built only with Mentora
/// components.
final class _DetailLayoutDocumentation extends StatelessWidget {
  const _DetailLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('detail-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(detailLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: detailLayoutDocArchitecture,
            keyPrefix: 'detail-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: detailLayoutDocResponsibilities,
            keyPrefix: 'detail-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: detailLayoutDocComponents,
            keyPrefix: 'detail-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: detailLayoutDocTokens,
            keyPrefix: 'detail-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: detailLayoutDocEngines,
            keyPrefix: 'detail-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: detailLayoutDocForbidden,
            keyPrefix: 'detail-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: detailLayoutDocScans,
            keyPrefix: 'detail-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Form Layout catalogue - the six regions of the work,
/// in the official order, and the work alone.
final class FormLayoutGallery extends StatelessWidget {
  const FormLayoutGallery({super.key});

  static MentoraLayoutZone zone(String label, Widget content) =>
      MentoraLayoutZone(semanticLabel: label, content: content);

  // Six regions ask for more room than a single one: the frame is
  // sized by what it shows.
  static Widget _scene(Widget layout) => _LayoutScene.framed(layout, bands: 12);

  static Widget words(String heading) =>
      MentoraText(heading, role: MentoraTextRole.body);

  static MentoraFormLayout shape({Key? key, bool complete = true}) {
    return MentoraFormLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      header: complete ? zone(formHeaderLabel, words(formHeaderLabel)) : null,
      introduction: complete
          ? zone(formIntroductionLabel, words(layoutContentBody))
          : null,
      form: zone(
        formWorkLabel,
        MentoraCard(
          variant: MentoraCardVariant.surface,
          child: const MentoraInput(
            label: formFieldLabel,
            semanticLabel: formFieldLabel,
          ),
        ),
      ),
      supportingContent: complete
          ? zone(formSupportingLabel, words(layoutContentBody))
          : null,
      actions: complete
          ? zone(
              formActionsLabel,
              MentoraButton(
                label: formActLabel,
                onPressed: () {},
                size: MentoraButtonSize.small,
              ),
            )
          : null,
      footer: complete ? zone(formFooterLabel, words(layoutContentBody)) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: formLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scene(shape(key: const Key('layout-shape-form'))),
          // The work alone: every other region is optional.
          _scene(shape(key: const Key('layout-form-bare'), complete: false)),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _scene(shape(key: Key('layout-form-${variant.name}'))),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _scene(shape(key: Key('layout-form-${comfort.name}'))),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _scene(shape(key: Key('layout-form-${direction.name}'))),
            ),
          const _FormLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Form Layout's living documentation - built only with Mentora
/// components.
final class _FormLayoutDocumentation extends StatelessWidget {
  const _FormLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('form-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(formLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: formLayoutDocArchitecture,
            keyPrefix: 'form-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: formLayoutDocResponsibilities,
            keyPrefix: 'form-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: formLayoutDocComponents,
            keyPrefix: 'form-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: formLayoutDocTokens,
            keyPrefix: 'form-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: formLayoutDocEngines,
            keyPrefix: 'form-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: formLayoutDocForbidden,
            keyPrefix: 'form-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: formLayoutDocScans,
            keyPrefix: 'form-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Tabbed Content catalogue - one context, several
/// contents, exactly one revealed.
final class TabbedContentLayoutGallery extends StatefulWidget {
  const TabbedContentLayoutGallery({super.key});

  @override
  State<TabbedContentLayoutGallery> createState() =>
      _TabbedContentLayoutGalleryState();
}

final class _TabbedContentLayoutGalleryState
    extends State<TabbedContentLayoutGallery> {
  static Widget content(String heading) => MentoraCard(
    variant: MentoraCardVariant.surface,
    child: MentoraText(heading, role: MentoraTextRole.subtitle),
  );

  static List<MentoraIdentifiedContent> get contents => [
    MentoraIdentifiedContent(
      id: 'overview',
      content: content(layoutFirstPanel),
    ),
    MentoraIdentifiedContent(
      id: 'sessions',
      content: content(layoutSecondPanel),
    ),
  ];

  /// Which content the catalogue reveals. The gallery is the
  /// application here: the context only expresses what it is told.
  String _revealed = 'overview';

  MentoraTabbedContentLayout shape({Key? key, String? revealed}) {
    final shown = revealed ?? _revealed;
    return MentoraTabbedContentLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      facets: MentoraTabs(
        controller: MentoraTabsController(shown),
        tabs: _TabsGalleryState.facets,
        onTabSelected: (facet) => setState(() => _revealed = facet),
      ),
      contextId: 'contexte',
      contextSemanticLabel: tabbedContextLabel,
      contents: contents,
      revealedContentId: shown,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: tabbedLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The live context: the facets report, the catalogue decides,
          // and the context reveals what it was told.
          _LayoutScene.framed(shape(key: const Key('layout-shape-tabbed'))),
          // The other content, announced directly.
          _LayoutScene.framed(
            shape(key: const Key('layout-tabbed-other'), revealed: 'sessions'),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-tabbed-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(key: Key('layout-tabbed-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-tabbed-${direction.name}')),
              ),
            ),
          const _TabbedContentLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Tabbed Content Layout's living documentation - built only with
/// Mentora components.
final class _TabbedContentLayoutDocumentation extends StatelessWidget {
  const _TabbedContentLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('tabbed-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(tabbedLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: tabbedLayoutDocArchitecture,
            keyPrefix: 'tabbed-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: tabbedLayoutDocResponsibilities,
            keyPrefix: 'tabbed-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: tabbedLayoutDocComponents,
            keyPrefix: 'tabbed-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: tabbedLayoutDocTokens,
            keyPrefix: 'tabbed-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: tabbedLayoutDocEngines,
            keyPrefix: 'tabbed-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: tabbedLayoutDocForbidden,
            keyPrefix: 'tabbed-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: tabbedLayoutDocScans,
            keyPrefix: 'tabbed-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Grid Layout catalogue - cells standing exactly where
/// the catalogue announced them, and nowhere else.
final class GridLayoutGallery extends StatelessWidget {
  const GridLayoutGallery({super.key});

  /// The room the catalogue gives each cell. The application decides
  /// it; the grid only expresses it.
  static const double cellExtent = 160;

  static MentoraGridCell cell(String id, String heading) {
    return MentoraGridCell(
      id: id,
      extent: cellExtent,
      content: MentoraCard(
        variant: MentoraCardVariant.outlined,
        child: MentoraText(heading, role: MentoraTextRole.subtitle),
      ),
    );
  }

  static MentoraGridLayout shape({Key? key, bool wide = true}) {
    return MentoraGridLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      gridId: 'indicateurs',
      gridSemanticLabel: gridCollectionLabel,
      disposition: MentoraGridDisposition(
        rows: [
          MentoraGridRow(
            id: 'haut',
            cells: [
              cell('nord', layoutFirstPanel),
              if (wide) cell('est', layoutSecondPanel),
            ],
          ),
          MentoraGridRow(id: 'bas', cells: [cell('sud', layoutPageLabel)]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: gridLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(key: const Key('layout-shape-grid'))),
          // The same grid, announced with one cell fewer: the layout
          // deduces nothing - the disposition changed, that is all.
          _LayoutScene.framed(
            shape(key: const Key('layout-grid-narrow'), wide: false),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-grid-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(key: Key('layout-grid-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-grid-${direction.name}')),
              ),
            ),
          const _GridLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Grid Layout's living documentation - built only with Mentora
/// components.
final class _GridLayoutDocumentation extends StatelessWidget {
  const _GridLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('grid-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(gridLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: gridLayoutDocArchitecture,
            keyPrefix: 'grid-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: gridLayoutDocResponsibilities,
            keyPrefix: 'grid-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: gridLayoutDocComponents,
            keyPrefix: 'grid-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: gridLayoutDocTokens,
            keyPrefix: 'grid-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: gridLayoutDocEngines,
            keyPrefix: 'grid-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: gridLayoutDocForbidden,
            keyPrefix: 'grid-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: gridLayoutDocScans,
            keyPrefix: 'grid-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official List Layout catalogue - a sequence of elements, in the
/// order announced, with nothing added between them.
final class ListLayoutGallery extends StatelessWidget {
  const ListLayoutGallery({super.key});

  static MentoraListLayout shape({Key? key, int elements = 3}) {
    return MentoraListLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      listId: 'entites',
      listSemanticLabel: listCollectionLabel,
      items: [
        for (var element = 1; element <= elements; element++)
          MentoraIdentifiedContent(
            id: 'entite-$element',
            content: ListTileGallery.entity(
              key: Key('list-entity-$element'),
              composed: false,
              onTap: () {},
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: listLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(key: const Key('layout-shape-list'))),
          // A collection of one element is a collection.
          _LayoutScene.framed(
            shape(key: const Key('layout-list-single'), elements: 1),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-list-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(key: Key('layout-list-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-list-${direction.name}')),
              ),
            ),
          const _ListLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The List Layout's living documentation - built only with Mentora
/// components.
final class _ListLayoutDocumentation extends StatelessWidget {
  const _ListLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('list-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(listLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: listLayoutDocArchitecture,
            keyPrefix: 'list-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: listLayoutDocResponsibilities,
            keyPrefix: 'list-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: listLayoutDocComponents,
            keyPrefix: 'list-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: listLayoutDocTokens,
            keyPrefix: 'list-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: listLayoutDocEngines,
            keyPrefix: 'list-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: listLayoutDocForbidden,
            keyPrefix: 'list-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: listLayoutDocScans,
            keyPrefix: 'list-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Section Layout catalogue - logical units of content,
/// each announced once, with nothing added around them.
final class SectionLayoutGallery extends StatelessWidget {
  const SectionLayoutGallery({super.key});

  static MentoraSection section(
    String id,
    String title, {
    String? description,
  }) {
    return MentoraSection(
      id: id,
      title: title,
      description: description,
      content: MentoraCard(
        variant: MentoraCardVariant.surface,
        child: MentoraText(layoutContentBody, role: MentoraTextRole.body),
      ),
    );
  }

  static MentoraSectionLayout shape({Key? key, bool completed = true}) {
    return MentoraSectionLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      sections: [
        section(
          'resume',
          sectionFirstTitle,
          description: completed ? sectionDescription : null,
        ),
        section('echanges', sectionSecondTitle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: sectionLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(key: const Key('layout-shape-section'))),
          // A section that says nothing more than its name.
          _LayoutScene.framed(
            shape(key: const Key('layout-section-bare'), completed: false),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-section-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(key: Key('layout-section-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-section-${direction.name}')),
              ),
            ),
          const _SectionLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Section Layout's living documentation - built only with Mentora
/// components.
final class _SectionLayoutDocumentation extends StatelessWidget {
  const _SectionLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('section-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(sectionLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: sectionLayoutDocArchitecture,
            keyPrefix: 'section-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: sectionLayoutDocResponsibilities,
            keyPrefix: 'section-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: sectionLayoutDocComponents,
            keyPrefix: 'section-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: sectionLayoutDocTokens,
            keyPrefix: 'section-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: sectionLayoutDocEngines,
            keyPrefix: 'section-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: sectionLayoutDocForbidden,
            keyPrefix: 'section-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: sectionLayoutDocScans,
            keyPrefix: 'section-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Content Layout catalogue - the same regions, disposed
/// the official way, with nothing added between them.
final class ContentLayoutGallery extends StatelessWidget {
  const ContentLayoutGallery({super.key});

  static MentoraContentRegion region(String id, String heading) {
    return MentoraContentRegion(
      id: id,
      semanticLabel: heading,
      content: MentoraCard(
        variant: MentoraCardVariant.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MentoraText(heading, role: MentoraTextRole.subtitle),
            MentoraText(layoutContentBody, role: MentoraTextRole.body),
          ],
        ),
      ),
    );
  }

  static MentoraContentLayout shape({Key? key, int regions = 2}) {
    const headings = [
      contentFirstRegion,
      contentSecondRegion,
      contentThirdRegion,
    ];
    return MentoraContentLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      place: const MentoraAppBar(title: layoutPageLabel),
      regions: [
        for (final heading in headings.take(regions))
          region(heading.toLowerCase(), heading),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: contentLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(key: const Key('layout-shape-content'))),
          _LayoutScene.framed(
            shape(key: const Key('layout-content-three'), regions: 3),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-content-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(key: Key('layout-content-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-content-${direction.name}')),
              ),
            ),
          const _ContentLayoutDocumentation(),
        ],
      ),
    );
  }
}

/// The Content Layout's living documentation - built only with Mentora
/// components.
final class _ContentLayoutDocumentation extends StatelessWidget {
  const _ContentLayoutDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('content-layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(contentLayoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: contentLayoutDocArchitecture,
            keyPrefix: 'content-layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: contentLayoutDocResponsibilities,
            keyPrefix: 'content-layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: contentLayoutDocComponents,
            keyPrefix: 'content-layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: contentLayoutDocTokens,
            keyPrefix: 'content-layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: contentLayoutDocEngines,
            keyPrefix: 'content-layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: contentLayoutDocForbidden,
            keyPrefix: 'content-layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: contentLayoutDocScans,
            keyPrefix: 'content-layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Layouts catalogue - the five shapes a screen of
/// Mentora may take, each assembled by the family's single assembly.
final class _LayoutScene {
  const _LayoutScene();

  static const MentoraNavigationAnnouncement where =
      MentoraNavigationAnnouncement(destinationId: 'home');

  static MentoraLayoutContext frame({bool withNavigation = false}) {
    return MentoraLayoutContext(
      semanticLabel: layoutContextLabel,
      navigation: where,
      configuration: MentoraWorkspaceConfiguration(
        navigation: withNavigation
            ? MentoraWorkspaceNavigationChannel.base
            : MentoraWorkspaceNavigationChannel.none,
      ),
      base: withNavigation
          ? MentoraBottomNavigation(
              destinations: _BottomNavigationGalleryState.places(5),
              selectedDestinationId: 'home',
              semanticLabel: 'Navigation principale',
              onDestinationRequested: (_) {},
            )
          : null,
    );
  }

  static Widget get content =>
      MentoraText(layoutContentBody, role: MentoraTextRole.body);

  // A demonstration frame is sized by the number of bands the shape
  // shows, never by a single constant: a shape with six regions needs
  // more room than a shape with one, at every font scale.
  static Widget framed(Widget layout, {int bands = 6}) =>
      SizedBox(height: kMinInteractiveDimension * bands, child: layout);
}

final class WorkspaceLayoutGallery extends StatelessWidget {
  const WorkspaceLayoutGallery({super.key});

  static MentoraWorkspaceLayout shape({Key? key}) => MentoraWorkspaceLayout(
    key: key,
    frame: _LayoutScene.frame(),
    pageSemanticLabel: layoutPageLabel,
    place: const MentoraAppBar(title: layoutPageLabel),
    content: _LayoutScene.content,
  );

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: workspaceLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(key: const Key('layout-shape-workspace'))),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: _LayoutScene.framed(
                shape(key: Key('layout-workspace-${variant.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: _LayoutScene.framed(
                shape(key: Key('layout-workspace-${direction.name}')),
              ),
            ),
          const _LayoutFamilyDocumentation(),
        ],
      ),
    );
  }
}

final class DashboardLayoutGallery extends StatelessWidget {
  const DashboardLayoutGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget shape(Key key) => MentoraDashboardLayout(
      key: key,
      frame: _LayoutScene.frame(),
      pageSemanticLabel: layoutPageLabel,
      panels: [
        MentoraDashboardPanel(
          title: layoutFirstPanel,
          content: _LayoutScene.content,
          acts: [
            MentoraButton(
              label: layoutPanelAct,
              onPressed: () {},
              variant: MentoraButtonVariant.text,
              size: MentoraButtonSize.small,
            ),
          ],
        ),
        MentoraDashboardPanel(
          title: layoutSecondPanel,
          content: _LayoutScene.content,
        ),
      ],
    );

    return GallerySection(
      title: dashboardLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(shape(const Key('layout-shape-dashboard'))),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: _LayoutScene.framed(
                shape(Key('layout-dashboard-${comfort.name}')),
              ),
            ),
        ],
      ),
    );
  }
}

final class NavigationLayoutGallery extends StatelessWidget {
  const NavigationLayoutGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: navigationLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(
            MentoraNavigationLayout(
              key: const Key('layout-shape-navigation'),
              frame: _LayoutScene.frame(withNavigation: true),
              pageSemanticLabel: layoutPageLabel,
              content: _LayoutScene.content,
            ),
          ),
        ],
      ),
    );
  }
}

final class SplitWorkspaceLayoutGallery extends StatelessWidget {
  const SplitWorkspaceLayoutGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: splitWorkspaceLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(
            MentoraSplitWorkspaceLayout(
              key: const Key('layout-shape-split-workspace'),
              frame: _LayoutScene.frame(),
              regions: _SplitViewGalleryState.regions(),
              specification: _SplitViewGalleryState.specification(),
            ),
          ),
        ],
      ),
    );
  }
}

final class MasterDetailLayoutGallery extends StatelessWidget {
  const MasterDetailLayoutGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: masterDetailLayoutGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayoutScene.framed(
            MentoraMasterDetailLayout(
              key: const Key('layout-shape-master-detail'),
              frame: _LayoutScene.frame(),
              master: _MasterDetailGalleryState.master,
              detail: _MasterDetailGalleryState.detail,
              specification: _MasterDetailGalleryState.layout,
              masterSemanticLabel: masterDetailMasterLabel,
              detailSemanticLabel: masterDetailDetailLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Layout family's living documentation - built only with Mentora
/// components.
final class _LayoutFamilyDocumentation extends StatelessWidget {
  const _LayoutFamilyDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('layout-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(layoutDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: layoutDocHierarchyTitle,
            lines: layoutDocHierarchy,
            keyPrefix: 'layout-doc-hierarchy',
          ),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: layoutDocArchitecture,
            keyPrefix: 'layout-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: layoutDocResponsibilities,
            keyPrefix: 'layout-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: layoutDocComponents,
            keyPrefix: 'layout-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: layoutDocTokens,
            keyPrefix: 'layout-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: layoutDocEngines,
            keyPrefix: 'layout-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: layoutDocForbidden,
            keyPrefix: 'layout-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: layoutDocScans,
            keyPrefix: 'layout-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official narrow adaptation catalogue - the SAME entity, in
/// every room, giving up in the official order and never its name.
final class NarrowAdaptationGallery extends StatelessWidget {
  const NarrowAdaptationGallery({super.key});

  /// The rooms the catalogue presents, from the narrowest upward.
  static const List<double> rooms = [180, 220, 260, 300, 340, 370, 420, 480];

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget entityIn(double room, {String? suffix}) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width: room,
        child: ListTileGallery.entity(
          key: Key('narrow-${suffix ?? ''}${room.toInt()}'),
          onTap: () {},
        ),
      ),
    );

    return GallerySection(
      title: narrowAdaptationGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final room in rooms) entityIn(room),
          // The same descent, read from the other side.
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: entityIn(220, suffix: '${direction.name}-'),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: entityIn(220, suffix: '${comfort.name}-'),
            ),
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: entityIn(220, suffix: '${variant.name}-'),
            ),
        ],
      ),
    );
  }
}

/// The official Workspaces catalogue - every navigation channel,
/// every official surface, and the layers mounted only when their
/// service is given.
final class WorkspaceGallery extends StatefulWidget {
  const WorkspaceGallery({super.key});

  @override
  State<WorkspaceGallery> createState() => _WorkspaceGalleryState();
}

final class _WorkspaceGalleryState extends State<WorkspaceGallery> {
  static const String homeId = 'home';

  static Widget framed(Widget workspace) =>
      SizedBox(height: kMinInteractiveDimension * 6, child: workspace);

  static MentoraPageScaffold get page => MentoraPageScaffold(
    semanticLabel: workspacePageLabel,
    content: MentoraCard(
      variant: MentoraCardVariant.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(workspaceHeading, role: MentoraTextRole.subtitle),
          MentoraText(workspaceBody, role: MentoraTextRole.body),
        ],
      ),
    ),
  );

  static MentoraBottomNavigation get base => MentoraBottomNavigation(
    destinations: _BottomNavigationGalleryState.places(5),
    selectedDestinationId: homeId,
    semanticLabel: 'Navigation principale',
    onDestinationRequested: (_) {},
  );

  static MentoraNavigationRail get rail => MentoraNavigationRail(
    destinations: _NavigationRailGalleryState.places,
    controller: MentoraNavigationRailController(homeId),
    onDestinationSelected: (_) {},
  );

  static MentoraNavigationDrawer get orientation => MentoraNavigationDrawer(
    controller: MentoraNavigationDrawerController(
      selectedId: homeId,
      visibility: MentoraDrawerVisibility.opened,
    ),
    sections: _NavigationDrawerGalleryState.sections,
    semanticLabel: 'Espace de Awa Mensah',
    onDestinationSelected: (_) {},
  );

  static MentoraWorkspace workspace({
    Key? key,
    required MentoraWorkspaceSurface surface,
    MentoraWorkspaceNavigationChannel channel =
        MentoraWorkspaceNavigationChannel.none,
  }) {
    return MentoraWorkspace(
      key: key,
      semanticLabel: workspaceLabel,
      configuration: MentoraWorkspaceConfiguration(navigation: channel),
      navigation: const MentoraNavigationAnnouncement(destinationId: homeId),
      base: channel == MentoraWorkspaceNavigationChannel.base ? base : null,
      rail: channel == MentoraWorkspaceNavigationChannel.rail ? rail : null,
      orientation: channel == MentoraWorkspaceNavigationChannel.orientation
          ? orientation
          : null,
      surface: surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget scene(
      String name, {
      MentoraWorkspaceNavigationChannel channel =
          MentoraWorkspaceNavigationChannel.none,
      MentoraWorkspaceSurface? surface,
    }) {
      return framed(
        workspace(
          key: Key('workspace-$name'),
          channel: channel,
          surface: surface ?? MentoraWorkspaceSurface.page(page),
        ),
      );
    }

    return GallerySection(
      title: workspaceGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The four channels the application may announce.
          scene('channel-none'),
          scene(
            'channel-base',
            channel: MentoraWorkspaceNavigationChannel.base,
          ),
          scene(
            'channel-rail',
            channel: MentoraWorkspaceNavigationChannel.rail,
          ),
          scene(
            'channel-orientation',
            channel: MentoraWorkspaceNavigationChannel.orientation,
          ),
          // The three official surfaces - exactly one at a time.
          scene(
            'surface-shared',
            surface: MentoraWorkspaceSurface.shared(
              MentoraSplitView(
                regions: _SplitViewGalleryState.regions(),
                layout: _SplitViewGalleryState.specification(),
              ),
            ),
          ),
          scene(
            'surface-relation',
            surface: MentoraWorkspaceSurface.relation(
              _MasterDetailGalleryState.relation(),
            ),
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: scene('theme-${variant.name}'),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: scene('comfort-${comfort.name}'),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: scene('direction-${direction.name}'),
            ),
          const _WorkspaceDocumentation(),
        ],
      ),
    );
  }
}

/// The Workspace's living documentation - built only with Mentora
/// components.
final class _WorkspaceDocumentation extends StatelessWidget {
  const _WorkspaceDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('workspace-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(workspaceDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: workspaceDocArchitecture,
            keyPrefix: 'workspace-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: workspaceDocResponsibilities,
            keyPrefix: 'workspace-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: workspaceDocComponents,
            keyPrefix: 'workspace-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: workspaceDocTokens,
            keyPrefix: 'workspace-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: workspaceDocEngines,
            keyPrefix: 'workspace-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: workspaceDocForbidden,
            keyPrefix: 'workspace-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: workspaceDocScans,
            keyPrefix: 'workspace-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Split Views catalogue - both axes, regions announced
/// by identity, fixed and movable separations, and a live workspace
/// where the catalogue itself decides what the component reports.
final class SplitViewGallery extends StatefulWidget {
  const SplitViewGallery({super.key});

  @override
  State<SplitViewGallery> createState() => _SplitViewGalleryState();
}

final class _SplitViewGalleryState extends State<SplitViewGallery> {
  static const String navigationId = 'navigation';
  static const String workspaceId = 'workspace';
  static const String inspectorId = 'inspector';

  static Widget framed(Widget workspace) =>
      SizedBox(height: kMinInteractiveDimension * 6, child: workspace);

  static Widget space(String heading) => MentoraCard(
    variant: MentoraCardVariant.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(heading, role: MentoraTextRole.subtitle),
        MentoraText(splitViewContentBody, role: MentoraTextRole.body),
      ],
    ),
  );

  static MentoraSplitRegion region(
    String id,
    String semanticLabel,
    String heading, {
    MentoraSplitRegionVisibility visibility =
        MentoraSplitRegionVisibility.shown,
  }) {
    return MentoraSplitRegion(
      id: id,
      semanticLabel: semanticLabel,
      content: space(heading),
      visibility: visibility,
      resizeSemanticLabel: splitViewResizeLabel,
    );
  }

  static List<MentoraSplitRegion> regions({
    MentoraSplitRegionVisibility inspector = MentoraSplitRegionVisibility.shown,
  }) => [
    region(navigationId, splitViewNavigationLabel, splitViewNavigationHeading),
    region(workspaceId, splitViewWorkspaceLabel, splitViewWorkspaceHeading),
    region(
      inspectorId,
      splitViewInspectorLabel,
      splitViewInspectorHeading,
      visibility: inspector,
    ),
  ];

  static MentoraSplitLayoutSpecification specification({
    MentoraSplitAxis axis = MentoraSplitAxis.horizontal,
    double navigation = 240,
    double inspector = 280,
  }) {
    return MentoraSplitLayoutSpecification(
      axis: axis,
      extents: {navigationId: navigation, inspectorId: inspector},
      fillsRemainingRegionId: workspaceId,
    );
  }

  /// The room the catalogue announces, and the visibility it decides.
  /// The gallery is the application here: the workspace only reports.
  double _navigationExtent = 240;
  MentoraSplitRegionVisibility _inspector = MentoraSplitRegionVisibility.shown;

  void _apply(MentoraSplitResizeIntention intention) {
    if (intention.regionId != navigationId) return;
    setState(() {
      _navigationExtent = (_navigationExtent + intention.delta).clamp(
        splitViewMinimumRegionExtent,
        splitViewMinimumRegionExtent * 3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    Widget scene(
      String name, {
      MentoraSplitAxis axis = MentoraSplitAxis.horizontal,
      MentoraSplitRegionVisibility inspector =
          MentoraSplitRegionVisibility.shown,
      ValueChanged<MentoraSplitResizeIntention>? onResizeRequested,
    }) {
      return framed(
        MentoraSplitView(
          key: Key('split-view-$name'),
          regions: regions(inspector: inspector),
          layout: specification(axis: axis),
          onResizeRequested: onResizeRequested,
        ),
      );
    }

    return GallerySection(
      title: splitViewGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed separations: they say that regions exist, and offer
          // nothing else.
          scene('fixed'),
          // Movable separations: what a person asks for is reported.
          scene('movable', onResizeRequested: (_) {}),
          // The other axis, announced by the application.
          scene('vertical', axis: MentoraSplitAxis.vertical),
          // A hidden region does not exist at all.
          scene('hidden', inspector: MentoraSplitRegionVisibility.hidden),
          // The live workspace: the component reports, the catalogue
          // decides, and the announced room follows.
          framed(
            MentoraSplitView(
              key: const Key('split-view-live'),
              regions: regions(inspector: _inspector),
              layout: specification(navigation: _navigationExtent),
              onResizeRequested: _apply,
            ),
          ),
          MentoraButton(
            key: const Key('split-view-visibility-toggle'),
            label: _inspector == MentoraSplitRegionVisibility.shown
                ? splitViewHideLabel
                : splitViewShowLabel,
            onPressed: () => setState(() {
              _inspector = _inspector == MentoraSplitRegionVisibility.shown
                  ? MentoraSplitRegionVisibility.hidden
                  : MentoraSplitRegionVisibility.shown;
            }),
            variant: MentoraButtonVariant.text,
            size: MentoraButtonSize.small,
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: scene('theme-${variant.name}'),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: scene('comfort-${comfort.name}'),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: scene('direction-${direction.name}'),
            ),
          const _SplitViewDocumentation(),
        ],
      ),
    );
  }
}

/// The Split View's living documentation - built only with Mentora
/// components.
final class _SplitViewDocumentation extends StatelessWidget {
  const _SplitViewDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('split-view-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(splitViewDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: splitViewDocArchitecture,
            keyPrefix: 'split-view-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: splitViewDocResponsibilities,
            keyPrefix: 'split-view-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: splitViewDocComponents,
            keyPrefix: 'split-view-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: splitViewDocTokens,
            keyPrefix: 'split-view-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: splitViewDocEngines,
            keyPrefix: 'split-view-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: splitViewDocForbidden,
            keyPrefix: 'split-view-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: splitViewDocScans,
            keyPrefix: 'split-view-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The official Master Details catalogue - every presentation, every
/// visibility and both regions of the REAL relation.
final class MasterDetailGallery extends StatefulWidget {
  const MasterDetailGallery({super.key});

  @override
  State<MasterDetailGallery> createState() => _MasterDetailGalleryState();
}

final class _MasterDetailGalleryState extends State<MasterDetailGallery> {
  static void _noop() {}

  /// The room the two spaces take - decided here, by the application
  /// that owns the catalogue, and never by the relation.
  static const MentoraMasterDetailLayoutSpecification layout =
      MentoraMasterDetailLayoutSpecification(masterExtent: 240);

  static Widget framed(Widget relation) =>
      SizedBox(height: kMinInteractiveDimension * 6, child: relation);

  /// The space that presents: entities, and nothing else.
  static Widget get master => MentoraCard(
    variant: MentoraCardVariant.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(masterDetailMasterHeading, role: MentoraTextRole.subtitle),
        // A presenting space is narrow by nature: the entity is shown
        // compact, as a real conversation list shows it.
        ListTileGallery.entity(onTap: _noop, composed: false),
      ],
    ),
  );

  /// The space that deepens: what one entity carries.
  static Widget get detail => MentoraCard(
    variant: MentoraCardVariant.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoraText(masterDetailDetailHeading, role: MentoraTextRole.subtitle),
        MentoraText(masterDetailDetailBody, role: MentoraTextRole.body),
        MentoraButton(
          label: masterDetailDetailAct,
          onPressed: _noop,
          size: MentoraButtonSize.small,
        ),
      ],
    ),
  );

  static MentoraMasterDetail relation({
    Key? key,
    MentoraMasterDetailPresentation presentation =
        MentoraMasterDetailPresentation.split,
    MentoraMasterPaneVisibility visibility = MentoraMasterPaneVisibility.shown,
    MentoraMasterDetailRegion activeRegion = MentoraMasterDetailRegion.detail,
    VoidCallback? onDismissRequested,
  }) {
    return MentoraMasterDetail(
      key: key,
      master: master,
      detail: detail,
      layout: layout,
      presentation: presentation,
      visibility: visibility,
      activeRegion: activeRegion,
      masterSemanticLabel: masterDetailMasterLabel,
      detailSemanticLabel: masterDetailDetailLabel,
      onDismissRequested: onDismissRequested,
    );
  }

  /// Which space the catalogue says is being worked in - the gallery
  /// is the application here: the relation only expresses it.
  MentoraMasterDetailRegion _activeRegion = MentoraMasterDetailRegion.master;

  @override
  Widget build(BuildContext context) {
    final scope = DesignKitScope.of(context);

    return GallerySection(
      title: masterDetailGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The presenting space alone: one space at a time.
          framed(
            relation(
              key: const Key('master-detail-stacked-master'),
              presentation: MentoraMasterDetailPresentation.stacked,
              activeRegion: MentoraMasterDetailRegion.master,
            ),
          ),
          // The deepening space alone: the presenting one was put away.
          framed(
            relation(
              key: const Key('master-detail-stacked-detail'),
              presentation: MentoraMasterDetailPresentation.stacked,
              visibility: MentoraMasterPaneVisibility.hidden,
            ),
          ),
          // The two spaces, side by side.
          framed(relation(key: const Key('master-detail-split'))),
          framed(
            relation(
              key: const Key('master-detail-split-hidden'),
              visibility: MentoraMasterPaneVisibility.hidden,
            ),
          ),
          // The presenting space passes in front of the other.
          framed(
            relation(
              key: const Key('master-detail-overlay'),
              presentation: MentoraMasterDetailPresentation.overlay,
              activeRegion: MentoraMasterDetailRegion.master,
              onDismissRequested: _noop,
            ),
          ),
          framed(
            relation(
              key: const Key('master-detail-overlay-hidden'),
              presentation: MentoraMasterDetailPresentation.overlay,
              visibility: MentoraMasterPaneVisibility.hidden,
              onDismissRequested: _noop,
            ),
          ),
          // The live scene: the region worked in changes, announced by
          // the application - the ground follows, nothing else moves.
          framed(
            relation(
              key: const Key('master-detail-live'),
              activeRegion: _activeRegion,
            ),
          ),
          MentoraButton(
            key: const Key('master-detail-region-toggle'),
            label: masterDetailRegionToggleLabel,
            onPressed: () => setState(() {
              _activeRegion = _activeRegion == MentoraMasterDetailRegion.master
                  ? MentoraMasterDetailRegion.detail
                  : MentoraMasterDetailRegion.master;
            }),
            variant: MentoraButtonVariant.text,
            size: MentoraButtonSize.small,
          ),
          // The four theme variants, high contrasts included.
          for (final variant in ThemeVariantId.values)
            DesignKitScope.deriving(
              scope,
              variant: variant,
              child: framed(
                relation(key: Key('master-detail-theme-${variant.name}')),
              ),
            ),
          for (final comfort in ReadingComfortPreference.values)
            DesignKitScope.deriving(
              scope,
              appearance: scope.appearance.copyWith(readingComfort: comfort),
              child: framed(
                relation(key: Key('master-detail-comfort-${comfort.name}')),
              ),
            ),
          for (final direction in TextDirection.values)
            Directionality(
              textDirection: direction,
              child: framed(
                relation(key: Key('master-detail-direction-${direction.name}')),
              ),
            ),
          const _MasterDetailDocumentation(),
        ],
      ),
    );
  }
}

/// The Master Detail's living documentation - built only with Mentora
/// components.
final class _MasterDetailDocumentation extends StatelessWidget {
  const _MasterDetailDocumentation();

  @override
  Widget build(BuildContext context) {
    return MentoraCard(
      key: const Key('master-detail-doc'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(masterDetailDocHeading, role: MentoraTextRole.subtitle),
          const _DocumentationSection(
            title: inputDocArchitectureTitle,
            lines: masterDetailDocArchitecture,
            keyPrefix: 'master-detail-doc-architecture',
          ),
          const _DocumentationSection(
            title: inputDocResponsibilitiesTitle,
            lines: masterDetailDocResponsibilities,
            keyPrefix: 'master-detail-doc-responsibility',
          ),
          const _DocumentationSection(
            title: listTileDocComponentsTitle,
            lines: masterDetailDocComponents,
            keyPrefix: 'master-detail-doc-component',
          ),
          const _DocumentationSection(
            title: textDocTokensTitle,
            lines: masterDetailDocTokens,
            keyPrefix: 'master-detail-doc-token',
          ),
          const _DocumentationSection(
            title: textDocEnginesTitle,
            lines: masterDetailDocEngines,
            keyPrefix: 'master-detail-doc-engine',
          ),
          const _DocumentationSection(
            title: textDocForbiddenTitle,
            lines: masterDetailDocForbidden,
            keyPrefix: 'master-detail-doc-forbidden',
          ),
          const _DocumentationSection(
            title: inputDocScansTitle,
            lines: masterDetailDocScans,
            keyPrefix: 'master-detail-doc-scan',
          ),
        ],
      ),
    );
  }
}

/// The responsive contexts — each representative size classified live
/// by the official engine.
final class ResponsiveGallery extends StatelessWidget {
  final ResponsiveEngine responsive;

  const ResponsiveGallery({super.key, required this.responsive});

  static const Map<String, Size> _representativeSizes = {
    'wearable': Size(250, 280),
    'phone': Size(390, 844),
    'foldable': Size(650, 840),
    'tablet': Size(800, 1280),
    'desktop': Size(1600, 1050),
    'tv': Size(3840, 2160),
  };

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: responsiveGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in _representativeSizes.entries)
            MentoraText(
              '${entry.key} → ${responsive.resolve(entry.value).name}',
              key: Key('responsive-${entry.key}'),
              role: MentoraTextRole.caption,
            ),
        ],
      ),
    );
  }
}
