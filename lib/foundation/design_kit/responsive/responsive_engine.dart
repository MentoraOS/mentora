import 'dart:ui';

/// The official device contexts (Responsive Foundation §6). The phone
/// is the reference — every other context is a presentation of the
/// same experience, never another product.
enum DeviceContext { wearable, phone, foldable, tablet, desktop, tv }

/// The Responsive Engine — pure classification of the available space
/// into an official context. No screen logic, no capability gating
/// (RSE-02: nothing exists off-phone that does not exist on phone).
final class ResponsiveEngine {
  const ResponsiveEngine();

  /// Width thresholds are presentation boundaries, never meaning: the
  /// same contracts render in every context (values live here because
  /// this engine is their token-sanctioned home for the foundation —
  /// they will move to the registry with the Responsive token wave).
  static const double _wearableMaxWidth = 300;
  static const double _phoneMaxWidth = 600;
  static const double _foldableMaxWidth = 720;
  static const double _tabletMaxWidth = 1024;
  static const double _desktopMaxWidth = 1920;

  DeviceContext resolve(Size size) {
    final width = size.shortestSide;
    if (width < _wearableMaxWidth) return DeviceContext.wearable;
    if (width < _phoneMaxWidth) return DeviceContext.phone;
    if (width < _foldableMaxWidth) return DeviceContext.foldable;
    if (width < _tabletMaxWidth) return DeviceContext.tablet;
    if (size.width <= _desktopMaxWidth) return DeviceContext.desktop;
    return DeviceContext.tv;
  }

  /// The reference context: any adaptation doubt resolves to what the
  /// phone does (RSMF-04).
  DeviceContext get reference => DeviceContext.phone;
}
