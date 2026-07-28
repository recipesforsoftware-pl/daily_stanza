import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';

class DailyPoemStatusView extends StatelessWidget {
  const DailyPoemStatusView({
    required this.title,
    required this.subtitle,
    this.showStanzi = true,
    this.showRetry = false,
    this.onRetry,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool showStanzi;
  final bool showRetry;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStanzi) ...[
                Image.asset(
                  'assets/stanzi.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  semanticLabel: 'Stanzi the mascot',
                ),
                const SizedBox(height: 24),
              ],
              Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.lightFg,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightMuted,
                ),
                textAlign: TextAlign.center,
              ),
              if (showRetry) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lightAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
