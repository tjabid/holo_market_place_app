import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    final result = await repository.getCategories();
    
    // Business logic: Add "All Items" at the beginning
    return result.fold(
      (failure) => Left(failure),
      (categories) {
        // Capitalize categories for better UX
        final capitalizedCategories = categories
            .map((cat) => _capitalize(cat))
            .toList();
        
        return Right(['All Items', ...capitalizedCategories]);
      },
    );
  }
  
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}