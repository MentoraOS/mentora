import 'package:flutter/widgets.dart';

/// Renders one opaque video track handle from the live room contract.
///
/// The concrete builder is provided by the composition edge (the LiveKit
/// one lives in Infrastructure); screens and widgets only ever depend on
/// this vendor-free signature.
typedef VideoTrackViewBuilder =
    Widget Function(BuildContext context, Object track);
