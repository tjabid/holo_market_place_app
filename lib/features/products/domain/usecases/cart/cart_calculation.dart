import '../../entities/cart/cart.dart';

class CartCalculationUseCase {

  int getItemCount(Cart cart) {
    return cart.itemCount;
  }

  double getCartSubtotal(Cart cart) {
    return cart.items.fold(0.0, (total, item) {
      return total + (item.product.price * item.quantity);
    });
  }

  double getCartTotal(Cart cart) {
    return cart.total;
  }

  double getShippingCost(Cart cart) {
    return cart.shippingCost;
  }

  double calculateTotalWithShipping(Cart cart) {
    final subtotal = getCartSubtotal(cart);
    final shipping = getShippingCost(cart);

    return (subtotal + shipping).clamp(0.0, double.infinity);
  }

  bool isCartEmpty(Cart cart) {
    return cart.items.isEmpty;
  }

  int getTotalQuantity(Cart cart) {
    return cart.items.fold(0, (total, item) => total + item.quantity);
  }
}
