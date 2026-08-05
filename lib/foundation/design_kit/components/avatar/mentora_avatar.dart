import 'package:flutter/material.dart';

import '../../tokens/avatar_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text.dart';
import 'mentora_avatar_style.dart';
import 'mentora_avatar_theme.dart';

/// The official Mentora avatar — the identity language of the product.
///
/// It represents a person, an organisation, an intelligence or the
/// system itself. It is never a decoration, never an illustration, and
/// never a circle that happens to hold a picture: **the identity
/// always survives the absence of an image** — a portrait gives way to
/// initials, initials give way to the identity's own mark, and the
/// name is always announced.
///
/// It stays deliberately pure: it carries no act, no presence, no
/// verification, no premium, no counter and no badge. Those are
/// decorators, and decorators are composed around it — never inside.
final class MentoraAvatar extends StatefulWidget {
  final MentoraAvatarIdentity identity;
  final MentoraAvatarShape shape;
  final MentoraAvatarSize size;

  /// Who this is. The application owns every string (Localization
  /// Engine); the Kit composes none — and an identity that cannot be
  /// announced is not an identity: this is required.
  final String name;

  /// The initials the application derived — deriving them from a name
  /// is a language-sensitive rule, and rules are business.
  final String? initials;

  /// The portrait, when there is one. Its absence — or its failure —
  /// is never an error: the identity simply speaks otherwise.
  final ImageProvider? portrait;

  /// What the screen reader hears, when it must carry more than the
  /// name: the identity, its type and its context.
  final String? semanticLabel;

  /// The resting state, when it never changes.
  final MentoraAvatarState state;

  /// The state over time, when the application makes it change. It
  /// prevails over [state]: one truth, announced from outside.
  final MentoraAvatarController? controller;

  const MentoraAvatar({
    super.key,
    required this.identity,
    required this.name,
    this.shape = MentoraAvatarShape.circle,
    this.size = MentoraAvatarSize.medium,
    this.initials,
    this.portrait,
    this.semanticLabel,
    this.state = MentoraAvatarState.idle,
    this.controller,
  });

  @override
  State<MentoraAvatar> createState() => _MentoraAvatarState();
}

final class _MentoraAvatarState extends State<MentoraAvatar> {
  /// A portrait that failed is not an error: it is simply a portrait
  /// that will not be shown.
  bool _portraitFailed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onStateAnnounced);
  }

  @override
  void didUpdateWidget(MentoraAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStateAnnounced);
      widget.controller?.addListener(_onStateAnnounced);
    }
    if (oldWidget.portrait != widget.portrait) _portraitFailed = false;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onStateAnnounced);
    super.dispose();
  }

  void _onStateAnnounced() {
    if (mounted) setState(() {});
  }

  MentoraAvatarState get _effectiveState =>
      widget.controller?.state ?? widget.state;

  /// What the screen reader will say. Never "image": an identity that
  /// cannot be announced is not an identity.
  String _announcement() {
    final spoken = widget.semanticLabel ?? widget.name;
    if (spoken.isEmpty) {
      throw StateError(
        'An avatar announces who it represents: an identity that '
        'cannot be named is not an identity.',
      );
    }
    return spoken;
  }

  bool get _showsPortrait =>
      widget.portrait != null &&
      !_portraitFailed &&
      acceptsPortrait(widget.identity) &&
      _effectiveState != MentoraAvatarState.loading;

  bool get _showsInitials {
    final initials = widget.initials;
    return initials != null &&
        initials.isNotEmpty &&
        acceptsInitials(widget.identity) &&
        _effectiveState != MentoraAvatarState.loading;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraAvatarTheme.fromScope(DesignKitScope.of(context));
    final state = _effectiveState;
    final visuals = theme.visualsOf(identity: widget.identity, state: state);
    final spec = theme.specOf(widget.size);
    final radius = theme.radiusOf(widget.shape, widget.size);
    final announcement = _announcement();

    return Semantics(
      container: true,
      // A portrait is an image — but it is never announced as one
      // alone: the identity always comes with it.
      image: _showsPortrait,
      label: announcement,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: visuals.opacity,
          child: AnimatedContainer(
            duration: theme.transitionDuration,
            curve: theme.curve,
            width: spec.extent,
            height: spec.extent,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: visuals.ground,
              borderRadius: radius,
              border: Border.all(
                color: visuals.border,
                width: avatarBorderWidth,
              ),
            ),
            child: Center(child: _representation(theme, spec, state, visuals)),
          ),
        ),
      ),
    );
  }

  Widget _representation(
    MentoraAvatarTheme theme,
    AvatarSizeSpec spec,
    MentoraAvatarState state,
    MentoraAvatarVisuals visuals,
  ) {
    if (state == MentoraAvatarState.loading) {
      return SizedBox(
        width: spec.markSize,
        height: spec.markSize,
        child: CircularProgressIndicator(
          strokeWidth: avatarProgressStroke,
          color: visuals.accent,
        ),
      );
    }

    if (_showsPortrait) {
      return Image(
        image: widget.portrait!,
        width: spec.extent,
        height: spec.extent,
        fit: BoxFit.cover,
        // The identity survives: a portrait that cannot be shown hands
        // over to the initials, then to the identity's own mark.
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_portraitFailed) {
              setState(() => _portraitFailed = true);
            }
          });
          return _withoutPortrait(theme, spec, state, visuals);
        },
      );
    }

    return _withoutPortrait(theme, spec, state, visuals);
  }

  Widget _withoutPortrait(
    MentoraAvatarTheme theme,
    AvatarSizeSpec spec,
    MentoraAvatarState state,
    MentoraAvatarVisuals visuals,
  ) {
    if (_showsInitials) {
      return MentoraText(
        widget.initials!,
        role: theme.initialsRoleOf(widget.size),
        color: theme.initialsColorRoleOf(
          identity: widget.identity,
          state: state,
        ),
        maxLines: 1,
      );
    }

    return Icon(
      theme.markOf(widget.identity),
      size: spec.markSize,
      color: visuals.accent,
    );
  }
}
