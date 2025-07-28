import 'package:flutter/foundation.dart';

import '../model/medicine.dart';
import '../service/api_service.dart';
import '../service/preferences_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PreferencesService _preferencesService = PreferencesService();
  
  List<medicine> _products = [];
  List<medicine> _favorites = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<medicine> get products => _products;
  List<medicine> get favorites => _favorites;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    await fetchProducts();
    // Categories feature removed
    await loadFavorites();
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    _setLoading(true);
    _error = '';
    
    try {
      final products = await _apiService.getProducts();
      _products = products;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch product categories
  Future<void> fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      _categories = ['all', ...categories];
      notifyListeners();
    } catch (e) {
      
    }
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    try {
      _favorites = await _preferencesService.getFavorites();
      
      // Update isFavorite flag in products list
      _updateProductFavoriteStatus();
      
      notifyListeners();
    } catch (e) {
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(medicine product) async {
    try {
      final isFav = await _preferencesService.isFavorite(product.id);
      
      if (isFav) {
        await _preferencesService.removeFromFavorites(product.id);
        _favorites.removeWhere((p) => p.id == product.id);
      } else {
        final favoriteProduct = product.copyWith(isFavorite: true);
        await _preferencesService.addToFavorites(favoriteProduct);
        _favorites.add(favoriteProduct);
      }
      
      // Update product in products list
      _updateProductFavoriteStatus();
      
      notifyListeners();
    } catch (e) {
    }
  }

  // Helper method to update favorite status in products list
  void _updateProductFavoriteStatus() {
    for (var i = 0; i < _products.length; i++) {
      final isFav = _favorites.any((fav) => fav.id == _products[i].id);
      if (_products[i].isFavorite != isFav) {
        _products[i] = _products[i].copyWith(isFavorite: isFav);
      }
    }
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}