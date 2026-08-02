import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';

class FavouritesEmptyView extends StatelessWidget {
  const FavouritesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/stanzi.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                semanticLabel: 'Stanzi the mascot',
              ),
              const SizedBox(height: 24),
              Text(
                'No favourite poems yet',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Save a poem from Today and it will appear here.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
