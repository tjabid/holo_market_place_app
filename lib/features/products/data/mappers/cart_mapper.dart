import 'package:holo_market_place_app/features/products/data/dto/cart/cart_product_dto.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart_item.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product.dart';

import '../../domain/entities/cart/cart.dart';
import '../dto/cart/cart_dto.dart';

Cart mapCartDtoToEntity(CartDto dto, List<Product> products) {
  final productMap = {for (var p in products) p.id: p};
  return Cart(
    id: dto.id,
    items: dto.products
        .map((itemDto) => mapCartItemDtoToEntity(
              itemDto,
              productMap[itemDto.productId] ?? Product.empty(),
            ))
        .toList(),
    shippingCost: dto.shippingCost,
  );
}

CartItem mapCartItemDtoToEntity(CartProductDto dto, Product product) {
  return CartItem(
    id: dto.productId.toString(),
    product: product,
    quantity: dto.quantity,
  );
}
