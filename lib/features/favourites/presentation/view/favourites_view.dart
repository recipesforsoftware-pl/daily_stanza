import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/favourites/presentation/widgets/favourite_poem_card.dart';
import 'package:daily_stanza/features/favourites/presentation/widgets/favourites_empty_view.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) {
          return switch (state) {
            FavouritesInitial() => const SizedBox.shrink(),
            FavouritesLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            FavouritesLoaded(
              :final poems,
              :final favouriteIds,
              :final updatingPoemIds,
            ) =>
              poems.isEmpty
                  ? const FavouritesEmptyView()
                  : _FavouritesList(
                      poems: poems,
                      favouriteIds: favouriteIds,
                      updatingPoemIds: updatingPoemIds,
                    ),
            FavouritesFailure() => _FailureView(),
          };
        },
      ),
    );
  }
}

class _FavouritesList extends StatelessWidget {
  const _FavouritesList({
    required this.poems,
    required this.favouriteIds,
    required this.updatingPoemIds,
  });

  final List<Poem> poems;
  final Set<String> favouriteIds;
  final Set<String> updatingPoemIds;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: poems.length,
      itemBuilder: (context, index) {
        final poem = poems[index];
        return FavouritePoemCard(
          poem: poem,
          isRemoving: updatingPoemIds.contains(poem.id),
          onRemove: () {
            context.read<FavouritesCubit>().removeFavourite(poem.id);
          },
          onOpen: () => context.push('/favourites/poem/${poem.id}'),
        );
      },
    );
  }
}

class _FailureView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load favourites',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.lightFg,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Something went wrong. Please try again.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  context.read<FavouritesCubit>().loadFavourites();
                },
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
          ),
        ),
      ),
    );
  }
}
