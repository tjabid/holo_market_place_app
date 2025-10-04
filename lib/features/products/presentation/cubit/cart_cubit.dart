import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart_item.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/get_cart.dart';
import 'package:holo_market_place_app/features/products/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;

  CartCubit({required this.getCartUseCase}) : super(const CartEmpty());

  // Promo codes map (code -> discount amount)
  final Map<String, double> _promoCodes = {
    'SAVE10': 10.0,
    'SAVE20': 20.0,
    'WELCOME': 5.0,
  };

  // Add product to cart
  void addToCart(Product product, {String? selectedSize}) {
    final currentState = state;
    
    // Get current cart or create empty one
    Cart cart;
    if (currentState is CartLoaded) {
      cart = currentState.cart;
    } else {
      cart = const Cart();
    }

    // Check if product already exists in cart
    final existingItemIndex = cart.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == selectedSize,
    );

    List<CartItem> updatedItems;
    if (existingItemIndex != -1) {
      // Product exists, increment quantity
      updatedItems = List.from(cart.items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Add new product
      final newItem = CartItem(
        id: '${product.id}_${selectedSize ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: 1,
        selectedSize: selectedSize,
      );
      updatedItems = [...cart.items, newItem];
    }

    final updatedCart = cart.copyWith(items: updatedItems);
    emit(CartLoaded(updatedCart));
  }

  // Remove item from cart
  void removeFromCart(String cartItemId) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedItems = currentState.cart.items
        .where((item) => item.id != cartItemId)
        .toList();

    if (updatedItems.isEmpty) {
      emit(const CartEmpty());
    } else {
      final updatedCart = currentState.cart.copyWith(items: updatedItems);
      emit(CartLoaded(updatedCart));
    }
  }

  // Update item quantity
  void updateQuantity(String cartItemId, int newQuantity) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final updatedItems = currentState.cart.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    final updatedCart = currentState.cart.copyWith(items: updatedItems);
    emit(CartLoaded(updatedCart));
  }

  // Increment quantity
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

  // Apply promo code
  void applyPromoCode(String promoCode) {
    final currentState = state;
    if (currentState is! CartLoaded) {
      emit(const CartError('Cart is empty'));
      return;
    }

    emit(const CartLoading());

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final discount = _promoCodes[promoCode.toUpperCase()];
      
      if (discount != null) {
        final updatedCart = currentState.cart.copyWith(
          discount: discount,
          promoCode: promoCode.toUpperCase(),
        );
        emit(CartLoaded(updatedCart));
      } else {
        emit(const CartError('Invalid promo code'));
        // Restore previous state after showing error
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      }
    });
  }

  // Remove promo code
  void removePromoCode() {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedCart = currentState.cart.copyWith(
      discount: 0.0,
      promoCode: null,
    );
    emit(CartLoaded(updatedCart));
  }

  // Clear entire cart
  void clearCart() {
    emit(const CartEmpty());
  }

  // Update shipping cost
  void updateShippingCost(double newShippingCost) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedCart = currentState.cart.copyWith(shippingCost: newShippingCost);
    emit(CartLoaded(updatedCart));
  }

  // Get cart item count
  int getItemCount() {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.cart.itemCount;
    }
    return 0;
  }

  // Get cart total
  double getCartTotal() {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.cart.total;
    }
    return 0.0;
  }
}
