import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'hymn_favorites';

  static Future<Set<int>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      return favoritesJson.map((e) => int.parse(e)).toSet();
    } catch (e) {
      print('Error loading favorites: $e');
      return <int>{};
    }
  }

  static Future<void> saveFavorites(Set<int> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((e) => e.toString()).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  static Future<void> addFavorite(int hymnNumber) async {
    final favorites = await loadFavorites();
    favorites.add(hymnNumber);
    await saveFavorites(favorites);
  }

  static Future<void> removeFavorite(int hymnNumber) async {
    final favorites = await loadFavorites();
    favorites.remove(hymnNumber);
    await saveFavorites(favorites);
  }

  static Future<bool> isFavorite(int hymnNumber) async {
    final favorites = await loadFavorites();
    return favorites.contains(hymnNumber);
  }

  static Future<bool> toggleFavorite(int hymnNumber) async {
    final favorites = await loadFavorites();
    final wasFavorite = favorites.contains(hymnNumber);
    
    if (wasFavorite) {
      favorites.remove(hymnNumber);
    } else {
      favorites.add(hymnNumber);
    }
    
    await saveFavorites(favorites);
    return !wasFavorite;
  }
}