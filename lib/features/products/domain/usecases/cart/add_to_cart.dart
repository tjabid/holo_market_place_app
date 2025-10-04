import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product.dart';

import '../../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failure, void>> call(Product product) async {
    // TODO: implement addToCart
    throw UnimplementedError();
  }
}