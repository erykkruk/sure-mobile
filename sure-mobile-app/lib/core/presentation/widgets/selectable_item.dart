import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Selectable list item with built-in accessibility
/// Use for list items that can be selected
class SelectableItem extends StatelessWidget {
  const SelectableItem({
    required this.isSelected,
    required this.semanticLabel,
    required this.semanticHint,
    required this.onTap,
    required this.child,
    this.borderRadius = AppRadius.md,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.enableHapticFeedback = true,
    super.key,
  });

  /// Whether the item is currently selected
  final bool isSelected;

  /// Semantic label for screen readers (REQUIRED)
  final String semanticLabel;

  /// Semantic hint for screen readers (REQUIRED)
  final String semanticHint;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Child widget
  final Widget child;

  /// Border radius
  final double borderRadius;

  /// Padding around the item
  final EdgeInsetsGeometry padding;

  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  void _handleTap() {
    if (enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.instance.primaryLight.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.instance.primary
                  : AppColors.instance.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
