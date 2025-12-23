import 'package:flutter/material.dart';

/// Centralized color system with dark/light mode support
/// NEVER hardcode colors - always use AppColors.instance.*
class AppColors {
  AppColors._({required this.brightness});

  /// Current theme instance
  static AppColors _instance = AppColors._(brightness: Brightness.light);

  /// Get current color instance
  static AppColors get instance => _instance;

  /// Initialize with brightness
  static void init(Brightness brightness) {
    _instance = AppColors._(brightness: brightness);
  }

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  // Primary colors
  Color get primary => isDark ? const Color(0xFF6B9DFC) : const Color(0xFF2563EB);
  Color get primaryLight =>
      isDark ? const Color(0xFF93B8FD) : const Color(0xFF60A5FA);
  Color get primaryDark =>
      isDark ? const Color(0xFF4A7FE8) : const Color(0xFF1D4ED8);

  // Secondary colors
  Color get secondary =>
      isDark ? const Color(0xFF818CF8) : const Color(0xFF7C3AED);
  Color get secondaryLight =>
      isDark ? const Color(0xFFA5B4FC) : const Color(0xFFA78BFA);

  // Background colors
  Color get backgroundPrimary =>
      isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  Color get backgroundSecondary =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  Color get backgroundTertiary =>
      isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E5E5);

  // Surface colors
  Color get surface => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceVariant =>
      isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6);

  // Text colors
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);
  Color get textSecondary =>
      isDark ? const Color(0xFFB3B3B3) : const Color(0xFF6B7280);
  Color get textTertiary =>
      isDark ? const Color(0xFF808080) : const Color(0xFF9CA3AF);
  Color get textOnPrimary => const Color(0xFFFFFFFF);
  Color get textOnAccent => const Color(0xFFFFFFFF);

  // Icon colors
  Color get iconPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);
  Color get iconSecondary =>
      isDark ? const Color(0xFFB3B3B3) : const Color(0xFF6B7280);
  Color get iconOnAccent => const Color(0xFFFFFFFF);

  // Status colors
  Color get success => const Color(0xFF10B981);
  Color get successLight => const Color(0xFFD1FAE5);
  Color get error => const Color(0xFFEF4444);
  Color get errorLight => const Color(0xFFFEE2E2);
  Color get warning => const Color(0xFFF59E0B);
  Color get warningLight => const Color(0xFFFEF3C7);
  Color get info => const Color(0xFF3B82F6);
  Color get infoLight => const Color(0xFFDBEAFE);

  // Border colors
  Color get border => isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E7EB);
  Color get borderFocused => primary;

  // Overlay colors
  Color get overlay => Colors.black.withValues(alpha: 0.5);
  Color get scrim => Colors.black.withValues(alpha: 0.3);

  // Divider
  Color get divider => isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E7EB);

  // Disabled
  Color get disabled =>
      isDark ? const Color(0xFF4D4D4D) : const Color(0xFFD1D5DB);
  Color get disabledText =>
      isDark ? const Color(0xFF808080) : const Color(0xFF9CA3AF);
}
