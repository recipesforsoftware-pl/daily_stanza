import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({required this.poem, super.key});

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              poem.title,
              style: AppTextStyles.poemTitle.copyWith(color: AppColors.lightFg),
            ),
            const SizedBox(height: 4),
            Text(
              poem.author,
              style: AppTextStyles.poemAuthor.copyWith(
                color: AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              poem.content,
              style: AppTextStyles.poemBody.copyWith(color: AppColors.lightFg),
            ),
          ],
        ),
      ),
    );
  }
}
