import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final int id;
  final List<CartItem> items;
  final double shippingCost;

  const Cart({
    this.id = 0,
    this.items = const [],
    this.shippingCost = 0, // Default shipping cost is 0 for now
  });

  // Calculate subtotal (sum of all item subtotals)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Calculate total (subtotal + shipping cost)
  double get total {
    return subtotal + shippingCost;
  }

  // Get total number of items in cart
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Create a copy with updated values
  Cart copyWith({
    List<CartItem>? items,
    double? shippingCost,
  }) {
    return Cart(
      items: items ?? this.items,
      shippingCost: shippingCost ?? this.shippingCost
    );
  }

  @override
  List<Object?> get props => [items, shippingCost];
}
