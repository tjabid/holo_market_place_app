import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getCachedProducts();
  Future<void> cacheProducts(List<Product> products);

  Future<Product?> getProductById(int id);
  Future<List<Product>> getProductsByCategory(String category);

  Future<List<Category>> getCachedCategories();
  Future<void> cacheCategories(List<Category> categories);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  List<Category> categories = [];
  List<Product> allProducts = [];

  ProductLocalDataSourceImpl();

  @override
  Future<void> cacheCategories(List<Category> categories) {
    this.categories = categories;
    return Future.value();
  }

  @override
  Future<void> cacheProducts(List<Product> products) {
    allProducts = products;
    return Future.value();
  }

  @override
  Future<List<Category>> getCachedCategories() {
    return Future.value(categories);
  }

  @override
  Future<List<Product>> getCachedProducts() {
    return Future.value(allProducts);
  }

  @override
  Future<Product?> getProductById(int id) {
    final product = allProducts.where((product) => product.id == id).toList();
    return Future.value(product.isNotEmpty ? product.first : null);
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) {
    return Future.value(
        allProducts.where((product) => product.category.toLowerCase() == category.toLowerCase()).toList());
  }
}
