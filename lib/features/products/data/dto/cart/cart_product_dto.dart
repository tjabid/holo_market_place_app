class CartProductDto {
  final int productId;
  final int quantity;
  final String? selectedSize;

  CartProductDto({
    required this.productId,
    required this.quantity,
    this.selectedSize,
  });

  factory CartProductDto.fromJson(Map<String, dynamic> json) {
    return CartProductDto(
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      selectedSize: json['selectedSize'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }
}
