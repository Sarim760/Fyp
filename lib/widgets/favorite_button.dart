import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../model/medicine.dart';
import '../providers/product_provider.dart';

class FavoriteButton extends StatefulWidget {
  final medicine product;
  final double size;

  const FavoriteButton({
    super.key,
    required this.product,

    this.size = 32,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  void _handleTap(ProductProvider productProvider) async {
    // Toggle favorite state first so UI reflects change instantly
    productProvider.toggleFavorite(widget.product);
    // Provide a subtle haptic feedback when available
    Feedback.forTap(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final isFav = widget.product.isFavorite;

        return GestureDetector(
          onTap: () => _handleTap(productProvider),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: isFav
                  ? ( const Color(0xFFFF6464))
                  : (const Color(0x1AFF6464)),
              shape: BoxShape.circle,
              boxShadow: [
                if (isFav)
                  const BoxShadow(
                    color: Color(0x33FF6464),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFav),
                color: isFav ? Colors.white : const Color(0xFFFF6464),
                size: widget.size * 0.6,
              ),
            ),
          ).animate().shake(duration: 300.ms, hz: 3, curve: Curves.easeOut),
        );
      },
    );
  }
}