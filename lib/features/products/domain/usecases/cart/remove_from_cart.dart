import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/cart_repository.dart';
import '../../entities/cart/cart.dart';
import '../../../../../core/error/failures.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Either<Failure, Cart?>> call({
    required Cart currentCart,
    required String cartItemId
  }) async {
    try {
      final updatedItems =
          currentCart.items.where((item) => item.id != cartItemId).toList();

      final updatedCart = currentCart.copyWith(items: updatedItems);
      repository.updateCart(updatedCart); //update the cart in repository

      // Return null if cart becomes empty, otherwise return updated cart
      if (updatedItems.isEmpty) {
        return const Right(null);
      } else {
        return Right(updatedCart);
      }
    } catch (e) {
      return Left(
          CacheFailure('Failed to remove item from cart: ${e.toString()}'));
    }
  }
}
