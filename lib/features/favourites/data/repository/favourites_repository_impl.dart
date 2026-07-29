import 'package:daily_stanza/features/favourites/data/datasource/local_favourites_data_source.dart';
import 'package:daily_stanza/features/favourites/domain/repository/favourites_repository.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  const FavouritesRepositoryImpl({
    required LocalFavouritesDataSource dataSource,
  }) : _dataSource = dataSource;

  final LocalFavouritesDataSource _dataSource;

  @override
  Future<List<String>> getFavouritePoemIds() async {
    return _dataSource.getFavouritePoemIds();
  }

  @override
  Future<bool> isFavourite(String poemId) async {
    final ids = _dataSource.getFavouritePoemIds();
    return ids.contains(poemId);
  }

  @override
  Future<void> addFavourite(String poemId) async {
    final ids = _dataSource.getFavouritePoemIds();
    ids.remove(poemId);
    ids.insert(0, poemId);
    await _dataSource.saveFavouritePoemIds(ids);
  }

  @override
  Future<void> removeFavourite(String poemId) async {
    final ids = _dataSource.getFavouritePoemIds();
    ids.remove(poemId);
    await _dataSource.saveFavouritePoemIds(ids);
  }
}
