import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/offline_poem_banner.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/poem_card.dart';
import 'package:daily_stanza/features/share_poem/presentation/widgets/share_poem_button.dart';

class DailyPoemContent extends StatelessWidget {
  const DailyPoemContent({
    required this.poem,
    required this.isFromCache,
    required this.formattedDate,
    this.isFavourite = false,
    this.isFavouriteUpdating = false,
    this.onFavouriteToggle,
    this.onReadFocusMode,
    super.key,
  });

  final Poem poem;
  final bool isFromCache;
  final String formattedDate;
  final bool isFavourite;
  final bool isFavouriteUpdating;
  final VoidCallback? onFavouriteToggle;
  final VoidCallback? onReadFocusMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
                  key: const ValueKey('dailyPoemDate'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Today's poem",
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.onSurface,
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
                SizedBox(
                  width: double.infinity,
                  child: PoemCard(poem: poem),
                ),
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
                            ? colors.primary
                            : colors.onSurfaceVariant,
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
                const SizedBox(height: 8),
                Center(
                  child: SharePoemButton(poem: poem, label: 'Share poem'),
                ),
                if (onReadFocusMode != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Semantics(
                      label: 'Read in focus mode',
                      child: TextButton.icon(
                        onPressed: onReadFocusMode,
                        icon: const Icon(Icons.open_in_full, size: 18),
                        label: const Text('Read in focus mode'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SourceInfo extends StatelessWidget {
  const _SourceInfo({required this.poem});

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source: ${poem.sourceName}',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rights: ${poem.rightsStatus.replaceAll('_', ' ')}',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
