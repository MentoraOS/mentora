/// The official registry of the shapes a screen of Mentora may take.
///
/// It is CLOSED. A product never invents a shape: every extension of
/// the Layout system passes through this enumeration, and through the
/// specialization that materializes it. Adding a shape is therefore a
/// deliberate act of the Design System — never a local decision of a
/// screen, and never a widget someone assembled by hand.
///
/// There is exactly one registry in the product, and a scan proves it.
enum MentoraLayoutKind {
  /// One page, in the working context of the product.
  workspace,

  /// A page whose content is a set of panels.
  dashboard,

  /// A context whose whole point is the way through the product.
  navigation,

  /// A room shared between regions, in the working context.
  splitWorkspace,

  /// Two spaces in relation, in the working context.
  masterDetail,

  /// Content, disposed the official way: named regions, in the order
  /// the application announced them, and nothing added between them.
  content,
}
