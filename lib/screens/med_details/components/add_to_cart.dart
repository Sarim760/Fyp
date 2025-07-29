import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helper/constants.dart';
import '../../../model/medicine.dart';
import '../../../service/cart_service.dart';
import '../../../providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'cart_counter.dart';

/// A button row that allows the user to quickly add the current [product]
/// to their cart (left icon) or proceed to checkout immediately ("Buy Now")
///
/// The "add to cart" action now hits the backend `/api/cart/add` endpoint.
/// A snackbar notifies the user of success or failure.
class AddToCart extends StatelessWidget {
  const AddToCart({super.key, required this.product});

  final medicine product;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: kDefaultPaddin),
            height: 50,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blue,
              ),
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/add_to_cart.svg",
                colorFilter:
                    const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              ),
              onPressed: () async {
                final cartService = CartService();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                try {
                  // Get quantity from CartCounter
                  final quantity = CartCounter.quantity;
                  
                  final success = await cartService.addItemToCart(
                    itemId: product.id.toString(),
                    quantity: quantity,
                  );
                  if (success) {
                    // refresh cart count
                    if (context.mounted) {
                      // Trigger provider to fetch latest items without waiting
                      // ignore: use_build_context_synchronously
                      context.read<CartProvider>().refreshCart();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $quantity item(s) to cart'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add item to cart'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // Direct checkout is out of scope for now. For consistency,
                // we add the item to the cart first, then navigate or inform
                // the user. Replace with your checkout flow when ready.
                final cartService = CartService();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                try {
                  // Get quantity from CartCounter
                  final quantity = CartCounter.quantity;
                  
                  final success = await cartService.addItemToCart(
                    itemId: product.id.toString(),
                    quantity: quantity,
                  );
                  if (success) {
                    if (context.mounted) {
                      context.read<CartProvider>().refreshCart();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $quantity item(s)! Proceed to checkout'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Navigate to a checkout/cart screen if implemented.
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add item to cart'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                "Buy  Now".toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
