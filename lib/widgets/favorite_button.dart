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
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(ProductProvider productProvider) async {
    if (_isAnimating) return;
    
    _isAnimating = true;
    
    // Bounce animation on tap
    await _bounceController.forward();
    await _bounceController.reverse();
    
    // Toggle favorite state
    productProvider.toggleFavorite(widget.product);
    
    // If favorited, start pulse animation
    if (widget.product.isFavorite) {
      _pulseController.repeat(reverse: true);
      // Stop pulse after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _pulseController.stop();
          _pulseController.reset();
        }
      });
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
    
    // Provide haptic feedback
    Feedback.forTap(context);
    
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final isFav = productProvider.favorites.any((fav) => fav.id == widget.product.id);

        return AnimatedBuilder(
          animation: Listenable.merge([_bounceController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value * _pulseAnimation.value,
              child: GestureDetector(
                onTap: () => _handleTap(productProvider),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    color: isFav
                        ? const Color(0xFFFF6464)
                        : const Color(0x1AFF6464),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isFav)
                        BoxShadow(
                          color: const Color(0x33FF6464),
                          blurRadius: 8 + (_pulseAnimation.value - 1) * 4,
                          spreadRadius: 1 + (_pulseAnimation.value - 1) * 2,
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: RotationTransition(
                          turns: Tween<double>(
                            begin: 0.0,
                            end: 0.1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFav),
                      color: isFav ? Colors.white : const Color(0xFFFF6464),
                      size: widget.size * 0.6,
                    ),
                  ),
                ),
              ).animate().shimmer(
                duration: isFav ? 600.ms : 0.ms,
                color: Colors.white.withOpacity(0.3),
              ).animate().shake(
                duration: isFav ? 300.ms : 0.ms,
                hz: 2,
                curve: Curves.easeOut,
              ),
            );
          },
        );
      },
    );
  }
}