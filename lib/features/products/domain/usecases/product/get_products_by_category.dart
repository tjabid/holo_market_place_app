import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/product/product.dart';
import '../../repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call(String category) async {
    // Validation - business rule
    if (category.trim().isEmpty) {
      return const Left(ValidationFailure('Category cannot be empty'));
    }
    
    // Convert to lowercase for consistency
    final normalizedCategory = category.toLowerCase().trim();
    
    return await repository.getProductsByCategory(normalizedCategory);
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}