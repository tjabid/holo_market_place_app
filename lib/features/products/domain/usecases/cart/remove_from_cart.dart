import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product.dart';

import '../../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Either<Failure, void>> call(Product product) async {
    // TODO: implement removeFromCart
    throw UnimplementedError();
  }
}