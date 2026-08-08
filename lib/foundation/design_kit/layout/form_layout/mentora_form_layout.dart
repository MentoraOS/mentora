import 'package:flutter/widgets.dart';

import '../../components/button/mentora_button.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/search_bar/mentora_search_bar.dart';
import '../../structure/tabs/mentora_tabs.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';

/// The official Form Layout - the way the work of a person filling
/// information in is organised.
///
/// A form layout is NOT a form. The form belongs to the components:
/// MentoraInput owns what is typed, MentoraButton owns the acts,
/// MentoraText owns the words, MentoraSection owns the sections. What
/// this layout owns is the CONTEXT of that work: its regions, their
/// order, their announcements and their focus groups.
///
/// It expresses. It never decides.
///
/// It validates nothing, submits nothing, knows no field, no data, no
/// model, no network, no platform and no state of the work. It builds
/// nothing either: it describes the official regions, and the assembly
/// of the layer is what places them.
///
/// The work itself is the only region a form cannot do without, and
/// the compiler says so: it is not optional.
final class MentoraFormLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// Where the person is - the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The facets of the page - the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding - the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The acts the page keeps at hand - the Button remains their owner.
  final List<MentoraButton> acts;

  /// What the person is about to do.
  final MentoraFormZone? header;

  /// What must be known before filling anything in.
  final MentoraFormZone? introduction;

  /// The work itself. A form without it is not a form, and this is
  /// refused by the type rather than at run time.
  final MentoraFormZone form;

  /// What helps while filling it in.
  final MentoraFormZone? supportingContent;

  /// What closes the work.
  final MentoraFormZone? actions;

  /// What is said under everything.
  final MentoraFormZone? footer;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraFormLayout({
    super.key,
    required this.frame,
    required this.form,
    required this.pageSemanticLabel,
    this.header,
    this.introduction,
    this.supportingContent,
    this.actions,
    this.footer,
    this.place,
    this.facets,
    this.intention,
    this.acts = const [],
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.form;

  /// What was given for each official region, in the official order.
  ///
  /// The order is the declaration of the vocabulary itself: it cannot
  /// drift, and nothing here chooses it.
  Map<MentoraFormRegion, MentoraFormZone?> get _zones => {
    MentoraFormRegion.header: header,
    MentoraFormRegion.introduction: introduction,
    MentoraFormRegion.form: form,
    MentoraFormRegion.supportingContent: supportingContent,
    MentoraFormRegion.actions: actions,
    MentoraFormRegion.footer: footer,
  };

  @override
  void verify() {
    final zones = _zones;
    for (final region in MentoraFormRegion.values) {
      final zone = zones[region];
      if (zone == null) continue;
      if (zone.semanticLabel.isEmpty) {
        throw StateError(
          'A region without a name is not a landmark: a person always '
          'knows which part of the work they are in.',
        );
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    final zones = _zones;

    return MentoraLayoutSurface.regions(
      semanticLabel: pageSemanticLabel,
      place: place,
      facets: facets,
      intention: intention,
      acts: acts,
      regions: [
        for (final region in MentoraFormRegion.values)
          if (zones[region] case final zone?)
            MentoraContentRegion(
              // The identity of a region of a form IS the official
              // region it is: a product never names one.
              id: region.name,
              semanticLabel: zone.semanticLabel,
              content: zone.content,
            ),
      ],
    );
  }
}
