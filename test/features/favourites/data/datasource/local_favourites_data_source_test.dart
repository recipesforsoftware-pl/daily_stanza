import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_stanza/features/favourites/data/datasource/local_favourites_data_source.dart';

void main() {
  group('LocalFavouritesDataSource', () {
    late LocalFavouritesDataSource dataSource;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> setUpDataSource() async {
      final prefs = await SharedPreferences.getInstance();
      dataSource = LocalFavouritesDataSource(sharedPreferences: prefs);
    }

    test('missing key returns an empty list', () async {
      await setUpDataSource();
      expect(dataSource.getFavouritePoemIds(), isEmpty);
    });

    test('existing IDs are returned in stored order', () async {
      SharedPreferences.setMockInitialValues({
        'favourite_poem_ids': <String>['c', 'a', 'b'],
      });
      await setUpDataSource();
      expect(dataSource.getFavouritePoemIds(), ['c', 'a', 'b']);
    });

    test('blank IDs are ignored', () async {
      SharedPreferences.setMockInitialValues({
        'favourite_poem_ids': <String>['a', '', 'b', '  '],
      });
      await setUpDataSource();
      expect(dataSource.getFavouritePoemIds(), ['a', 'b']);
    });

    test('duplicate IDs are removed', () async {
      SharedPreferences.setMockInitialValues({
        'favourite_poem_ids': <String>['a', 'b', 'a'],
      });
      await setUpDataSource();
      expect(dataSource.getFavouritePoemIds(), ['a', 'b']);
    });

    test('adding an ID stores it', () async {
      await setUpDataSource();
      await dataSource.saveFavouritePoemIds(['poem1']);
      expect(dataSource.getFavouritePoemIds(), ['poem1']);
    });

    test('newly added ID appears first', () async {
      await setUpDataSource();
      await dataSource.saveFavouritePoemIds(['a']);
      await dataSource.saveFavouritePoemIds(['b', 'a']);
      expect(dataSource.getFavouritePoemIds(), ['b', 'a']);
    });

    test('adding an existing ID does not duplicate it', () async {
      await setUpDataSource();
      await dataSource.saveFavouritePoemIds(['a']);
      await dataSource.saveFavouritePoemIds(['a']);
      expect(dataSource.getFavouritePoemIds(), ['a']);
    });

    test('removing an ID removes it', () async {
      SharedPreferences.setMockInitialValues({
        'favourite_poem_ids': <String>['a', 'b'],
      });
      await setUpDataSource();
      await dataSource.saveFavouritePoemIds(['b']);
      expect(dataSource.getFavouritePoemIds(), ['b']);
    });

    test(
      'values persist between reads using the same SharedPreferences',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final ds1 = LocalFavouritesDataSource(sharedPreferences: prefs);
        await ds1.saveFavouritePoemIds(['x', 'y']);

        final ds2 = LocalFavouritesDataSource(sharedPreferences: prefs);
        expect(ds2.getFavouritePoemIds(), ['x', 'y']);
      },
    );
  });
}
