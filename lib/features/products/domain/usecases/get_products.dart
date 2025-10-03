import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

// Use Case for fetching all products
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  /// Execute the use case
  /// 
  /// Returns Either<Failure, List<Product>>
  /// - Left: Failure if something went wrong
  /// - Right: List of products if successful
  Future<Either<Failure, List<Product>>> call() async {
    // business logic
    // For example:
    
    // 1. Log analytics
    // analyticsService.logEvent('products_fetched');
    
    // 2. Apply business rules
    // if (userHasPremiumSubscription) {
    //   return repository.getPremiumProducts();
    // }
    
    // 3. For now, just delegate to repository
    return await repository.getProducts();
  }
  
  /// Alternative: Execute with parameters
  /// You could also add parameters for more control
  Future<Either<Failure, List<Product>>> execute({
    int? limit,
    String? sortBy,
  }) async {
    final result = await repository.getProducts();
    
    // Apply business rules based on parameters
    return result.fold(
      (failure) => Left(failure),
      (products) {
        var filteredProducts = products;
        
        // Apply limit
        if (limit != null && limit > 0) {
          filteredProducts = products.take(limit).toList();
        }
        
        // Apply sorting
        if (sortBy == 'price_asc') {
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        } else if (sortBy == 'price_desc') {
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        } else if (sortBy == 'rating') {
          filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        }
        
        return Right(filteredProducts);
      },
    );
  }
}