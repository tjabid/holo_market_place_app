import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/cart_icon_badge.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Search Bar
            _buildSearchBar(context),
            
            const SizedBox(height: 20),
            
            // Category Filters
            BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoaded) {
                  return CategoryFilterChips(
                    categories: state.categories,
                    selectedCategory: state.selectedCategory ?? 'All Items',
                    onCategorySelected: (category) {
                      context.read<ProductsCubit>().filterByCategory(category);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 20),
            
            // Products Grid
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  } else if (state is ProductsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<ProductsCubit>().refreshProducts(),
                      child: ProductGrid(products: state.products),
                    );
                  } else if (state is ProductsError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ProductsCubit>().loadProducts(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search clothes...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Cart Icon with Badge
          const CartIconBadge(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavBarItem(icon: Icons.home, isSelected: true),
            _NavBarItem(icon: Icons.shopping_bag_outlined, isSelected: false),
            _NavBarItem(icon: Icons.favorite_border, isSelected: false),
            _NavBarItem(icon: Icons.person_outline, isSelected: false),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.isSelected,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 28,
      ),
    );
  }
}
