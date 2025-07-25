import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helper/constants.dart';
import '../../providers/product_provider.dart';
import '../med_details/details_screen.dart';
import 'components/item_card.dart';

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});

  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  String _searchQuery = '';
  // Category filter removed

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Filter products based on search query only
    final filteredProducts = productProvider.products.where((product) {
      return _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search products…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: kDefaultPaddin),

        // Category chips removed

        // Products grid
        Expanded(
          child: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading products',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => productProvider.fetchProducts(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : RefreshIndicator(
                          onRefresh: () => productProvider.fetchProducts(),
                          child: GridView.builder(
                            itemCount: filteredProducts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ItemCard(
                                product: product,
                                press: () {
                                  final provider = Provider.of<ProductProvider>(context, listen: false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider<ProductProvider>.value(
                                        value: provider,
                                        child: DetailsScreen(product: product),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
