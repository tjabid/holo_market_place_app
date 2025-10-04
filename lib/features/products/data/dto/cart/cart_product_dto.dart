import 'package:holo_market_place_app/features/products/data/dto/product_dto.dart';

class CartProductDto {
  final int productId;
  final int quantity;
  final ProductDto? product;

  CartProductDto({
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartProductDto.fromJson(Map<String, dynamic> json) {
    return CartProductDto(
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      product: json['product'] != null
          ? ProductDto.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
