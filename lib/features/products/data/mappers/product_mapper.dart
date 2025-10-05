import '../../domain/entities/product/product.dart';
import '../dto/product_dto.dart';

Product mapProductEntity(ProductDto dto) {
    return Product(
      id: dto.id,
      title: dto.title,
      price: dto.price,
      description: dto.description,
      category: dto.category,
      image: dto.image,
      rating: dto.rating,
      ratingCount: dto.ratingCount,
    );
  }