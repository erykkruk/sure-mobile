/// Centralized border radius system
/// NEVER hardcode radius values - always use AppRadius.*
abstract class AppRadius {
  /// 0dp - no rounding
  static const double none = 0;

  /// 4dp - subtle rounding
  static const double xs = 4;

  /// 8dp - small rounding
  static const double sm = 8;

  /// 12dp - medium rounding
  static const double md = 12;

  /// 16dp - large rounding
  static const double lg = 16;

  /// 20dp - extra large rounding
  static const double xl = 20;

  /// 24dp - extra extra large rounding
  static const double xxl = 24;

  /// 32dp - huge rounding
  static const double xxxl = 32;

  /// 9999dp - full/pill rounding
  static const double full = 9999;
}
