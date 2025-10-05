import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/entities/category.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  
  List<Category> categories = [];
  List<Product> allProducts = [];

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      if (allProducts.isNotEmpty) {
        return Right(allProducts);
      }

      final products = await remoteDataSource.getProducts();
      final productEntities = products.map((model) => mapProductEntity(model)).toList();
      
      allProducts = productEntities; // Cache all products

      return Right(productEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(mapProductEntity(product));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category) async {
    try {
      if (allProducts.isNotEmpty) {
        if (category.toLowerCase() == 'all') {
          return Right(allProducts);
        } else {
          final filteredProducts = allProducts
              .where((product) => product.category.toLowerCase() == category.toLowerCase())
              .toList();
          return Right(filteredProducts);
        }
      }
      
      final products = await remoteDataSource.getProductsByCategory(category);
      return Right(products.map((model) => mapProductEntity(model)).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      if (this.categories.isNotEmpty) {
        return Right(this.categories);
      }

      final categories = await remoteDataSource.getCategories();
      this.categories = categories; //cache categories
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
