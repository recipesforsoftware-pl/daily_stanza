import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

class FavouritePoemCard extends StatelessWidget {
  const FavouritePoemCard({
    required this.poem,
    required this.isRemoving,
    required this.onRemove,
    this.onOpen,
    super.key,
  });

  final Poem poem;
  final bool isRemoving;
  final VoidCallback onRemove;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: BorderSide(color: AppColors.lightBorder),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Open ${poem.title} by ${poem.author}',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poem.title,
                              style: AppTextStyles.poemTitle.copyWith(
                                color: AppColors.lightFg,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              poem.author,
                              style: AppTextStyles.poemAuthor.copyWith(
                                color: AppColors.lightMuted,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      label: 'Remove from favourites',
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.lightMuted,
                        onPressed: isRemoving ? null : onRemove,
                        tooltip: 'Remove from favourites',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MetaChip(label: _languageLabel(poem.languageCode)),
                    const SizedBox(width: 6),
                    _MetaChip(label: _countryLabel(poem.countryCode)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  poem.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightMuted,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.lightMuted,
          fontSize: 11,
        ),
      ),
    );
  }
}
