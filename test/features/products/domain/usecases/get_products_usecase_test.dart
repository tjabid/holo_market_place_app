import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:holo_market_place_app/features/products/domain/entities/product.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/product_repository.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/get_products.dart';

@GenerateMocks([ProductRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  final tProducts = [
    const Product(
      id: 1,
      title: 'Product 1',
      price: 100.0,
      description: 'Description 1',
      category: 'Category 1',
      image: 'image1.png',
      rating: 4.5,
      ratingCount: 100,
    ),
    const Product(
      id: 2,
      title: 'Product 2',
      price: 50.0,
      description: 'Description 2',
      category: 'Category 2',
      image: 'image2.png',
      rating: 3.5,
      ratingCount: 50,
    ),
    const Product(
      id: 3,
      title: 'Product 3',
      price: 150.0,
      description: 'Description 3',
      category: 'Category 3',
      image: 'image3.png',
      rating: 5.0,
      ratingCount: 200,
    ),
  ];

  group('GetProductsUseCase', () {
    test('should return products from repository when no parameters', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(tProducts));
      verify(mockRepository.getProducts());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return limited products when limit parameter is provided', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase(limit: 2);

      // assert
      result.fold(
        (failure) => fail('Should return products'),
        (products) {
          expect(products.length, 2);
          expect(products, tProducts.take(2).toList());
        },
      );
    });

    test('should return sorted products by price ascending', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase(sortBy: 'price_asc');

      // assert
      result.fold(
        (failure) => fail('Should return products'),
        (products) {
          expect(products[0].price, 50.0);
          expect(products[1].price, 100.0);
          expect(products[2].price, 150.0);
        },
      );
    });

    test('should return sorted products by rating descending', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase(sortBy: 'rating');

      // assert
      result.fold(
        (failure) => fail('Should return products'),
        (products) {
          expect(products[0].rating, 5.0);
          expect(products[1].rating, 4.5);
          expect(products[2].rating, 3.5);
        },
      );
    });

    test('should apply both limit and sorting', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase(limit: 2, sortBy: 'price_desc');

      // assert
      result.fold(
        (failure) => fail('Should return products'),
        (products) {
          expect(products.length, 2);
          expect(products[0].price, 150.0);
          expect(products[1].price, 100.0);
        },
      );
    });
  });
}
