import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

/// Centralized loading indicator
/// ALWAYS use AppLoadingIndicator instead of CircularProgressIndicator
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.size = AppSizes.loadingMedium,
    this.color,
    this.strokeWidth = 3,
    this.semanticLabel = 'Loading',
    super.key,
  });

  /// Size of the indicator
  final double size;

  /// Color of the indicator (defaults to primary)
  final Color? color;

  /// Stroke width of the indicator
  final double strokeWidth;

  /// Semantic label for screen readers
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.instance.primary,
          ),
        ),
      ),
    );
  }
}
