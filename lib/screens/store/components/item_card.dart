import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../helper/constants.dart';
import '../../../model/medicine.dart';
import '../../../widgets/favorite_button.dart';

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
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
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
