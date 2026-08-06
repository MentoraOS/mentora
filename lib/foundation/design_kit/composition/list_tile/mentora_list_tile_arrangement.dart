import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How an entity gives up what it carries when the room grows short.
///
/// The order is a MEANING, not a preference. An entity reduces before
/// it removes, and it removes from the least telling to the most:
///
/// 1. the space it breathes in;
/// 2. the states it shows, the last announced first;
/// 3. what completes its name;
/// 4. the act offered on it — an act outlives a decoration.
///
/// The name and the identity are never given up. Never.
///
/// Nothing here measures a screen, a platform or a breakpoint: the
/// parent imposes a constraint, and the entity answers it. That is the
/// only thing this arrangement ever reads.
final class MentoraListTileArrangement extends MultiChildRenderObjectWidget {
  /// Whether the first child is the identity of the entity.
  final bool hasIdentity;

  /// How many of the children are states shown beside the entity.
  /// They are given in the order the application announced them: the
  /// last announced is the first given up.
  final int badgeCount;

  /// Whether the last child is the act offered on the entity.
  final bool hasAct;

  /// The breathing between the parts, and what survives of it when the
  /// room grows short.
  final double gap;
  final double surrenderedGap;

  /// The room a name needs to stay a name.
  final double wordsFloor;

  /// The room the words need to say more than the name.
  ///
  /// Giving up what completes the name gives that room back: it is a
  /// rung of the ladder like any other, and it is climbed down after
  /// the states and before the act.
  final double secondaryWordsFloor;

  /// The reading direction — never a platform, never a measure.
  final TextDirection textDirection;

  const MentoraListTileArrangement({
    super.key,
    required this.hasIdentity,
    required this.badgeCount,
    required this.hasAct,
    required this.gap,
    required this.surrenderedGap,
    required this.wordsFloor,
    required this.secondaryWordsFloor,
    required this.textDirection,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMentoraListTileArrangement(
      hasIdentity: hasIdentity,
      badgeCount: badgeCount,
      hasAct: hasAct,
      gap: gap,
      surrenderedGap: surrenderedGap,
      wordsFloor: wordsFloor,
      secondaryWordsFloor: secondaryWordsFloor,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMentoraListTileArrangement renderObject,
  ) {
    renderObject
      ..hasIdentity = hasIdentity
      ..badgeCount = badgeCount
      ..hasAct = hasAct
      ..gap = gap
      ..surrenderedGap = surrenderedGap
      ..wordsFloor = wordsFloor
      ..secondaryWordsFloor = secondaryWordsFloor
      ..textDirection = textDirection;
  }
}

/// What the arrangement decided for one child.
final class _ArrangementParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether the entity kept this part in the room it was given.
  bool kept = true;
}

/// What one measure of the room decided.
final class _Plan {
  final Size size;
  final double gap;
  final double identityExtent;
  final double wordsExtent;
  final double wordsCeiling;
  final Set<RenderBox> kept;

  const _Plan({
    required this.size,
    required this.gap,
    required this.identityExtent,
    required this.wordsExtent,
    required this.wordsCeiling,
    required this.kept,
  });
}

/// The entity line — the layout that owns the surrender ladder.
final class RenderMentoraListTileArrangement extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ArrangementParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ArrangementParentData> {
  RenderMentoraListTileArrangement({
    required bool hasIdentity,
    required int badgeCount,
    required bool hasAct,
    required double gap,
    required double surrenderedGap,
    required double wordsFloor,
    required double secondaryWordsFloor,
    required TextDirection textDirection,
  }) : _hasIdentity = hasIdentity,
       _badgeCount = badgeCount,
       _hasAct = hasAct,
       _gap = gap,
       _surrenderedGap = surrenderedGap,
       _wordsFloor = wordsFloor,
       _secondaryWordsFloor = secondaryWordsFloor,
       _textDirection = textDirection;

  bool _hasIdentity;
  set hasIdentity(bool value) {
    if (value == _hasIdentity) return;
    _hasIdentity = value;
    markNeedsLayout();
  }

  int _badgeCount;
  set badgeCount(int value) {
    if (value == _badgeCount) return;
    _badgeCount = value;
    markNeedsLayout();
  }

  bool _hasAct;
  set hasAct(bool value) {
    if (value == _hasAct) return;
    _hasAct = value;
    markNeedsLayout();
  }

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  double _surrenderedGap;
  set surrenderedGap(double value) {
    if (value == _surrenderedGap) return;
    _surrenderedGap = value;
    markNeedsLayout();
  }

  double _wordsFloor;
  set wordsFloor(double value) {
    if (value == _wordsFloor) return;
    _wordsFloor = value;
    markNeedsLayout();
  }

  double _secondaryWordsFloor;
  set secondaryWordsFloor(double value) {
    if (value == _secondaryWordsFloor) return;
    _secondaryWordsFloor = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ArrangementParentData) {
      child.parentData = _ArrangementParentData();
    }
  }

  /// The parts of the entity, in the order they were given: the
  /// identity, the words, the states, then the act.
  List<RenderBox> get _parts {
    final parts = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      parts.add(child);
      child = childAfter(child);
    }
    return parts;
  }

  RenderBox? get _identity => _hasIdentity ? firstChild : null;

  RenderBox get _words => _hasIdentity ? childAfter(firstChild!)! : firstChild!;

  /// The states shown beside the entity, in the order the application
  /// announced them.
  List<RenderBox> get _states => _aside.take(_badgeCount).toList();

  /// The act offered on the entity, when one is offered.
  RenderBox? get _act {
    final aside = _aside;
    if (!_hasAct || aside.length <= _badgeCount) return null;
    return aside[_badgeCount];
  }

  List<RenderBox> get _aside => _parts.sublist(_hasIdentity ? 2 : 1);

  static double _naturalWidthOf(RenderBox part) =>
      part.getDryLayout(const BoxConstraints()).width;

  /// What the entity keeps in the room it was given.
  ///
  /// The same measure serves the dry layout and the real one, so what
  /// is announced is always what is laid out.
  _Plan _planFor(BoxConstraints constraints) {
    final bounded = constraints.hasBoundedWidth;
    final room = constraints.maxWidth;
    final identity = _identity;
    final identityExtent = identity == null ? 0.0 : _naturalWidthOf(identity);
    final kept = <RenderBox>{..._aside};

    var gap = _gap;
    var saysMoreThanItsName = true;

    double needed() {
      var needed = identity == null ? 0.0 : identityExtent + gap;
      // A name needs its floor; a name and what completes it need
      // more — so giving up what completes it gives room back.
      needed += saysMoreThanItsName ? _secondaryWordsFloor : _wordsFloor;
      for (final part in _aside) {
        if (kept.contains(part)) needed += gap + _naturalWidthOf(part);
      }
      return needed;
    }

    if (bounded) {
      // The official ladder, climbed down one rung at a time: the
      // space, then the states from the last announced, then what
      // completes the name, then the act. The name and the identity
      // are never rungs.
      if (needed() > room) gap = _surrenderedGap;
      final act = _act;
      final ladder = <void Function()>[
        for (final state in _states.reversed) () => kept.remove(state),
        () => saysMoreThanItsName = false,
        if (act != null) () => kept.remove(act),
      ];
      for (final surrender in ladder) {
        if (needed() <= room) break;
        surrender();
      }
    }

    var occupied = identity == null ? 0.0 : identityExtent + gap;
    for (final part in _aside) {
      if (kept.contains(part)) occupied += gap + _naturalWidthOf(part);
    }

    // What is left belongs to the words, and never less than nothing.
    final wordsExtent = bounded
        ? math.max(0.0, room - occupied)
        : _naturalWidthOf(_words);

    // What completes the name was either kept or given up by the
    // ladder above: the words are told through the room they are given.
    final wordsCeiling = saysMoreThanItsName
        ? double.infinity
        : _words.getMinIntrinsicHeight(wordsExtent);
    final wordsConstraints = BoxConstraints(
      minWidth: wordsExtent,
      maxWidth: wordsExtent,
      maxHeight: wordsCeiling,
    );

    var height = identity == null
        ? 0.0
        : identity.getDryLayout(const BoxConstraints()).height;
    height = math.max(height, _words.getDryLayout(wordsConstraints).height);
    for (final part in _aside) {
      if (!kept.contains(part)) continue;
      height = math.max(
        height,
        part.getDryLayout(const BoxConstraints()).height,
      );
    }

    final width = bounded ? room : occupied + wordsExtent;
    return _Plan(
      size: constraints.constrain(Size(width, height)),
      gap: gap,
      identityExtent: identityExtent,
      wordsExtent: wordsExtent,
      wordsCeiling: wordsCeiling,
      kept: kept,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _planFor(constraints).size;

  @override
  void performLayout() {
    final plan = _planFor(constraints);
    size = plan.size;

    void place(RenderBox part, double start, double extent) {
      final data = part.parentData! as _ArrangementParentData;
      final dx = _textDirection == TextDirection.rtl
          ? size.width - start - extent
          : start;
      data.offset = Offset(dx, (size.height - part.size.height) / 2);
    }

    var start = 0.0;
    final identity = _identity;
    if (identity != null) {
      identity.layout(const BoxConstraints(), parentUsesSize: true);
      place(identity, start, plan.identityExtent);
      start += plan.identityExtent + plan.gap;
    }

    _words.layout(
      BoxConstraints(
        minWidth: plan.wordsExtent,
        maxWidth: plan.wordsExtent,
        maxHeight: plan.wordsCeiling,
      ),
      parentUsesSize: true,
    );
    place(_words, start, plan.wordsExtent);
    start += plan.wordsExtent;

    for (final part in _aside) {
      final data = part.parentData! as _ArrangementParentData;
      data.kept = plan.kept.contains(part);
      // A part that was given up is still measured, so that nothing is
      // ever left un-laid-out — it is simply no longer there: not
      // painted, not touchable, and not spoken.
      part.layout(const BoxConstraints(), parentUsesSize: true);
      if (!data.kept) {
        data.offset = Offset.zero;
        continue;
      }
      start += plan.gap;
      place(part, start, part.size.width);
      start += part.size.width;
    }
  }

  bool _isKept(RenderBox part) =>
      (part.parentData! as _ArrangementParentData).kept;

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      if (_isKept(child)) {
        final data = child.parentData! as _ArrangementParentData;
        context.paintChild(child, data.offset + offset);
      }
      child = childAfter(child);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final data = child.parentData! as _ArrangementParentData;
      if (_isKept(child)) {
        final hit = result.addWithPaintOffset(
          offset: data.offset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (hit) return true;
      }
      child = childBefore(child);
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      // What an entity gave up says nothing: it is not announced.
      if (_isKept(child)) visitor(child);
      child = childAfter(child);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final identity = _identity;
    return (identity == null ? 0.0 : _naturalWidthOf(identity) + _gap) +
        _wordsFloor;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var total = 0.0;
    for (final part in _parts) {
      total += _naturalWidthOf(part) + _gap;
    }
    return math.max(0.0, total - _gap);
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _planFor(BoxConstraints(maxWidth: width)).size.height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);
}

/// The words of an entity: its name, and what completes it.
///
/// The name is always there. What completes it is given up when the
/// room it would be shown in is too small to carry it with dignity —
/// a stump of a sentence says less than no sentence at all.
final class MentoraListTileWords extends MultiChildRenderObjectWidget {
  /// The breathing between two lines of words.
  final double lineGap;

  const MentoraListTileWords({
    super.key,
    required this.lineGap,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMentoraListTileWords(lineGap: lineGap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMentoraListTileWords renderObject,
  ) {
    renderObject.lineGap = lineGap;
  }
}

final class RenderMentoraListTileWords extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ArrangementParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ArrangementParentData> {
  RenderMentoraListTileWords({required double lineGap}) : _lineGap = lineGap;

  double _lineGap;
  set lineGap(double value) {
    if (value == _lineGap) return;
    _lineGap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ArrangementParentData) {
      child.parentData = _ArrangementParentData();
    }
  }

  /// The name of the entity, which is never given up.
  ///
  /// What completes it is kept only while the room the entity was
  /// given can still carry it — the arrangement says so through the
  /// height it hands down, and nothing else is ever read here.
  Size _planFor(BoxConstraints constraints) {
    final lines = BoxConstraints(maxWidth: constraints.maxWidth);
    var height = 0.0;
    var width = 0.0;
    var isName = true;
    var child = firstChild;
    while (child != null) {
      final size = child.getDryLayout(lines);
      final wanted = isName ? size.height : height + _lineGap + size.height;
      if (isName || wanted <= constraints.maxHeight) {
        height = wanted;
        width = math.max(width, size.width);
      }
      isName = false;
      child = childAfter(child);
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _planFor(constraints);

  @override
  void performLayout() {
    size = _planFor(constraints);
    final lines = BoxConstraints(maxWidth: constraints.maxWidth);

    var offset = 0.0;
    var isName = true;
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ArrangementParentData;
      child.layout(lines, parentUsesSize: true);
      final wanted = isName
          ? child.size.height
          : offset + _lineGap + child.size.height;
      data.kept = isName || wanted <= constraints.maxHeight;
      if (data.kept) {
        if (!isName) offset += _lineGap;
        data.offset = Offset(0, offset);
        offset += child.size.height;
      } else {
        data.offset = Offset.zero;
      }
      isName = false;
      child = childAfter(child);
    }
  }

  bool _isKept(RenderBox child) =>
      (child.parentData! as _ArrangementParentData).kept;

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      if (_isKept(child)) {
        final data = child.parentData! as _ArrangementParentData;
        context.paintChild(child, data.offset + offset);
      }
      child = childAfter(child);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final data = child.parentData! as _ArrangementParentData;
      if (_isKept(child)) {
        final hit = result.addWithPaintOffset(
          offset: data.offset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (hit) return true;
      }
      child = childBefore(child);
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      if (_isKept(child)) visitor(child);
      child = childAfter(child);
    }
  }

  /// The height of the name alone — what an entity keeps when the room
  /// it was given can carry nothing more.
  @override
  double computeMinIntrinsicHeight(double width) =>
      firstChild == null ? 0 : firstChild!.getMaxIntrinsicHeight(width);

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      width = math.max(width, child.getMaxIntrinsicWidth(double.infinity));
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _planFor(BoxConstraints(maxWidth: width)).height;
}
