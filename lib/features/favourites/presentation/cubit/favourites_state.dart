import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

sealed class FavouritesState extends Equatable {
  const FavouritesState();
}

final class FavouritesInitial extends FavouritesState {
  const FavouritesInitial();

  @override
  List<Object> get props => [];
}

final class FavouritesLoading extends FavouritesState {
  const FavouritesLoading();

  @override
  List<Object> get props => [];
}

final class FavouritesLoaded extends FavouritesState {
  const FavouritesLoaded({
    required this.poems,
    required this.favouriteIds,
    this.updatingPoemIds = const {},
    this.mutationError,
  });

  final List<Poem> poems;
  final Set<String> favouriteIds;
  final Set<String> updatingPoemIds;

  /// One-time error message from a failed add/remove mutation.
  ///
  /// The presentation layer should show it (e.g. via SnackBar) and let the
  /// next emission clear it naturally.
  final String? mutationError;

  bool isFavourite(String poemId) => favouriteIds.contains(poemId);

  @override
  List<Object?> get props => [
    poems,
    favouriteIds,
    updatingPoemIds,
    mutationError,
  ];
}

final class FavouritesFailure extends FavouritesState {
  const FavouritesFailure();

  @override
  List<Object> get props => [];
}
