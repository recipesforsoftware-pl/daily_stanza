import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/favourites/data/datasource/local_favourites_data_source.dart';
import 'package:daily_stanza/features/favourites/data/repository/favourites_repository_impl.dart';

void main() {
  group('FavouritesRepositoryImpl', () {
    late FavouritesRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = LocalFavouritesDataSource(sharedPreferences: prefs);
      repository = FavouritesRepositoryImpl(dataSource: dataSource);
    });

    test('initial state returns empty list', () async {
      final ids = await repository.getFavouritePoemIds();
      expect(ids, isEmpty);
    });

    test('initial isFavourite returns false', () async {
      expect(await repository.isFavourite('nonexistent'), isFalse);
    });

    test('addFavourite stores the ID', () async {
      await repository.addFavourite('poem1');
      final ids = await repository.getFavouritePoemIds();
      expect(ids, ['poem1']);
    });

    test('addFavourite prepends new IDs', () async {
      await repository.addFavourite('poem1');
      await repository.addFavourite('poem2');
      final ids = await repository.getFavouritePoemIds();
      expect(ids, ['poem2', 'poem1']);
    });

    test('adding same ID twice does not duplicate', () async {
      await repository.addFavourite('poem1');
      await repository.addFavourite('poem1');
      final ids = await repository.getFavouritePoemIds();
      expect(ids, ['poem1']);
    });

    test('isFavourite returns true after add', () async {
      await repository.addFavourite('poem1');
      expect(await repository.isFavourite('poem1'), isTrue);
    });

    test('removeFavourite removes the ID', () async {
      await repository.addFavourite('poem1');
      await repository.removeFavourite('poem1');
      expect(await repository.isFavourite('poem1'), isFalse);
      final ids = await repository.getFavouritePoemIds();
      expect(ids, isEmpty);
    });

    test('removing unknown ID is safe no-op', () async {
      await repository.addFavourite('poem1');
      await repository.removeFavourite('nonexistent');
      final ids = await repository.getFavouritePoemIds();
      expect(ids, ['poem1']);
    });

    test('values persist between repository instances', () async {
      await repository.addFavourite('persist-test');

      final prefs = await SharedPreferences.getInstance();
      final ds2 = LocalFavouritesDataSource(sharedPreferences: prefs);
      final repo2 = FavouritesRepositoryImpl(dataSource: ds2);
      expect(await repo2.getFavouritePoemIds(), ['persist-test']);
    });
  });
}
