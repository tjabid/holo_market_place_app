import 'package:equatable/equatable.dart';
import '../../domain/entities/cart/cart.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

// Initial state
class CartInitial extends CartState {
  const CartInitial();
}

// Loading state (e.g., when applying promo code)
class CartLoading extends CartState {
  const CartLoading();
}

// Cart loaded with items
class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

// Cart is empty
class CartEmpty extends CartState {
  const CartEmpty();
}

// Error state
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
