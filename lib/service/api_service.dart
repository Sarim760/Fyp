import 'package:http/http.dart' as http;

import '../model/medicine.dart';
import '../helper/global_variables.dart';

class ApiService {
  // Base URL now fetched from global variables pointing to local backend
  final String baseUrl = GlobalVariables().localhost;

  Future<List<medicine>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/medicines'));
      
      if (response.statusCode == 200) {
        return productsFromJson(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      // Derive categories from medicines list since backend doesn't expose a categories endpoint yet
      final medicines = await getProducts();
      final categories = medicines.map((m) => m.category).toSet().toList();
      return categories;
    } catch (e) {
      throw Exception('Failed to derive categories: $e');
    }
  }

  // Optionally filter products by category on client side
  Future<List<medicine>> getProductsByCategory(String category) async {
    final all = await getProducts();
    return all.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }
}