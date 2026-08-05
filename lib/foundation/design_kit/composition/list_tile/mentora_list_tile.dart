import 'package:flutter/material.dart';

import '../../components/avatar/mentora_avatar.dart';
import '../../components/badge/mentora_badge.dart';
import '../../components/button/mentora_button.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/list_tile_tokens.dart';
import 'mentora_list_tile_style.dart';
import 'mentora_list_tile_theme.dart';

/// The official Mentora tile — the representation of an ENTITY.
///
/// A line does not exist. A person exists, a consultation exists, a
/// company exists, an invoice exists. This component always presents
/// something that exists — never a layout.
///
/// It is the first Composition Component: it **composes and never
/// redefines**. Its zones are typed, so the authority of every Core
/// Component is guaranteed by the compiler and not merely by a scan:
/// the identity is a [MentoraAvatar], the states are [MentoraBadge]s,
/// the act is a [MentoraButton], and every word is a [MentoraText].
/// The tile styles none of them.
final class MentoraListTile extends StatefulWidget {
  /// The identity of the entity — the Avatar remains its owner.
  final MentoraAvatar? leading;

  /// What the entity is called. An entity that cannot be named is not
  /// an entity: this is required.
  final String headline;

  /// What completes the name.
  final String? supporting;

  /// The facts that situate the entity — a time, a reference.
  final String? metadata;

  /// The states of the entity — the Badge remains their owner.
  final List<MentoraBadge> badges;

  /// The act offered on the entity — the Button remains its owner.
  final MentoraButton? trailing;

  /// What closes the entity, when something must be said under it.
  final String? footer;

  final MentoraListTileDensity density;
  final MentoraListTileChrome chrome;

  /// The act the whole entity invites, when it invites one. Its
  /// presence is what makes a tile interactive — never a variant.
  final VoidCallback? onTap;

  /// What the screen reader hears when the entity must be announced
  /// as one sentence the application composed itself.
  final String? semanticLabel;

  /// The state of the entity over time, announced from outside.
  final MentoraListTileController? controller;

  const MentoraListTile({
    super.key,
    required this.headline,
    this.leading,
    this.supporting,
    this.metadata,
    this.badges = const [],
    this.trailing,
    this.footer,
    this.density = MentoraListTileDensity.standard,
    this.chrome = MentoraListTileChrome.plain,
    this.onTap,
    this.semanticLabel,
    this.controller,
  });

  @override
  State<MentoraListTile> createState() => _MentoraListTileState();
}

final class _MentoraListTileState extends State<MentoraListTile> {
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onStatusAnnounced);
  }

  @override
  void didUpdateWidget(MentoraListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStatusAnnounced);
      widget.controller?.addListener(_onStatusAnnounced);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onStatusAnnounced);
    super.dispose();
  }

  void _onStatusAnnounced() {
    if (mounted) setState(() {});
  }

  MentoraListTileStatus get _status =>
      widget.controller?.status ?? MentoraListTileStatus.idle;

  bool get _actionable =>
      widget.onTap != null &&
      _status != MentoraListTileStatus.disabled &&
      _status != MentoraListTileStatus.loading;

  /// Exactly one effective state: what the application announced about
  /// the entity, then the focus, then the pointer.
  MentoraListTileState get _effectiveState {
    switch (_status) {
      case MentoraListTileStatus.disabled:
        return MentoraListTileState.disabled;
      case MentoraListTileStatus.loading:
        return MentoraListTileState.loading;
      case MentoraListTileStatus.archived:
        return MentoraListTileState.archived;
      case MentoraListTileStatus.selected:
        return MentoraListTileState.selected;
      case MentoraListTileStatus.idle:
        break;
    }
    if (_focused) return MentoraListTileState.focused;
    if (_hovered) return MentoraListTileState.hovered;
    return MentoraListTileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraListTileTheme.fromScope(DesignKitScope.of(context));
    if (widget.headline.isEmpty) {
      throw StateError(
        'A tile presents an entity: an entity that cannot be named is '
        'not an entity.',
      );
    }

    final state = _effectiveState;
    final visuals = theme.visualsOf(chrome: widget.chrome, state: state);
    final radius = BorderRadius.circular(listTileCornerRadius);

    Widget body = Padding(
      padding: theme.paddingOf(widget.density),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                SizedBox(width: theme.gapOf(widget.density)),
              ],
              Expanded(child: _words(theme)),
              ..._aside(theme, visuals),
            ],
          ),
          if (widget.footer != null) ...[
            SizedBox(height: theme.lineGap),
            MentoraText(widget.footer!, role: theme.footerRole),
          ],
        ],
      ),
    );

    if (_actionable) {
      body = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          overlayColor: WidgetStatePropertyAll(theme.overlay),
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          child: body,
        ),
      );
    }

    final tile = AnimatedContainer(
      // The tile's own surface, named: the components it composes
      // carry their own, and each stays theirs.
      key: const Key('list-tile-surface'),
      duration: theme.transitionDuration,
      curve: theme.curve,
      constraints: BoxConstraints(
        minHeight: theme.minimumExtentOf(
          density: widget.density,
          invitesAct: widget.onTap != null,
        ),
      ),
      decoration: BoxDecoration(
        color: visuals.ground,
        borderRadius: radius,
        border: visuals.border == null
            ? null
            : Border.all(
                color: visuals.border!,
                width: listTileBorderWidth,
              ),
      ),
      child: body,
    );

    final presence = Opacity(
      key: const Key('list-tile-presence'),
      opacity: visuals.opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          if (visuals.divider != null)
            Divider(
              height: listTileDividerThickness,
              thickness: listTileDividerThickness,
              color: visuals.divider,
            ),
        ],
      ),
    );

    // The entity is announced, never its layout — and never at the
    // expense of its parts: the identity and the states own their own
    // voices (each is a semantics boundary of its own), so the tile
    // merges only the words it owns. Given a sentence by the
    // application, it speaks that alone and silences everything else.
    return Semantics(
      container: widget.semanticLabel != null,
      button: widget.onTap != null,
      enabled: widget.onTap == null ? null : _actionable,
      selected: _status == MentoraListTileStatus.selected,
      label: widget.semanticLabel,
      child: widget.semanticLabel == null
          ? presence
          : ExcludeSemantics(child: presence),
    );
  }

  /// The words the tile owns, heard as one sentence: the name of the
  /// entity and what situates it.
  Widget _words(MentoraListTileTheme theme) {
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MentoraText(
            widget.headline,
            role: theme.headlineRoleOf(widget.density),
            maxLines: 1,
          ),
          if (widget.supporting != null) ...[
            SizedBox(height: theme.lineGap),
            MentoraText(
              widget.supporting!,
              role: theme.supportingRole,
              maxLines: 1,
            ),
          ],
          if (widget.metadata != null) ...[
            SizedBox(height: theme.lineGap),
            MentoraText(
              widget.metadata!,
              role: theme.metadataRole,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  /// What stands beside the entity: its states, then the act offered
  /// on it. While the entity is loading, no act is offered twice.
  List<Widget> _aside(
    MentoraListTileTheme theme,
    MentoraListTileVisuals visuals,
  ) {
    if (_status == MentoraListTileStatus.loading) {
      return [
        SizedBox(width: theme.gapOf(widget.density)),
        const SizedBox(
          width: listTileProgressExtent,
          height: listTileProgressExtent,
          child: CircularProgressIndicator(
            strokeWidth: listTileProgressStroke,
          ),
        ),
      ];
    }

    final aside = <Widget>[];
    for (final badge in widget.badges) {
      aside
        ..add(SizedBox(width: theme.gapOf(widget.density)))
        ..add(badge);
    }
    if (widget.trailing != null) {
      aside
        ..add(SizedBox(width: theme.gapOf(widget.density)))
        ..add(widget.trailing!);
    }
    return aside;
  }
}
