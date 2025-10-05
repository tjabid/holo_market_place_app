import 'package:equatable/equatable.dart';
import '../product/product.dart';

class CartItem extends Equatable {
  final String id; // Unique cart item ID
  final Product product;
  final int quantity;
  final String? selectedSize; // Optional size variant (e.g., "S", "M", "L")

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
  });

  // Calculate subtotal for this cart item
  double get subtotal => product.price * quantity;

  // Create a copy with updated values
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, selectedSize];
}
