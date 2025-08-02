import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../helper/constants.dart';
import '../../model/medicine.dart';
import '../../widgets/favorite_button.dart';
import 'components/add_to_cart.dart';
import 'components/color_and_size.dart';
import 'components/counter_with_fav_btn.dart';
import 'components/description.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.product});

  final medicine product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/back.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPaddin / 2),
                child: FavoriteButton(
                  product: product,
                ),
              ),
            ],
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Hero(
                  tag: "${product.id}",
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPaddin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & price
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kDefaultPaddin / 2),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kDefaultPaddin),
                  ColorAndSize(product: product),
                  const SizedBox(height: kDefaultPaddin),
                  Description(product: product),
                  const SizedBox(height: kDefaultPaddin),
                  CounterWithFavBtn(product: product),
                  const SizedBox(height: kDefaultPaddin * 2), // extra space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin, vertical: kDefaultPaddin / 2),
          child: AddToCart(product: product),
        ),
      ),
    );
  }
}
