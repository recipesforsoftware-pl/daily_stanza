import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit({
    required FavouritesRepository favouritesRepository,
    required PoemRepository poemRepository,
  }) : _favouritesRepository = favouritesRepository,
       _poemRepository = poemRepository,
       super(const FavouritesInitial());

  final FavouritesRepository _favouritesRepository;
  final PoemRepository _poemRepository;

  Future<void> loadFavourites() async {
    emit(const FavouritesLoading());

    try {
      final storedIds = await _favouritesRepository.getFavouritePoemIds();

      if (storedIds.isEmpty) {
        emit(const FavouritesLoaded(poems: [], favouriteIds: {}));
        return;
      }

      List<Poem> poems;
      try {
        poems = await _poemRepository.getPoemsByIds(storedIds);
      } catch (_) {
        // Poem loading failed — preserve stored IDs so the heart state in
        // Today remains consistent with local persistence.
        emit(
          FavouritesLoaded(poems: const [], favouriteIds: storedIds.toSet()),
        );
        return;
      }

      // Preserve stored order; skip poems that no longer exist.
      final foundIds = poems.map((p) => p.id).toSet();
      final validIds = storedIds.where((id) => foundIds.contains(id)).toList();
      final orderedPoems = validIds
          .map((id) => poems.firstWhere((p) => p.id == id))
          .toList();

      emit(
        FavouritesLoaded(poems: orderedPoems, favouriteIds: storedIds.toSet()),
      );
    } catch (_) {
      emit(const FavouritesFailure());
    }
  }

  Future<void> addFavourite(Poem poem) async {
    if (state is! FavouritesLoaded) return;
    final loaded = state as FavouritesLoaded;
    if (loaded.updatingPoemIds.contains(poem.id)) return;
    if (loaded.favouriteIds.contains(poem.id)) return;

    emit(
      FavouritesLoaded(
        poems: loaded.poems,
        favouriteIds: loaded.favouriteIds,
        updatingPoemIds: {...loaded.updatingPoemIds, poem.id},
      ),
    );

    try {
      await _favouritesRepository.addFavourite(poem.id);
      final newFavouriteIds = {poem.id, ...loaded.favouriteIds};
      final newPoems = loaded.poems.where((p) => p.id != poem.id).toList()
        ..insert(0, poem);
      emit(FavouritesLoaded(poems: newPoems, favouriteIds: newFavouriteIds));
    } catch (_) {
      emit(
        FavouritesLoaded(
          poems: loaded.poems,
          favouriteIds: loaded.favouriteIds,
          mutationError: 'Failed to save. Please try again.',
        ),
      );
    }
  }

  Future<void> removeFavourite(String poemId) async {
    if (state is! FavouritesLoaded) return;
    final loaded = state as FavouritesLoaded;
    if (loaded.updatingPoemIds.contains(poemId)) return;

    emit(
      FavouritesLoaded(
        poems: loaded.poems,
        favouriteIds: loaded.favouriteIds,
        updatingPoemIds: {...loaded.updatingPoemIds, poemId},
      ),
    );

    try {
      await _favouritesRepository.removeFavourite(poemId);
      final newFavouriteIds = Set<String>.from(loaded.favouriteIds)
        ..remove(poemId);
      final newPoems = loaded.poems.where((p) => p.id != poemId).toList();
      emit(FavouritesLoaded(poems: newPoems, favouriteIds: newFavouriteIds));
    } catch (_) {
      emit(
        FavouritesLoaded(
          poems: loaded.poems,
          favouriteIds: loaded.favouriteIds,
          mutationError: 'Failed to save. Please try again.',
        ),
      );
    }
  }

  Future<void> toggleFavourite(Poem poem) async {
    if (state is! FavouritesLoaded) return;
    if ((state as FavouritesLoaded).isFavourite(poem.id)) {
      await removeFavourite(poem.id);
    } else {
      await addFavourite(poem);
    }
  }

  bool isFavourite(String poemId) {
    return state is FavouritesLoaded &&
        (state as FavouritesLoaded).isFavourite(poemId);
  }
}
