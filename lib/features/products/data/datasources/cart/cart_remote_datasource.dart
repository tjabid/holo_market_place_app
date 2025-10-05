import 'package:holo_market_place_app/core/error/exceptions.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../dto/cart/cart_dto.dart';

abstract class CartRemoteDatasource {
  Future<CartDto> getCart();

  Future<void> addToCart(Product product, int quantity);
  Future<void> removeFromCart(Product product);
  Future<void> updateQuantity(Product product, int quantity);
  Future<void> clearCart();
}

class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  final ApiClient apiClient;

  CartRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<CartDto> getCart() async {
    try {
      final response = await apiClient.get('${ApiConstants.carts}/1');
      if (response == null) {
        return CartDto.empty();
      }
      return CartDto.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch cart: $e');
    }
  }

  @override
  Future<void> addToCart(Product product, int quantity) async {
    try {
      final paramMap = Map<String, dynamic>.from({
        'productId': product.id,
        'quantity': quantity,
      });
      await apiClient.post(ApiConstants.carts, paramMap);
    } catch (e) {
      throw ServerException('Failed to add item to cart: $e');
    }
  }

  @override
  Future<void> removeFromCart(Product product) async {
    try {
      await apiClient.delete('${ApiConstants.carts}/${product.id}');
    } catch (e) {
      throw ServerException('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> updateQuantity(Product product, int quantity) async {
    try {
      final paramMap = Map<String, dynamic>.from({
        'productId': product.id,
        'quantity': quantity,
      });
      await apiClient.put('${ApiConstants.carts}/${product.id}', paramMap);
    } catch (e) {
      throw ServerException('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await apiClient.delete(ApiConstants.carts);
    } catch (e) {
      throw ServerException('Failed to clear cart: $e');
    }
  }
}
