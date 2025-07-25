import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../model/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CartProvider>().refreshCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.error.isNotEmpty) {
            return Center(child: Text(cart.error));
          }
          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final CartItem item = cart.items[index];
              return ListTile(
                leading: Image.network(item.product.image, width: 50, height: 50, fit: BoxFit.contain),
                title: Text(item.product.title),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: SizedBox(
                  width: 100, // Fixed width to prevent overflow
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          await cart.removeItem(item.product.id.toString());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: cart.items.isEmpty ? null : () {
                    // TODO: Implement checkout flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout not implemented yet')),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}