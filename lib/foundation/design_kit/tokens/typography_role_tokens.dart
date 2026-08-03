import 'package:flutter/widgets.dart';

/// The v1 materialization of the 27 typography roles (catalog §D2) —
/// sizes and weights live here, in the tokens layer, and nowhere else.
/// The hierarchy is strict (TSH-02): a lower role never visually
/// dominates a higher one.
final class TypographyRoleSpec {
  final double size;
  final FontWeight weight;
  final FontStyle style;

  const TypographyRoleSpec({
    required this.size,
    required this.weight,
    this.style = FontStyle.normal,
  });
}

// Structure roles.
const TypographyRoleSpec displaySpec = TypographyRoleSpec(
  size: 28,
  weight: FontWeight.w600,
);
const TypographyRoleSpec heroSpec = TypographyRoleSpec(
  size: 24,
  weight: FontWeight.w600,
);
const TypographyRoleSpec pageTitleSpec = TypographyRoleSpec(
  size: 22,
  weight: FontWeight.w600,
);
const TypographyRoleSpec sectionTitleSpec = TypographyRoleSpec(
  size: 17,
  weight: FontWeight.w600,
);
const TypographyRoleSpec surfaceTitleSpec = TypographyRoleSpec(
  size: 17,
  weight: FontWeight.w500,
);
const TypographyRoleSpec blockTitleSpec = TypographyRoleSpec(
  size: 15,
  weight: FontWeight.w600,
);

// Body roles.
const TypographyRoleSpec bodySpec = TypographyRoleSpec(
  size: 15,
  weight: FontWeight.w400,
);
const TypographyRoleSpec labelSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec supportingSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w400,
);
const TypographyRoleSpec captionSpec = TypographyRoleSpec(
  size: 12,
  weight: FontWeight.w400,
);
const TypographyRoleSpec hintSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w400,
);
const TypographyRoleSpec metadataSpec = TypographyRoleSpec(
  size: 12,
  weight: FontWeight.w400,
);
const TypographyRoleSpec timestampSpec = TypographyRoleSpec(
  size: 12,
  weight: FontWeight.w400,
);
const TypographyRoleSpec footnoteSpec = TypographyRoleSpec(
  size: 11,
  weight: FontWeight.w400,
);
const TypographyRoleSpec legalSpec = TypographyRoleSpec(
  size: 12,
  weight: FontWeight.w400,
);

// Data and state roles.
const TypographyRoleSpec valueSpec = TypographyRoleSpec(
  size: 20,
  weight: FontWeight.w600,
);
const TypographyRoleSpec statusSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec emptyStateSpec = TypographyRoleSpec(
  size: 15,
  weight: FontWeight.w400,
);
const TypographyRoleSpec loadingSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w400,
);

// Interaction roles.
const TypographyRoleSpec actionTextSpec = TypographyRoleSpec(
  size: 15,
  weight: FontWeight.w500,
);
const TypographyRoleSpec navigationTextSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec messageSpec = TypographyRoleSpec(
  size: 15,
  weight: FontWeight.w400,
);

// Signification roles.
const TypographyRoleSpec aiSuggestionTextSpec = TypographyRoleSpec(
  size: 14,
  weight: FontWeight.w400,
  style: FontStyle.italic,
);
const TypographyRoleSpec verificationSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec warningTextSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec criticalTextSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
const TypographyRoleSpec successTextSpec = TypographyRoleSpec(
  size: 13,
  weight: FontWeight.w500,
);
