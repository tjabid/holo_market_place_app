import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/product_repository.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/product/get_products.dart';

@GenerateMocks([ProductRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  final testProducts = [
    const Product(
      id: 1,
      title: 'Zebra Product',
      price: 100.0,
      description: 'Description 1',
      category: 'Category 1',
      image: 'image1.png',
      rating: 4.5,
      ratingCount: 100,
    ),
    const Product(
      id: 2,
      title: 'Alpha Product',
      price: 50.0,
      description: 'Description 2',
      category: 'Category 2',
      image: 'image2.png',
      rating: 3.5,
      ratingCount: 50,
    ),
    const Product(
      id: 3,
      title: 'Beta Product',
      price: 150.0,
      description: 'Description 3',
      category: 'Category 3',
      image: 'image3.png',
      rating: 5.0,
      ratingCount: 200,
    ),
    const Product(
      id: 4,
      title: 'Gamma Product',
      price: 75.0,
      description: 'Description 4',
      category: 'Category 4',
      image: 'image4.png',
      rating: 4.0,
      ratingCount: 80,
    ),
  ];

  group('GetProductsUseCase', () {
    group('Basic functionality', () {
      test('should return products from repository when no parameters', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(testProducts));
        verify(mockRepository.getProducts()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when repository returns empty list', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => const Right(<Product>[]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(<Product>[]));
        verify(mockRepository.getProducts()).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const tFailure = ServerFailure('Server error');
        when(mockRepository.getProducts())
            .thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(tFailure));
        verify(mockRepository.getProducts()).called(1);
      });
    });

    group('Limit functionality', () {
      test('should return limited products when limit parameter is provided', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 2);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 2);
            expect(products, testProducts.take(2).toList());
          },
        );
      });

      test('should return all products when limit is greater than available products', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 10);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, testProducts.length);
            expect(products, testProducts);
          },
        );
      });

      test('should return all products when limit is 0 (no filtering)', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 0);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            // Based on implementation: limit=0 means no filtering (returns all)
            expect(products.length, testProducts.length);
            expect(products, testProducts);
          },
        );
      });

      test('should return all products when limit is negative', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: -1);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, testProducts.length);
            expect(products, testProducts);
          },
        );
      });

      test('should return single product when limit is 1', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 1);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 1);
            expect(products.first, testProducts.first);
          },
        );
      });
    });

    group('Sorting functionality', () {
      test('should return sorted products by price ascending', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'price_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].price, 50.0);  // Alpha Product
            expect(products[1].price, 75.0);  // Gamma Product
            expect(products[2].price, 100.0); // Zebra Product
            expect(products[3].price, 150.0); // Beta Product
          },
        );
      });

      test('should return sorted products by price descending', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'price_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].price, 150.0); // Beta Product
            expect(products[1].price, 100.0); // Zebra Product
            expect(products[2].price, 75.0);  // Gamma Product
            expect(products[3].price, 50.0);  // Alpha Product
          },
        );
      });

      test('should return sorted products by rating descending (default)', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'rating');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].rating, 5.0);  // Beta Product
            expect(products[1].rating, 4.5);  // Zebra Product
            expect(products[2].rating, 4.0);  // Gamma Product
            expect(products[3].rating, 3.5);  // Alpha Product
          },
        );
      });

      test('should return sorted products by rating descending explicitly', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'rating_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].rating, 5.0);  // Beta Product
            expect(products[1].rating, 4.5);  // Zebra Product
            expect(products[2].rating, 4.0);  // Gamma Product
            expect(products[3].rating, 3.5);  // Alpha Product
          },
        );
      });

      test('should return sorted products by rating ascending', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'rating_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].rating, 3.5);  // Alpha Product
            expect(products[1].rating, 4.0);  // Gamma Product
            expect(products[2].rating, 4.5);  // Zebra Product
            expect(products[3].rating, 5.0);  // Beta Product
          },
        );
      });

      test('should return sorted products by name ascending (default)', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'name');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].title, 'Alpha Product');
            expect(products[1].title, 'Beta Product');
            expect(products[2].title, 'Gamma Product');
            expect(products[3].title, 'Zebra Product');
          },
        );
      });

      test('should return sorted products by name ascending explicitly', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'name_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].title, 'Alpha Product');
            expect(products[1].title, 'Beta Product');
            expect(products[2].title, 'Gamma Product');
            expect(products[3].title, 'Zebra Product');
          },
        );
      });

      test('should return sorted products by name descending', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'name_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].title, 'Zebra Product');
            expect(products[1].title, 'Gamma Product');
            expect(products[2].title, 'Beta Product');
            expect(products[3].title, 'Alpha Product');
          },
        );
      });

      test('should return unsorted products for unknown sort type', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'unknown_sort');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products, testProducts); // Should be in original order
          },
        );
      });

      test('should handle case insensitive sorting', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: 'PRICE_ASC');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products[0].price, 50.0);  // Should work with uppercase
            expect(products[1].price, 75.0);
            expect(products[2].price, 100.0);
            expect(products[3].price, 150.0);
          },
        );
      });

      test('should handle empty string sort type', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(sortBy: '');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products, testProducts); // Should be in original order
          },
        );
      });
    });

    group('Combined functionality', () {
      test('should apply both limit and sorting', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 2, sortBy: 'price_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 2);
            expect(products[0].price, 150.0); // Highest price first
            expect(products[1].price, 100.0); // Second highest
          },
        );
      });

      test('should apply sorting then limit (order matters)', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 2, sortBy: 'rating_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 2);
            expect(products[0].rating, 5.0);  // Highest rating first
            expect(products[1].rating, 4.5);  // Second highest rating
          },
        );
      });

      test('should handle limit with sorting on empty repository result', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => const Right(<Product>[]));

        // Act
        final result = await useCase(limit: 5, sortBy: 'price_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return empty list'),
          (products) {
            expect(products, isEmpty);
          },
        );
      });

      test('should handle repository failure with parameters', () async {
        // Arrange
        const tFailure = NetworkFailure('Network error');
        when(mockRepository.getProducts())
            .thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(limit: 5, sortBy: 'price_asc');

        // Assert
        expect(result, const Left(tFailure));
        verify(mockRepository.getProducts()).called(1);
      });
    });

    group('Edge cases', () {
      test('should handle single product sorting', () async {
        // Arrange
        final singleProduct = [testProducts.first];
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(singleProduct));

        // Act
        final result = await useCase(sortBy: 'price_desc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 1);
            expect(products.first, testProducts.first);
          },
        );
      });

      test('should handle products with identical values for sorting', () async {
        // Arrange
        final identicalPriceProducts = [
          const Product(
            id: 1, title: 'Product A', price: 100.0, description: 'Desc', 
            category: 'Cat', image: 'img', rating: 4.0, ratingCount: 10,
          ),
          const Product(
            id: 2, title: 'Product B', price: 100.0, description: 'Desc', 
            category: 'Cat', image: 'img', rating: 4.0, ratingCount: 10,
          ),
        ];
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(identicalPriceProducts));

        // Act
        final result = await useCase(sortBy: 'price_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 2);
            expect(products[0].price, 100.0);
            expect(products[1].price, 100.0);
            // Order should be preserved for identical values
          },
        );
      });

      test('should handle very large limit', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(limit: 1000000);

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, testProducts.length);
            expect(products, testProducts);
          },
        );
      });

      test('should handle products with extreme values', () async {
        // Arrange
        final extremeProducts = [
          const Product(
            id: 1, title: '', price: 0.0, description: '', 
            category: '', image: '', rating: 0.0, ratingCount: 0,
          ),
          Product(
            id: 2, title: 'Z' * 100, price: 999999.99, description: 'Desc', 
            category: 'Cat', image: 'img', rating: 5.0, ratingCount: 999999,
          ),
        ];
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(extremeProducts));

        // Act
        final result = await useCase(sortBy: 'price_asc');

        // Assert
        result.fold(
          (failure) => fail('Should return products'),
          (products) {
            expect(products.length, 2);
            expect(products[0].price, 0.0);
            expect(products[1].price, 999999.99);
          },
        );
      });
    });

    group('Performance considerations', () {
      test('should not mutate original product list when sorting', () async {
        // Arrange
        final originalProducts = List<Product>.from(testProducts);
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        await useCase(sortBy: 'price_desc');

        // Assert
        expect(testProducts, originalProducts); // Original list should be unchanged
      });

      test('should handle repeated calls efficiently', () async {
        // Arrange
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Right(testProducts));

        // Act
        await useCase(sortBy: 'price_asc');
        await useCase(sortBy: 'rating_desc');
        await useCase(limit: 2);

        // Assert
        verify(mockRepository.getProducts()).called(3);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
