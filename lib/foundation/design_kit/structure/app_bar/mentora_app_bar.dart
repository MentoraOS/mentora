import 'package:flutter/material.dart';

import '../../components/avatar/mentora_avatar.dart';
import '../../components/badge/mentora_badge.dart';
import '../../components/button/mentora_button.dart';
import '../../components/button/mentora_button_style.dart';
import '../../components/design_kit_scope.dart';
import '../../components/input/mentora_input.dart';
import '../../components/text/mentora_text.dart';
import '../../tokens/app_bar_tokens.dart';
import 'mentora_app_bar_style.dart';
import 'mentora_app_bar_theme.dart';

/// The official Mentora context — the first Structural Component.
///
/// An app bar is not a bar. It says WHERE the person is, what leads
/// out of here, and what can be done from here. It never competes
/// with the content: it announces the place, then steps back.
///
/// Flutter's own bars stay primitives: none is used. This component
/// implements [PreferredSizeWidget] so any host can reserve its room
/// without Mentora ever borrowing a Material structure.
///
/// It composes and never redefines: the identity is a
/// [MentoraAvatar], the states are [MentoraBadge]s, the acts are
/// [MentoraButton]s, the entry is a [MentoraInput], and every word is
/// a [MentoraText].
///
/// It subscribes to no scroll and measures no offset: the application
/// announces where the content is, the structure expresses it.
final class MentoraAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final MentoraAppBarVariant variant;

  /// Where the person is. A context that cannot be named announces
  /// nothing: this is required.
  final String title;

  /// What completes the place.
  final String? subtitle;

  /// The way out of here — exactly one, and never one without a name.
  final MentoraAppBarNavigation? navigation;

  /// The identity this context belongs to — the Avatar remains its
  /// owner. It never stands beside a way out: a context has one start.
  final MentoraAvatar? identity;

  /// The state of the place — the Badge remains its owner.
  final MentoraBadge? badge;

  /// What can be done from here — the Button remains their owner.
  final List<MentoraButton> actions;

  /// The entry of a searching context — the Input remains its owner.
  final MentoraInput? search;

  /// How this context behaves while the content moves under it — a
  /// declaration, never a behaviour implemented here.
  final MentoraAppBarScrollBehaviour scrollBehaviour;

  /// What the screen reader hears, when the place must be announced
  /// as one sentence the application composed itself.
  final String? semanticLabel;

  final MentoraAppBarController? controller;

  const MentoraAppBar({
    super.key,
    required this.title,
    this.variant = MentoraAppBarVariant.standard,
    this.subtitle,
    this.navigation,
    this.identity,
    this.badge,
    this.actions = const [],
    this.search,
    this.scrollBehaviour = MentoraAppBarScrollBehaviour.pinned,
    this.semanticLabel,
    this.controller,
  });

  /// The room reserved for this context — stable, so the content
  /// below never jumps while the context collapses inside it.
  @override
  Size get preferredSize =>
      Size.fromHeight(MentoraAppBarTheme.extentOf(variant).reservedExtent);

  @override
  State<MentoraAppBar> createState() => _MentoraAppBarState();
}

final class _MentoraAppBarState extends State<MentoraAppBar> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onAnnounced);
  }

  @override
  void didUpdateWidget(MentoraAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onAnnounced);
      widget.controller?.addListener(_onAnnounced);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onAnnounced);
    super.dispose();
  }

  void _onAnnounced() {
    if (mounted) setState(() {});
  }

  MentoraAppBarStatus get _status =>
      widget.controller?.status ?? MentoraAppBarStatus.idle;

  double get _progress => widget.controller?.collapseProgress ?? 0;

  /// Exactly one effective state: what the application announced about
  /// the context, then where the content has taken its room.
  MentoraAppBarState get _effectiveState {
    switch (_status) {
      case MentoraAppBarStatus.disabled:
        return MentoraAppBarState.disabled;
      case MentoraAppBarStatus.loading:
        return MentoraAppBarState.loading;
      case MentoraAppBarStatus.searching:
        return MentoraAppBarState.searching;
      case MentoraAppBarStatus.idle:
        break;
    }
    if (_progress > appBarFullOpacity) return MentoraAppBarState.expanded;
    if (_progress >= appBarFullOpacity) return MentoraAppBarState.collapsed;
    if (_progress > 0) return MentoraAppBarState.scrolled;
    return MentoraAppBarState.idle;
  }

  /// The contracts a context must honor — verified once, at build,
  /// never silently repaired.
  void _verify() {
    if (widget.title.isEmpty) {
      throw StateError(
        'A context announces where the person is: a place that cannot '
        'be named announces nothing.',
      );
    }
    if (widget.navigation != null && widget.identity != null) {
      throw StateError(
        'A context has one start: a way out and an identity never '
        'stand in the same place.',
      );
    }
    if (widget.variant == MentoraAppBarVariant.search &&
        widget.search == null) {
      throw StateError(
        'A searching context offers an entry: without one it searches '
        'nothing.',
      );
    }
    if (widget.scrollBehaviour == MentoraAppBarScrollBehaviour.stretchable &&
        !canCollapse(widget.variant)) {
      throw StateError(
        'Only a context that offers more room than it keeps may be '
        'stretched.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraAppBarTheme.fromScope(DesignKitScope.of(context));
    _verify();

    final state = _effectiveState;
    final visuals = theme.visualsOf(variant: widget.variant, state: state);

    // The header is the PLACE, not the bar: a screen reader travels
    // from place to place, and the acts offered here stay controls of
    // their own — never swallowed into the name of the place.
    return Opacity(
      key: const Key('app-bar-presence'),
      opacity: visuals.opacity,
      child: AnimatedContainer(
        key: const Key('app-bar-surface'),
        duration: theme.transitionDuration,
        curve: theme.curve,
        decoration: BoxDecoration(color: visuals.surface),
        // A structure occupies exactly the room it reserved — the
        // safe area belongs to the host, which reserves it around
        // the structure, never inside it.
        height: MentoraAppBarTheme.extentOf(widget.variant).reservedExtent,
        child: Stack(
          children: [
            Column(
              children: [
                if (state == MentoraAppBarState.loading)
                  const LinearProgressIndicator(
                    key: Key('app-bar-progress'),
                    minHeight: appBarProgressThickness,
                  ),
                _placeRow(theme, state),
                if (_showsLargePlace(state))
                  Expanded(child: _largePlace(theme)),
              ],
            ),
            // The delimitation rests on the structure: it never
            // takes room from the place it closes.
            if (visuals.divider != null)
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: Divider(
                  key: const Key('app-bar-divider'),
                  height: appBarDividerThickness,
                  thickness: appBarDividerThickness,
                  color: visuals.divider,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The row that always says where the person is: the way out or the
  /// identity, the place, then what can be done from here.
  Widget _placeRow(MentoraAppBarTheme theme, MentoraAppBarState state) {
    final searching = state == MentoraAppBarState.searching;
    final row = Padding(
      padding: theme.padding,
      child: Row(
        children: [
          if (widget.navigation != null) ...[
            _wayOut(theme),
            SizedBox(width: theme.gap),
          ] else if (widget.identity != null) ...[
            widget.identity!,
            SizedBox(width: theme.gap),
          ],
          Expanded(
            child: searching && widget.search != null
                ? widget.search!
                : _place(theme),
          ),
          ..._acts(theme),
        ],
      ),
    );

    // While the place is announced in full below, the row keeps the
    // collapsed extent; otherwise it takes the whole room.
    return _showsLargePlace(state)
        ? SizedBox(
            height: MentoraAppBarTheme.extentOf(widget.variant).collapsedExtent,
            child: row,
          )
        : Expanded(child: row);
  }

  /// A large title keeps its second line as long as the content has
  /// not asked for the room.
  bool _showsLargePlace(MentoraAppBarState state) {
    return canCollapse(widget.variant) &&
        state != MentoraAppBarState.searching &&
        _progress < appBarFullOpacity;
  }

  Widget _wayOut(MentoraAppBarTheme theme) {
    final navigation = widget.navigation!;
    return MentoraButton(
      key: Key('app-bar-${navigation.kind.name}'),
      label: navigation.label,
      onPressed: _status == MentoraAppBarStatus.disabled
          ? null
          : navigation.onInvoke,
      variant: MentoraButtonVariant.text,
      size: MentoraButtonSize.small,
      icon: theme.iconOf(navigation.kind),
    );
  }

  /// The words the context owns, heard as one place. When the
  /// application named the place itself, these words step back — but
  /// the way out and the acts never do: a control keeps its voice.
  Widget _place(MentoraAppBarTheme theme) {
    final large = _showsLargePlace(_effectiveState);
    final words = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // While the large place is shown below, the row keeps only
        // what situates it: a place is never announced twice.
        if (!large)
          MentoraText(
            widget.title,
            role: theme.titleRoleOf(
              variant: widget.variant,
              collapseProgress: _progress,
            ),
            maxLines: 1,
          ),
        if (widget.subtitle != null)
          MentoraText(widget.subtitle!, role: theme.subtitleRole, maxLines: 1),
      ],
    );

    // When the large place is shown below, the header travels with
    // the title: a place is announced exactly once.
    return _announcedPlace(words, carriesTitle: !large);
  }

  /// The place, announced as a header — and named by the application's
  /// own sentence when it gave one.
  Widget _announcedPlace(Widget child, {required bool carriesTitle}) {
    if (!carriesTitle) return MergeSemantics(child: child);
    // The annotation lives INSIDE the merge, so the place is heard as
    // one thing: a header carrying the words it qualifies.
    return MergeSemantics(
      child: Semantics(
        header: true,
        label: widget.semanticLabel,
        child: widget.semanticLabel == null
            ? child
            : ExcludeSemantics(child: child),
      ),
    );
  }

  Widget _largePlace(MentoraAppBarTheme theme) {
    return _announcedPlace(
      carriesTitle: true,
      Padding(
        padding: theme.padding,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: MentoraText(
            widget.title,
            key: const Key('app-bar-large-title'),
            role: theme.titleRoleOf(
              variant: widget.variant,
              collapseProgress: _progress,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  /// What can be done from here: the state of the place, then the
  /// acts. A disabled context offers none of them.
  List<Widget> _acts(MentoraAppBarTheme theme) {
    if (_status == MentoraAppBarStatus.disabled) return const [];

    final acts = <Widget>[];
    if (widget.badge != null) {
      acts
        ..add(SizedBox(width: theme.actionGap))
        ..add(widget.badge!);
    }
    for (final action in widget.actions) {
      acts
        ..add(SizedBox(width: theme.actionGap))
        ..add(action);
    }
    return acts;
  }
}
