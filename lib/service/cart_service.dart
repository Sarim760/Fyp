import 'package:dio/dio.dart';
import '../helper/Global_variables.dart';
import '../bloc/auth/authentication_bloc.dart';
import '../model/cart_item.dart';

class CartService {
  final Dio _dio = Dio();
  final String _baseUrl = globalvariables().apiString;

  /// Adds an item to the authenticated user's cart.
  /// Returns `true` when the backend responds with HTTP 201 (Created).
  Future<bool> addItemToCart({required String itemId, int quantity = 1}) async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    if (token == null) {
      throw Exception('User not authenticated. Please log in to add items to your cart.');
    }

    final response = await _dio.post(
      '$_baseUrl/cart/add',
      data: {
        'itemId': itemId,
        'quantity': quantity,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    return response.statusCode == 201;
  }

  /// Removes an item from the authenticated user's cart.
  /// Returns `true` when the backend responds with HTTP 200 (OK).
  Future<bool> removeItemFromCart({required String itemId}) async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    if (token == null) {
      throw Exception('User not authenticated. Please log in to remove items from your cart.');
    }

    final response = await _dio.delete(
      '$_baseUrl/cart/remove/$itemId',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    return response.statusCode == 200;
  }

  /// Fetch the authenticated user's cart items.
  Future<List<CartItem>> fetchCartItems() async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final response = await _dio.get(
      '$_baseUrl/cart',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['cartItems'] ?? [];
      return data.map((e) => CartItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch cart');
    }
  }

  /// Clear entire cart.
  Future<bool> clearCart() async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final response = await _dio.delete(
      '$_baseUrl/cart/clear',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );
    return response.statusCode == 200;
  }
} 