import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';
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

  Future<void> loadProducts() async {
    emit(ProductsLoading());

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
            selectedCategory: 'All Items',
          )),
        );
      },
    );
  }

  Future<void> filterByCategory(String category) async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;

    emit(ProductsLoading());

    if (category == 'All Items') {
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
  
  // Advanced filtering with business logic in use case
  Future<void> loadProductsWithOptions({
    int? limit,
    String? sortBy,
  }) async {
    emit(ProductsLoading());
    
    final result = await getProductsUseCase.execute(
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

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}