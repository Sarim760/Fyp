import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/medicine.dart';

class PreferencesService {
  static const String _favoritesKey = 'favorites';

  // Save favorite products to SharedPreferences
  Future<void> saveFavorites(List<medicine> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = favorites.map((product) => product.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonData));
  }

  // Get favorite products from SharedPreferences
  Future<List<medicine>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> jsonData = json.decode(favoritesJson);
    return jsonData.map((json) => medicine.fromJson(json)).toList();
  }

  // Add a product to favorites
  Future<void> addToFavorites(medicine product) async {
    final favorites = await getFavorites();
    
    // Check if product already exists in favorites
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product.copyWith(isFavorite: true));
      await saveFavorites(favorites);
    }
  }

  // Remove a product from favorites
  Future<void> removeFromFavorites(dynamic productId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((product) => product.id == productId);
    await saveFavorites(favorites);
  }

  // Check if a product is in favorites
  Future<bool> isFavorite(dynamic productId) async {
    final favorites = await getFavorites();
    return favorites.any((product) => product.id == productId);
  }
}