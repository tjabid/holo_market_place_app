import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';

import '../../entities/cart/cart.dart';
import '../../repositories/cart_repository.dart';

class GetCart {
  final CartRepository repository;

  GetCart(this.repository);

  Future<Either<Failure, Cart>> call() async {
    return await repository.getCart();
  }
}