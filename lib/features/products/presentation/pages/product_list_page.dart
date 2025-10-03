import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer_loading.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            
            const SizedBox(height: 20),
            
            // Products Grid
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const ShimmerLoading();
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
    );
  }
}
