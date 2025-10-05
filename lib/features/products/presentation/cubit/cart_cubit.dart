import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/clear_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/get_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/add_to_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/remove_from_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/update_quantity.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/cart_calculation.dart';
import 'package:holo_market_place_app/features/products/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;
  final ClearCartUseCase clearCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateQuantityUseCase updateQuantityUseCase;
  final CartCalculationUseCase cartCalculationUseCase;

  CartCubit({
    required this.getCartUseCase,
    required this.clearCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateQuantityUseCase,
    required this.cartCalculationUseCase,
  }) : super(const CartEmpty()) {
    loadCart();
  }

  /// Load all products with categories
  Future<void> loadCart() async {
    emit(const CartLoading());

    final cartResult = await getCartUseCase();

    cartResult.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

    // Add product to cart
  void addToCart(Product product, {String? selectedSize}) async {
    final currentState = state;

    // Get current cart or create empty one
    Cart cart;
    if (currentState is CartLoaded) {
      cart = currentState.cart;
    } else {
      cart = const Cart();
    }

    final result = await addToCartUseCase(
      currentCart: cart,
      product: product,
      selectedSize: selectedSize,
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (updatedCart) => emit(CartLoaded(updatedCart)),
    );
  }

  // Remove item from cart
  void removeFromCart(String cartItemId) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final result = await removeFromCartUseCase(
      currentCart: currentState.cart,
      cartItemId: cartItemId,
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (updatedCart) {
        if (updatedCart == null) {
          emit(const CartEmpty());
        } else {
          emit(CartLoaded(updatedCart));
        }
      },
    );
  }

  // Update item quantity
  void updateQuantity(String cartItemId, int newQuantity) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final result = await updateQuantityUseCase(
      currentCart: currentState.cart,
      cartItemId: cartItemId,
      newQuantity: newQuantity,
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (updatedCart) {
        if (updatedCart == null) {
          emit(const CartEmpty());
        } else {
          emit(CartLoaded(updatedCart));
        }
      },
    );
  }  // Increment quantity
  void incrementQuantity(String cartItemId) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    try {
      final item = currentState.cart.items.firstWhere(
        (item) => item.id == cartItemId,
        orElse: () => throw StateError('Cart item not found'),
      );
      updateQuantity(cartItemId, item.quantity + 1);
    } catch (e) {
      // Item not found, do nothing or optionally emit an error state
      emit(const CartError('Item not found in cart'));
      return;
    }
  }

  // Decrement quantity
  void decrementQuantity(String cartItemId) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    try {
      final item = currentState.cart.items.firstWhere(
        (item) => item.id == cartItemId,
        orElse: () => throw StateError('Cart item not found'),
      );
      updateQuantity(cartItemId, item.quantity - 1);
    } catch (e) {
      // Item not found, do nothing or optionally emit an error state
      emit(const CartError('Item not found in cart'));
      return;
    }
  }

  // Clear entire cart
  void clearCart() {
    clearCartUseCase();
    emit(const CartEmpty());
  }

  // Update shipping cost
  void updateShippingCost(double newShippingCost) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedCart =
        currentState.cart.copyWith(shippingCost: newShippingCost);
    emit(CartLoaded(updatedCart));
  }

  // Get cart item count
  int getItemCount() {
    final currentState = state;
    if (currentState is CartLoaded) {
      return cartCalculationUseCase.getItemCount(currentState.cart);
    }
    return 0;
  }

  // Get cart total
  double getCartTotal() {
    final currentState = state;
    if (currentState is CartLoaded) {
      return cartCalculationUseCase.getCartTotal(currentState.cart);
    }
    return 0.0;
  }
}
