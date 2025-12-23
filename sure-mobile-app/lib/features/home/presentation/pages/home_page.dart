import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/app_tap_widget.dart';
import '../../../../generated/app_localizations.dart';

/// Home page - main entry point of the app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.homeTitle,
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.instance.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.homeSubtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.instance.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _WelcomeCard(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppTapWidget(
      onTap: () {
        // TODO(home): Implement action
      },
      semanticLabel: l10n.homeSemanticWelcomeCard,
      semanticHint: l10n.homeSemanticWelcomeCardHint,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.instance.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.instance.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.waving_hand,
              size: 32,
              color: AppColors.instance.primary,
              semanticLabel: l10n.homeSemanticWaveIcon,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.homeWelcomeCardTitle,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.instance.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.homeWelcomeCardDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.instance.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
