import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';
import '../../../../core/error/failures.dart';
import '../entities/product/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(int id);
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category);
  Future<Either<Failure, List<Category>>> getCategories();
}
