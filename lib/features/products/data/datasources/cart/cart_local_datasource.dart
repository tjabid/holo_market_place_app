import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/cart/cart_dto.dart';

abstract class CartLocalDatasource {
  Future<CartDto?> getCart();
  Future<void> updateCart(CartDto cart);
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
  Future<void> updateCart(CartDto cart) async {
    await sharedPreferences.setString(_cartKey, json.encode(cart.toJson()));
  }
  
  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(_cartKey);
  }
}