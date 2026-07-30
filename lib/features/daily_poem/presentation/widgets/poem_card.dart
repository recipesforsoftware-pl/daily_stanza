import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({required this.poem, super.key});

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              poem.title,
              style: AppTextStyles.poemTitle.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              poem.author,
              style: AppTextStyles.poemAuthor.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              poem.content,
              style: AppTextStyles.poemBody.copyWith(color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
