import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/cart_repository.dart';
import '../../entities/cart/cart.dart';
import '../../entities/cart/cart_item.dart';
import '../../entities/product.dart';
import '../../../../../core/error/failures.dart';

class AddToCartUseCase {
  final CartRepository repository;
  
  AddToCartUseCase(this.repository);

  Future<Either<Failure, Cart>> call({
    required Cart currentCart,
    required Product product,
    String? selectedSize,
  }) async {
    try {
      // Check if product already exists in cart with same size
      final existingItemIndex = currentCart.items.indexWhere(
        (item) =>
            item.product.id == product.id && item.selectedSize == selectedSize,
      );

      List<CartItem> updatedItems;
      
      if (existingItemIndex != -1) {
        // Product exists, increment quantity
        updatedItems = List.from(currentCart.items);
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Add new product
        final newItem = CartItem(
          id: product.id.toString(),
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
        );
        updatedItems = [...currentCart.items, newItem];
      }

      final updatedCart = currentCart.copyWith(items: updatedItems);
      
      repository.updateCart(updatedCart);//update the cart in repository

      return Right(updatedCart); // notifiy the UI about the change
    } catch (e) {
      return Left(CacheFailure('Failed to add item to cart: ${e.toString()}'));
    }
  }
}