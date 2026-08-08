import 'package:flutter/widgets.dart' show Widget;

import '../../components/button/mentora_button.dart';
import '../../tokens/layout_tokens.dart';

/// The shared vocabulary of the Layout layer.
///
/// What lives here belongs to no particular layout: it is what several
/// of them speak, or what a future family will speak. A specialization
/// never declares a style of its own — there is one style file for the
/// whole layer, and a scan proves it.

/// One panel of a dashboard.
///
/// A panel is a subject, what is said about it, and the acts offered
/// on it. The foundation composes the official container, the official
/// words and the official acts — it styles none of them, and it knows
/// nothing of what a panel carries.
final class MentoraDashboardPanel {
  /// What the panel is about. The application owns every string
  /// (Localization Engine); the layer composes none.
  final String title;

  /// What the panel carries. It belongs entirely to the application:
  /// the layer wraps it in nothing and changes nothing about it.
  final Widget content;

  /// The acts offered on the subject — the Button remains their owner.
  final List<MentoraButton> acts;

  const MentoraDashboardPanel({
    required this.title,
    required this.content,
    this.acts = const [],
  });
}

/// One region of content.
///
/// A region is an IDENTITY, a name and what it carries. It is not a
/// position: the application announces the regions in the order it
/// wants them read, and the identity is what the product refers to
/// forever.
///
/// What it carries is already built. It is handed on strictly intact:
/// nothing is wrapped around it, nothing is added beside it.
final class MentoraContentRegion {
  /// What this region IS — stable forever, never a position.
  final String id;

  /// What the screen reader hears about the region: a landmark name.
  /// The application owns every string; the layer composes none.
  final String semanticLabel;

  /// What the region carries, already built by the application.
  final Widget content;

  const MentoraContentRegion({
    required this.id,
    required this.semanticLabel,
    required this.content,
  });
}

/// One section: a logical unit of content.
///
/// A section is not a card, not a container, not a column and not a
/// panel. It is what gathers: an identity that never changes, the name
/// of what is gathered, what completes that name when something must
/// be said, and the content itself — already built.
///
/// The layer composes the official words; it styles none of them, and
/// it knows nothing of what a section gathers.
final class MentoraSection {
  /// What this section IS — stable forever, never a position.
  final String id;

  /// The name of what is gathered. The application owns every string
  /// (Localization Engine); the layer composes none.
  final String title;

  /// What completes the name, when something must be said.
  final String? description;

  /// What the section gathers, already built by the application. It is
  /// handed on strictly intact.
  final Widget content;

  const MentoraSection({
    required this.id,
    required this.title,
    required this.content,
    this.description,
  });
}

/// An identity, and what it is.
///
/// This is the unit of the whole layer wherever content is designated
/// rather than named: an element of a collection, a content of a
/// context, and every unit a future family will need. There is ONE
/// type for that concept, and there will never be a second.
///
/// It is not a position: the application announces the units in the
/// order it wants them read, and the identity is what the product
/// refers to forever.
///
/// What it is, is already built. It is handed on strictly intact: the
/// layer never modifies it, never rebuilds it, never styles it — and
/// never speaks in its place. A unit keeps its own voice.
final class MentoraIdentifiedContent {
  /// What this unit IS — stable forever, never a position.
  final String id;

  /// What the unit is, already built by the application.
  final Widget content;

  const MentoraIdentifiedContent({required this.id, required this.content});
}

/// One cell of a grid.
///
/// A cell is an IDENTITY, the room it was given, and what it is. It is
/// not a position: the application announces where every cell stands,
/// and the identity is what the product refers to forever.
///
/// What it is, is already built. It is handed on strictly intact: the
/// layer never modifies it, never rebuilds it, never styles it — and
/// never speaks in its place. A cell keeps its own voice.
final class MentoraGridCell {
  /// What this cell IS — stable forever, never a position.
  final String id;

  /// The room this cell takes in its row, already decided by the
  /// application. It is announced, never computed.
  final double extent;

  /// What the cell is, already built by the application.
  final Widget content;

  const MentoraGridCell({
    required this.id,
    required this.extent,
    required this.content,
  });
}

/// One row of a grid: an identity, and the cells that stand in it.
final class MentoraGridRow {
  /// What this row IS — stable forever, never a rank.
  final String id;

  final List<MentoraGridCell> cells;

  const MentoraGridRow({required this.id, required this.cells});
}

/// Where every cell of a grid stands — already decided.
///
/// The arrangement is DATA, not a result: the layer never counts
/// columns, never counts rows, never measures a surface and never
/// adapts anything. The application decides; the layer expresses.
final class MentoraGridDisposition {
  final List<MentoraGridRow> rows;

  const MentoraGridDisposition({required this.rows});

  /// What the disposition alone can verify — fail closed.
  ///
  /// It verifies identities and a floor; it never chooses a place.
  void verify() {
    if (rows.isEmpty) {
      throw StateError(
        'A grid stands where it was placed: a disposition without a '
        'row places nothing.',
      );
    }
    final placedRows = <String>{};
    final placedCells = <String>{};
    for (final row in rows) {
      if (row.id.isEmpty) {
        throw StateError('A row without an identity is not a row.');
      }
      if (!placedRows.add(row.id)) {
        throw StateError('Two rows never share one identity.');
      }
      if (row.cells.isEmpty) {
        throw StateError('A row without a cell stands for nothing.');
      }
      for (final cell in row.cells) {
        if (cell.id.isEmpty) {
          throw StateError('A cell without an identity is not a cell.');
        }
        if (!placedCells.add(cell.id)) {
          throw StateError('Two cells never share one identity.');
        }
        if (!cell.extent.isFinite || cell.extent < layoutMinimumCellExtent) {
          throw StateError(
            'A cell needs room to be a cell: the extent announced for '
            '"${cell.id}" is below the opposable floor of '
            '$layoutMinimumCellExtent.',
          );
        }
      }
    }
  }
}

/// The official regions of a form, in the official order.
///
/// The vocabulary is CLOSED: a product never invents a region of a
/// form, and the order below IS the order they are read in — it is the
/// declaration itself, so it cannot drift.
enum MentoraFormRegion {
  /// What the person is about to do.
  header,

  /// What must be known before filling anything in.
  introduction,

  /// The work itself. It is the only region a form cannot do without.
  form,

  /// What helps while filling it in, beside the work.
  supportingContent,

  /// What closes the work — the acts remain the Button's own.
  actions,

  /// What is said under everything: the conditions, the recourse.
  footer,
}

/// The official regions of a detail, in the official order.
///
/// A detail is what a person sees when they consult ONE thing. The
/// vocabulary is CLOSED: a product never invents a region of a detail,
/// and the order below IS the order they are read in.
///
/// Three of them inform about the thing itself, and the vocabulary says
/// which — so the rule "a detail informs about something" is carried by
/// the words themselves, never by a rule written beside them.
enum MentoraDetailRegion {
  /// What one sees first of the thing consulted.
  hero(carriesInformation: false),

  /// What the thing IS: its name, and what designates it.
  identity(carriesInformation: true),

  /// What is essential about it, said shortly.
  summary(carriesInformation: true),

  /// Everything that is known about it, at length.
  details(carriesInformation: true),

  /// What helps beside it, without being about it.
  supportingContent(carriesInformation: false),

  /// What can be done about it — the acts remain the Button's own.
  actions(carriesInformation: false),

  /// What is said under everything: the conditions, the recourse.
  footer(carriesInformation: false);

  /// Whether this region is one of those that inform about the thing.
  ///
  /// A detail that informs about nothing is not a detail, and the
  /// shape refuses to build — fail closed.
  final bool carriesInformation;

  const MentoraDetailRegion({required this.carriesInformation});
}

/// One region of an official vocabulary: what it is called, and what it
/// holds.
///
/// This is the unit of the whole layer wherever a part is NAMED rather
/// than designated: a region of a form, a region of a detail, and every
/// part a future closed vocabulary will need. There is ONE type for
/// that concept, and there will never be a second.
///
/// It carries no identity of its own: the identity of such a region IS
/// the official region it is. What it does carry is its announcement —
/// one per region, exactly once — and the content, already built, which
/// is handed on strictly intact.
final class MentoraLayoutZone {
  /// What the screen reader hears about the region. The application
  /// owns every string; the layer composes none.
  final String semanticLabel;

  /// What the region holds, already built by the application.
  final Widget content;

  const MentoraLayoutZone({required this.semanticLabel, required this.content});
}
