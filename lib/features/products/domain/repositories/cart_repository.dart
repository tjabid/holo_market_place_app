import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';

import '../entities/cart/cart.dart';

abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();
  
  Future<Either<Failure, void>> updateCart(Cart cart);
  Future<Either<Failure, void>> clearCart();

  Future<Either<Failure, List<String>>> getAvailablePromoCodes();
  Future<Either<Failure, void>> applyPromoCode(String promoCode);
  Future<Either<Failure, void>> removePromoCode();
}