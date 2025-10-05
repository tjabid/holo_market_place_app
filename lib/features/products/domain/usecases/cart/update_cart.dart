import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';

import '../../entities/cart/cart.dart';
import '../../repositories/cart_repository.dart';

class UpdateCartUseCase {
  final CartRepository repository;

  UpdateCartUseCase(this.repository);

  Future<Either<Failure, void>> call(Cart cart) async {
    return await repository.updateCart(cart);
  }
}