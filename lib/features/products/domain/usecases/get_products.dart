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
  Future<Either<Failure, List<Product>>> call({
    int? limit,
    String? sortBy,
  }) async {
    // Fetch products from repository
    final result = await repository.getProducts();
    
    // If no parameters, return as is
    if (limit == null && sortBy == null) {
      return result;
    }
    
    // Apply business rules based on parameters
    return result.fold(
      (failure) => Left(failure),
      (products) {
        var filteredProducts = products;
        
        // Apply sorting first
        if (sortBy != null) {
          filteredProducts = _applySorting(filteredProducts, sortBy);
        }
        
        // Apply limit after sorting
        if (limit != null && limit > 0) {
          filteredProducts = filteredProducts.take(limit).toList();
        }
        
        return Right(filteredProducts);
      },
    );
  }
  
  /// Helper method to apply sorting logic
  List<Product> _applySorting(List<Product> products, String sortBy) {
    final sortedProducts = List<Product>.from(products);
    
    switch (sortBy.toLowerCase()) {
      case 'price_asc':
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
      case 'rating_desc':
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'rating_asc':
        sortedProducts.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'name':
      case 'name_asc':
        sortedProducts.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'name_desc':
        sortedProducts.sort((a, b) => b.title.compareTo(a.title));
        break;
      default:
        // No sorting or unknown sort type
        break;
    }
    
    return sortedProducts;
  }
}