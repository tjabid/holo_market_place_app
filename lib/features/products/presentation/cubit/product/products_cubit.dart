import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/product/get_products.dart';
import '../../../domain/usecases/product/get_categories.dart';
import '../../../domain/usecases/product/get_products_by_category.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductsCubit({
    required this.getProductsUseCase,
    required this.getProductsByCategoryUseCase,
    required this.getCategoriesUseCase,
  }) : super(ProductsInitial());

  /// Load all products with categories
  Future<void> loadProducts() async {
    emit(ProductsLoading());
    
    final currentState = (state is ProductsLoaded) ? state as ProductsLoaded : null;
    final selectedCategory = currentState?.selectedCategory ?? 'all';

    final productsResult = await getProductsUseCase();
    final categoriesResult = await getCategoriesUseCase();

    productsResult.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) {
        categoriesResult.fold(
          (failure) => emit(ProductsError(failure.message)),
          (categories) => emit(ProductsLoaded(
            products: products,
            categories: categories,
            selectedCategory: selectedCategory,
          )),
        );
      },
    );
  }

  /// Filter products by category
  Future<void> filterByCategory(String category) async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;

    emit(ProductsLoading());

    if (category == 'all') {
      final result = await getProductsUseCase();
      result.fold(
        (failure) => emit(ProductsError(failure.message)),
        (products) => emit(currentState.copyWith(
          products: products,
          selectedCategory: category,
        )),
      );
    } else {
      final result = await getProductsByCategoryUseCase(category);
      result.fold(
        (failure) => emit(ProductsError(failure.message)),
        (products) => emit(currentState.copyWith(
          products: products,
          selectedCategory: category,
        )),
      );
    }
  }
  
  /// Advanced filtering with business logic in use case
  Future<void> loadProductsWithOptions({
    int? limit,
    String? sortBy,
  }) async {
    emit(ProductsLoading());

    final result = await getProductsUseCase(
      limit: limit,
      sortBy: sortBy,
    );

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) async {
        final categoriesResult = await getCategoriesUseCase();
        categoriesResult.fold(
          (failure) => emit(ProductsError(failure.message)),
          (categories) => emit(ProductsLoaded(
            products: products,
            categories: categories,
            selectedCategory: 'All Items',
          )),
        );
      },
    );
  }

  /// Refresh products (reload from server)
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  /// Sort current products without refetching
  Future<void> sortProducts(String sortBy) async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;

    emit(ProductsLoading());

    // Refetch with sort parameter
    final result = await getProductsUseCase(sortBy: sortBy);

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(currentState.copyWith(
        products: products,
      )),
    );
  }
}