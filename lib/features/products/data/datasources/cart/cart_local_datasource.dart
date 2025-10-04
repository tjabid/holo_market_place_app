import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/product.dart';
import '../../dto/cart/cart_dto.dart';

abstract class CartLocalDatasource {
  Future<CartDto?> getCart();
  Future<void> saveCart(CartDto cart);
  Future<void> addToCart(Product product, int quantity);
  Future<void> removeFromCart(Product product);
  Future<void> updateQuantity(Product product, int quantity);
  Future<void> clearCart();
}

class CartLocalDatasourceImpl implements CartLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _cartKey = 'CART_DATA';

  CartLocalDatasourceImpl({required this.sharedPreferences});
  
  @override
  Future<CartDto?> getCart() async {
    final cartJson = sharedPreferences.getString(_cartKey);
    if (cartJson == null) return null;
    return CartDto.fromJson(json.decode(cartJson));
  }

  @override
  Future<void> saveCart(CartDto cart) async {
    await sharedPreferences.setString(_cartKey, json.encode(cart.toJson()));
  }

  @override
  Future<void> addToCart(Product product, int quantity) async {
    throw UnimplementedError('Use saveCart() instead');
  }

  @override
  Future<void> removeFromCart(Product product) async {
    throw UnimplementedError('Use saveCart() instead');
  }

  @override
  Future<void> updateQuantity(Product product, int quantity) async {
    throw UnimplementedError('Use saveCart() instead');
  }

  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(_cartKey);
  }
}