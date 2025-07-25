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
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Filter products based on category & search
    final filteredProducts = productProvider.products.where((product) {
      final matchesCategory = _selectedCategory == 'all' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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

        // Category chips
        SizedBox(
          height: 40,
          child: productProvider.categories.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: productProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = productProvider.categories[index];
                    final isSelected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    );
                  },
                ),
        ),
        const SizedBox(height: kDefaultPaddin),

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
                                press: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(product: product),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
