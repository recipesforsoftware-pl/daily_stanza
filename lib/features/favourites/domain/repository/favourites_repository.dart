abstract interface class FavouritesRepository {
  Future<List<String>> getFavouritePoemIds();

  Future<bool> isFavourite(String poemId);

  Future<void> addFavourite(String poemId);

  Future<void> removeFavourite(String poemId);
}
