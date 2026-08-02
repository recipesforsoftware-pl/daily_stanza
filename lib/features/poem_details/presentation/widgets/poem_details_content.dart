import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';

class PoemDetailsContent extends StatelessWidget {
  const PoemDetailsContent({required this.poem, super.key});

  final Poem poem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: BlocBuilder<FavouritesCubit, FavouritesState>(
              builder: (context, favState) {
                final isFav =
                    favState is FavouritesLoaded &&
                    favState.isFavourite(poem.id);
                final isUpdating =
                    favState is FavouritesLoaded &&
                    favState.updatingPoemIds.contains(poem.id);

                final colors = Theme.of(context).colorScheme;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poem.title,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      poem.author,
                      style: AppTextStyles.poemAuthor.copyWith(
                        color: colors.onSurfaceVariant,
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
                    const SizedBox(height: 24),
                    SelectableText(
                      poem.content,
                      style: AppTextStyles.poemBody.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SourceAndRights(poem: poem),
                    const SizedBox(height: 20),
                    Center(
                      child: Semantics(
                        label: isFav
                            ? 'Remove from favourites'
                            : 'Add to favourites',
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_outline,
                          ),
                          color: isFav
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          iconSize: 28,
                          onPressed: isUpdating
                              ? null
                              : () {
                                  if (isFav) {
                                    context
                                        .read<FavouritesCubit>()
                                        .removeFavourite(poem.id);
                                  } else {
                                    context
                                        .read<FavouritesCubit>()
                                        .addFavourite(poem);
                                  }
                                },
                          tooltip: isFav
                              ? 'Remove from favourites'
                              : 'Add to favourites',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
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

class _SourceAndRights extends StatelessWidget {
  const _SourceAndRights({required this.poem});

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
