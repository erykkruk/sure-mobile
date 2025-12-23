/// Centralized sizing system for buttons, icons, and other elements
/// NEVER hardcode size values - always use AppSizes.*
abstract class AppSizes {
  // Button heights
  static const double buttonHeightSmall = 36;
  static const double buttonHeightMedium = 48;
  static const double buttonHeightLarge = 56;

  // Icon sizes
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 32;
  static const double iconHuge = 48;

  // Avatar sizes
  static const double avatarSmall = 32;
  static const double avatarMedium = 40;
  static const double avatarLarge = 56;
  static const double avatarXLarge = 80;

  // Touch targets (minimum 48dp for accessibility)
  static const double minTouchTarget = 48;

  // Loading indicator
  static const double loadingSmall = 16;
  static const double loadingMedium = 24;
  static const double loadingLarge = 40;

  // App bar
  static const double appBarHeight = 56;

  // Bottom navigation
  static const double bottomNavHeight = 80;

  // Card
  static const double cardMinHeight = 80;

  // Input
  static const double inputHeight = 56;
}
