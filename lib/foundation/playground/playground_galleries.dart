import 'package:flutter/material.dart';

import '../design_kit/components/button/mentora_button.dart';
import '../design_kit/components/button/mentora_button_style.dart';
import '../design_kit/components/card/mentora_card.dart';
import '../design_kit/components/card/mentora_card_style.dart';
import '../design_kit/components/design_kit_scope.dart';
import '../design_kit/components/dialog/mentora_dialog.dart';
import '../design_kit/components/dialog/mentora_dialog_request.dart';
import '../design_kit/components/dialog/mentora_dialog_service.dart';
import '../design_kit/components/dialog/mentora_dialog_style.dart';
import '../design_kit/components/input/mentora_input.dart';
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
