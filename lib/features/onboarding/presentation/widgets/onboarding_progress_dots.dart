import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';

class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final inactive = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Semantics(
      label: 'Onboarding step ${activeIndex + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isActive ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive ? accent : inactive,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
