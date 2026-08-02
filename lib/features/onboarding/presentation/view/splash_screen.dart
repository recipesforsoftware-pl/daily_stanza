import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.9,
            colors: [
              isDark ? const Color(0xFF2E3044) : const Color(0xFFFDF6E8),
              isDark ? AppColors.darkBg : AppColors.lightBg,
            ],
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Mascot(),
                  SizedBox(height: AppSpacing.lg),
                  _Wordmark(),
                  SizedBox(height: AppSpacing.sm),
                  _Tagline(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Stanzi — friendly open-book mascot',
      child: Image.asset(
        'assets/stanzi.png',
        width: 152,
        height: 152,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Daily Stanza',
      style: theme.textTheme.displayMedium?.copyWith(
        fontFamily: AppTextStyles.displayMedium.fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'One poem. One quiet moment. Every day.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}
