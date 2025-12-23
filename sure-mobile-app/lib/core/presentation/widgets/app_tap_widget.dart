import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_radius.dart';

/// Accessible tap widget with built-in semantics
/// ALWAYS use AppTapWidget instead of GestureDetector or InkWell
/// semanticLabel and semanticHint are REQUIRED for accessibility
class AppTapWidget extends StatelessWidget {
  const AppTapWidget({
    required this.onTap,
    required this.semanticLabel,
    required this.semanticHint,
    required this.child,
    this.onLongPress,
    this.borderRadius = AppRadius.md,
    this.enableHapticFeedback = true,
    this.enabled = true,
    super.key,
  });

  /// Callback when widget is tapped
  final VoidCallback? onTap;

  /// Callback when widget is long pressed
  final VoidCallback? onLongPress;

  /// Semantic label for screen readers (REQUIRED)
  final String semanticLabel;

  /// Semantic hint for screen readers (REQUIRED)
  final String semanticHint;

  /// Child widget
  final Widget child;

  /// Border radius for ink splash
  final double borderRadius;

  /// Whether to enable haptic feedback on tap
  final bool enableHapticFeedback;

  /// Whether the widget is enabled
  final bool enabled;

  void _handleTap() {
    if (!enabled || onTap == null) return;

    if (enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    onTap?.call();
  }

  void _handleLongPress() {
    if (!enabled || onLongPress == null) return;

    if (enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? _handleTap : null,
        onLongPress: enabled && onLongPress != null ? _handleLongPress : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
