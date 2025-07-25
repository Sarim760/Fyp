import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../helper/constants.dart';
import '../../../model/medicine.dart';
import '../../../widgets/favorite_button.dart';
import '../../med_details/details_screen.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.product, required this.press});

  final medicine product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    // Fade-in animation when the card appears in the grid
    return GestureDetector(
      onTap: press,
      child: Column(
        // Trigger animation on build
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(kDefaultPaddin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: "${product.id}",
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    product: product,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 4),
            child: Text(
              product.title,
              style: const TextStyle(color: kTextLightColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ).animate().fade(duration: 400.ms, curve: Curves.easeIn),
    );
  }
}
