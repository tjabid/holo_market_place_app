import 'package:equatable/equatable.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';
import '../../../domain/entities/product/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Category> categories;
  final String? selectedCategory;

  const ProductsLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory = "all",
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    String? selectedCategory,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [products, categories, selectedCategory];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}
