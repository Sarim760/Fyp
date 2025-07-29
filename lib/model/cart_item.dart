import 'medicine.dart';

class CartItem {
  final String id; // Cart item ID (could be same as product id)
  final medicine product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: medicine.fromJson(json['item'] ?? json['product'] ?? json),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
} 