import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/offline_poem_banner.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/poem_card.dart';

class DailyPoemContent extends StatelessWidget {
  const DailyPoemContent({
    required this.poem,
    required this.isFromCache,
    required this.formattedDate,
    this.isFavourite = false,
    this.isFavouriteUpdating = false,
    this.onFavouriteToggle,
    super.key,
  });

  final Poem poem;
  final bool isFromCache;
  final String formattedDate;
  final bool isFavourite;
  final bool isFavouriteUpdating;
  final VoidCallback? onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Today's poem",
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.lightFg,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(label: _languageLabel(poem.languageCode)),
                    _Chip(label: _countryLabel(poem.countryCode)),
                  ],
                ),
                const SizedBox(height: 20),
                if (isFromCache) ...[
                  const OfflinePoemBanner(),
                  const SizedBox(height: 16),
                ],
                PoemCard(poem: poem),
                const SizedBox(height: 20),
                _SourceInfo(poem: poem),
                const SizedBox(height: 16),
                if (onFavouriteToggle != null)
                  Center(
                    child: Semantics(
                      label: isFavourite
                          ? 'Remove from favourites'
                          : 'Add to favourites',
                      child: IconButton(
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_outline,
                        ),
                        color: isFavourite
                            ? AppColors.lightAccent
                            : AppColors.lightMuted,
                        iconSize: 28,
                        onPressed: isFavouriteUpdating
                            ? null
                            : onFavouriteToggle,
                        tooltip: isFavourite
                            ? 'Remove from favourites'
                            : 'Add to favourites',
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'pl':
        return 'Polski';
      default:
        return code.toUpperCase();
    }
  }

  String _countryLabel(String code) {
    switch (code) {
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      case 'PL':
        return 'Poland';
      default:
        return code;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightMuted),
      ),
    );
  }
}

class _SourceInfo extends StatelessWidget {
  const _SourceInfo({required this.poem});

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source: ${poem.sourceName}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightMuted),
        ),
        const SizedBox(height: 4),
        Text(
          'Rights: ${poem.rightsStatus.replaceAll('_', ' ')}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightMuted),
        ),
      ],
    );
  }
}
