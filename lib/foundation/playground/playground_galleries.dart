import 'package:flutter/material.dart';

import '../design_kit/components/button/mentora_button.dart';
import '../design_kit/components/button/mentora_button_style.dart';
import '../design_kit/components/card/mentora_card.dart';
import '../design_kit/components/card/mentora_card_style.dart';
import '../design_kit/structure/app_bar/mentora_app_bar.dart';
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

  static const List<MentoraNavigationRailDestination> places = [
    MentoraNavigationRailDestination(
      id: 'home',
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    MentoraNavigationRailDestination(
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
    MentoraNavigationRailDestination(
      id: 'business',
      label: 'Activité',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
    MentoraNavigationRailDestination(
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
