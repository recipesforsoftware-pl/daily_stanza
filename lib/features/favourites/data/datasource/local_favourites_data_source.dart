import 'package:shared_preferences/shared_preferences.dart';

class LocalFavouritesDataSource {
  LocalFavouritesDataSource({required SharedPreferences sharedPreferences})
    : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String favouritePoemIdsKey = 'favourite_poem_ids';

  /// Returns stored poem IDs.
  ///
  /// Returns an empty list when the key is missing.
  /// Filters out blank IDs and removes duplicates, preserving first occurrence
  /// order.
  List<String> getFavouritePoemIds() {
    final ids = _prefs.getStringList(favouritePoemIdsKey);
    if (ids == null) return [];
    return _cleanIds(ids);
  }

  /// Persists the given list of poem IDs.
  ///
  /// Removes blanks and duplicates before saving.
  Future<void> saveFavouritePoemIds(List<String> ids) async {
    await _prefs.setStringList(favouritePoemIdsKey, _cleanIds(ids));
  }

  List<String> _cleanIds(List<String> ids) {
    final seen = <String>{};
    final result = <String>[];
    for (final id in ids) {
      if (id.trim().isEmpty) continue;
      if (seen.contains(id)) continue;
      seen.add(id);
      result.add(id);
    }
    return result;
  }
}
