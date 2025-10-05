import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/entities/category.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  
  ProductRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final cachedProducts = await localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Right(cachedProducts);
      }

      final products = await remoteDataSource.getProducts();
      final productEntities = products.map((model) => mapProductEntity(model)).toList();

      localDataSource.cacheProducts(productEntities); // Cache all products

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
      final allProducts = await localDataSource.getProductsByCategory(category);
      if (allProducts.isNotEmpty) {
          return Right(allProducts);
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
      final cachedCategories = await localDataSource.getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        return Right(cachedCategories);
      }

      final categories = await remoteDataSource.getCategories();
      
      // cache in memory
      localDataSource.cacheCategories(categories);

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
