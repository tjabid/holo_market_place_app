import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/cart_repository.dart';
import '../../entities/cart/cart.dart';
import '../../../../../core/error/failures.dart';

class UpdateQuantityUseCase {
  final CartRepository repository;

  UpdateQuantityUseCase(this.repository);

  Future<Either<Failure, Cart?>> call({
    required Cart currentCart,
    required String cartItemId,
    required int newQuantity,
  }) async {
    try {
      // If quantity is 0 or negative, remove the item
      if (newQuantity <= 0) {
        final updatedItems =
            currentCart.items.where((item) => item.id != cartItemId).toList();

        final updatedCart = currentCart.copyWith(items: updatedItems);
        repository.updateCart(updatedCart); //update the cart in repository

        // Return null if cart becomes empty
        if (updatedItems.isEmpty) {
          return const Right(null);
        } else {
          return Right(updatedCart);
        }
      }

      // Update the quantity
      final updatedItems = currentCart.items.map((item) {
        if (item.id == cartItemId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList();

      final updatedCart = currentCart.copyWith(items: updatedItems);

      repository.updateCart(updatedCart); //update the cart in repository

      return Right(updatedCart); // notify the UI about the change
    } catch (e) {
      return Left(CacheFailure('Failed to update quantity: ${e.toString()}'));
    }
  }
}
