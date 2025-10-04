import 'dart:convert';
import '../../../domain/entities/product.dart';
import '../../dto/cart_dto.dart';

abstract class CartLocalDatasource {
  Future<CartDto?> getCart();
  Future<void> saveCart(CartDto cart);
  Future<void> addToCart(Product product, int quantity);
  Future<void> removeFromCart(Product product);
  Future<void> updateQuantity(Product product, int quantity);
  Future<void> clearCart();
}
