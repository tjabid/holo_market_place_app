import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/failures.dart';

import '../entities/cart/cart.dart';

abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();
  
  Future<void> addToCart(int productId, int quantity);
  Future<void> removeFromCart(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clearCart();

  Future<List<String>?> getAvailablePromoCodes();
  Future<void> applyPromoCode(String promoCode);
  Future<void> removePromoCode();
}