import '../../domain/entities/product.dart';

class ProductDto extends Product {
  const ProductDto({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.image,
    required super.rating,
    required super.ratingCount,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: (json['rating']['rate'] as num).toDouble(),
      ratingCount: json['rating']['count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
        'rating': {
          'rate': rating,
          'count': ratingCount,
        },
      };

  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: rating,
      ratingCount: ratingCount,
    );
  }
}
