import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/entities/category.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call() async {
    final result = await repository.getCategories();
    
    // Business logic: Add "All Items" at the beginning
    return result.fold(
      (failure) => Left(failure),
      (categories) {        
        return Right(categories);
      },
    );
  }
}