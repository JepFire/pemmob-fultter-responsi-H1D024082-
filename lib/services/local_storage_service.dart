import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _searchHistoryKey = 'search_history';
  static const String _lastLocationKey = 'last_location';

  // ─── Favorite Locations ───────────────────────────────────────────────────

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((e) => LocationModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.any((l) => l.id == location.id)) {
      favorites.add(location);
      await prefs.setStringList(
        _favoritesKey,
        favorites.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
  }

  Future<void> removeFavorite(int locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((l) => l.id == locationId);
    await prefs.setStringList(
      _favoritesKey,
      favorites.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<bool> isFavorite(int locationId) async {
    final favorites = await getFavorites();
    return favorites.any((l) => l.id == locationId);
  }

  // ─── Search History ───────────────────────────────────────────────────────

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    history.remove(query); // hapus duplikat
    history.insert(0, query);
    final limited = history.take(10).toList(); // simpan max 10
    await prefs.setStringList(_searchHistoryKey, limited);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  // ─── Last Selected Location ───────────────────────────────────────────────

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }
}
