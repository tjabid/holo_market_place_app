import 'cart_product_dto.dart';

class CartDto {
  final int id;
  final int userId;
  final String date;
  final List<CartProductDto> products;
  final double shippingCost;

  CartDto({
    required this.id,
    this.userId = 1,
    this.date = "",
    required this.products,
    this.shippingCost = 0, // Default shipping cost is 0 for now
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      date: json['date'] as String,
      products: (json['products'] as List)
          .map((p) => CartProductDto.fromJson(p as Map<String, dynamic>))
          .toList(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'products': products.map((p) => p.toJson()).toList(),
      'shippingCost': shippingCost,
    };
  }

  static CartDto empty() {
    return CartDto(
      id: 0,
      userId: 0,
      date: '',
      products: [],
      shippingCost: 0,
    );
  }
}
