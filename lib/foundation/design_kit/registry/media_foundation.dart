import 'package:flutter/widgets.dart' show IconData;

import 'token_identity.dart';

/// Icon Foundation — the receiving contract of the Iconography domain.
///
/// The 47 admitted significations (catalog §D5) will bind through the
/// SAME registry mechanism as every other domain: an icon Token is a
/// `TokenRef<IconData>` whose glyph is its materialization. One
/// mechanism for all domains — the ten-year answer.
typedef IconTokenRef = TokenRef<IconData>;

/// A reference to an illustration asset — the situation's image is the
/// materialization; the situation and its narration stay upstream
/// (Illustration System, niveau Narrative).
final class IllustrationReference {
  /// The asset identifier the materialization wave will produce.
  final String assetName;

  const IllustrationReference({required this.assetName});
}

/// Illustration Foundation — the receiving contract of the
/// Illustration domain (catalog §D6): an illustration Token is a
/// `TokenRef<IllustrationReference>`.
typedef IllustrationTokenRef = TokenRef<IllustrationReference>;
