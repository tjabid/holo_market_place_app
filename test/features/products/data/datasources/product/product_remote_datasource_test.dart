import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:holo_market_place_app/core/constants/api_constants.dart';
import 'package:holo_market_place_app/core/error/exceptions.dart';
import 'package:holo_market_place_app/core/network/api_client.dart';
import 'package:holo_market_place_app/features/products/data/datasources/product/product_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/dto/product_dto.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';

@GenerateMocks([ApiClient])
import 'product_remote_datasource_test.mocks.dart';

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProductRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('ProductRemoteDataSourceImpl', () {
    group('getProducts', () {
      final testProductsJson = [
        {
          'id': 1,
          'title': 'Test Product 1',
          'price': 29.99,
          'description': 'Test description 1',
          'category': 'electronics',
          'image': 'https://example.com/image1.jpg',
          'rating': {
            'rate': 4.5,
            'count': 100,
          },
        },
        {
          'id': 2,
          'title': 'Test Product 2',
          'price': 49.99,
          'description': 'Test description 2',
          'category': 'clothing',
          'image': 'https://example.com/image2.jpg',
          'rating': {
            'rate': 3.8,
            'count': 50,
          },
        },
      ];

      test('should return list of ProductDto when API call is successful', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => testProductsJson);

        // Act
        final result = await dataSource.getProducts();

        // Assert
        expect(result, isA<List<ProductDto>>());
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[0].title, 'Test Product 1');
        expect(result[0].price, 29.99);
        expect(result[0].category, 'electronics');
        expect(result[1].id, 2);
        expect(result[1].title, 'Test Product 2');
        expect(result[1].price, 49.99);
        verify(mockApiClient.get(ApiConstants.products)).called(1);
        verifyNoMoreInteractions(mockApiClient);
      });

      test('should return empty list when API returns empty array', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getProducts();

        // Assert
        expect(result, isA<List<ProductDto>>());
        expect(result, isEmpty);
        verify(mockApiClient.get(ApiConstants.products)).called(1);
      });

      test('should throw ServerException when API call fails', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => dataSource.getProducts(),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to fetch products'),
          )),
        );
        verify(mockApiClient.get(ApiConstants.products)).called(1);
      });

      test('should throw ServerException when API returns invalid JSON', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => dataSource.getProducts(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException when ProductDto.fromJson fails', () async {
        // Arrange
        final invalidProductJson = [
          {
            'id': 'invalid_id', // Should be int, not string
            'title': 'Test Product',
            // Missing required fields
          }
        ];
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => invalidProductJson);

        // Act & Assert
        expect(
          () => dataSource.getProducts(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should handle large number of products', () async {
        // Arrange
        final largeProductList = List.generate(1000, (index) => {
          'id': index + 1,
          'title': 'Product ${index + 1}',
          'price': (index + 1) * 10.0,
          'description': 'Description ${index + 1}',
          'category': 'category${index % 5}',
          'image': 'https://example.com/image${index + 1}.jpg',
          'rating': {
            'rate': 4.0 + (index % 10) / 10,
            'count': 10 + index,
          },
        });
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => largeProductList);

        // Act
        final result = await dataSource.getProducts();

        // Assert
        expect(result.length, 1000);
        expect(result.first.id, 1);
        expect(result.last.id, 1000);
      });
    });

    group('getProductById', () {
      const testProductId = 1;
      final testProductJson = {
        'id': testProductId,
        'title': 'Specific Test Product',
        'price': 99.99,
        'description': 'Specific test description',
        'category': 'specific',
        'image': 'https://example.com/specific.jpg',
        'rating': {
          'rate': 4.8,
          'count': 200,
        },
      };

      test('should return ProductDto when API call is successful', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.products}/$testProductId'))
            .thenAnswer((_) async => testProductJson);

        // Act
        final result = await dataSource.getProductById(testProductId);

        // Assert
        expect(result, isA<ProductDto>());
        expect(result.id, testProductId);
        expect(result.title, 'Specific Test Product');
        expect(result.price, 99.99);
        expect(result.rating, 4.8);
        expect(result.ratingCount, 200);
        verify(mockApiClient.get('${ApiConstants.products}/$testProductId')).called(1);
        verifyNoMoreInteractions(mockApiClient);
      });

      test('should throw ServerException when API call fails', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.products}/$testProductId'))
            .thenThrow(Exception('Product not found'));

        // Act & Assert
        expect(
          () => dataSource.getProductById(testProductId),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to fetch product'),
          )),
        );
        verify(mockApiClient.get('${ApiConstants.products}/$testProductId')).called(1);
      });

      test('should handle product with id 0', () async {
        // Arrange
        const productId = 0;
        final productJson = {
          'id': productId,
          'title': 'Zero ID Product',
          'price': 0.0,
          'description': 'Zero price product',
          'category': 'free',
          'image': 'https://example.com/free.jpg',
          'rating': {
            'rate': 5.0,
            'count': 1,
          },
        };
        when(mockApiClient.get('${ApiConstants.products}/$productId'))
            .thenAnswer((_) async => productJson);

        // Act
        final result = await dataSource.getProductById(productId);

        // Assert
        expect(result.id, 0);
        expect(result.price, 0.0);
      });

      test('should handle large product ID', () async {
        // Arrange
        const largeId = 999999999;
        final productJson = {
          'id': largeId,
          'title': 'Large ID Product',
          'price': 1000000.99,
          'description': 'Expensive product',
          'category': 'luxury',
          'image': 'https://example.com/luxury.jpg',
          'rating': {
            'rate': 5.0,
            'count': 1,
          },
        };
        when(mockApiClient.get('${ApiConstants.products}/$largeId'))
            .thenAnswer((_) async => productJson);

        // Act
        final result = await dataSource.getProductById(largeId);

        // Assert
        expect(result.id, largeId);
        expect(result.price, 1000000.99);
      });

      test('should throw ServerException when product JSON is invalid', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.products}/$testProductId'))
            .thenAnswer((_) async => {'invalid': 'data'});

        // Act & Assert
        expect(
          () => dataSource.getProductById(testProductId),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getProductsByCategory', () {
      const testCategory = 'electronics';
      final testCategoryProductsJson = [
        {
          'id': 1,
          'title': 'Electronics Product 1',
          'price': 199.99,
          'description': 'Electronic device 1',
          'category': testCategory,
          'image': 'https://example.com/electronics1.jpg',
          'rating': {
            'rate': 4.3,
            'count': 150,
          },
        },
        {
          'id': 2,
          'title': 'Electronics Product 2',
          'price': 299.99,
          'description': 'Electronic device 2',
          'category': testCategory,
          'image': 'https://example.com/electronics2.jpg',
          'rating': {
            'rate': 4.7,
            'count': 80,
          },
        },
      ];

      test('should return list of ProductDto for specific category when API call is successful', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory'))
            .thenAnswer((_) async => testCategoryProductsJson);

        // Act
        final result = await dataSource.getProductsByCategory(testCategory);

        // Assert
        expect(result, isA<List<ProductDto>>());
        expect(result.length, 2);
        expect(result[0].category, testCategory);
        expect(result[1].category, testCategory);
        expect(result[0].title, 'Electronics Product 1');
        expect(result[1].title, 'Electronics Product 2');
        verify(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory')).called(1);
        verifyNoMoreInteractions(mockApiClient);
      });

      test('should return empty list when category has no products', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory'))
            .thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getProductsByCategory(testCategory);

        // Assert
        expect(result, isA<List<ProductDto>>());
        expect(result, isEmpty);
        verify(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory')).called(1);
      });

      test('should throw ServerException when API call fails', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory'))
            .thenThrow(Exception('Category not found'));

        // Act & Assert
        expect(
          () => dataSource.getProductsByCategory(testCategory),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to fetch products by category'),
          )),
        );
        verify(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory')).called(1);
      });

      test('should handle category with special characters', () async {
        // Arrange
        const specialCategory = "men's clothing";
        final specialCategoryJson = [
          {
            'id': 1,
            'title': "Men's Shirt",
            'price': 59.99,
            'description': 'Nice shirt for men',
            'category': specialCategory,
            'image': 'https://example.com/shirt.jpg',
            'rating': {
              'rate': 4.0,
              'count': 30,
            },
          }
        ];
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$specialCategory'))
            .thenAnswer((_) async => specialCategoryJson);

        // Act
        final result = await dataSource.getProductsByCategory(specialCategory);

        // Assert
        expect(result.length, 1);
        expect(result[0].category, specialCategory);
        expect(result[0].title, "Men's Shirt");
      });

      test('should handle empty category string', () async {
        // Arrange
        const emptyCategory = '';
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$emptyCategory'))
            .thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getProductsByCategory(emptyCategory);

        // Assert
        expect(result, isEmpty);
        verify(mockApiClient.get('${ApiConstants.productsByCategory}/$emptyCategory')).called(1);
      });

      test('should throw ServerException when response is not a list', () async {
        // Arrange
        when(mockApiClient.get('${ApiConstants.productsByCategory}/$testCategory'))
            .thenAnswer((_) async => {'error': 'Invalid response format'});

        // Act & Assert
        expect(
          () => dataSource.getProductsByCategory(testCategory),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getCategories', () {
      final testCategoriesJson = [
        'electronics',
        'jewelery',
        "men's clothing",
        "women's clothing",
      ];

      test('should return list of Category with "all" added when API call is successful', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => testCategoriesJson);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result, isA<List<Category>>());
        expect(result.length, 5); // 4 original + 1 "all"
        
        // Check that "all" is first (reversed order)
        expect(result.first.displayName, 'All');
        expect(result.first.id, 'all');
        expect(result.first.isSelected, false);
        
        // Check other categories are present
        final categoryIds = result.map((c) => c.id).toList();
        expect(categoryIds, contains('electronics'));
        expect(categoryIds, contains('jewelery'));
        expect(categoryIds, contains("men's clothing"));
        expect(categoryIds, contains("women's clothing"));
        expect(categoryIds, contains('all'));
        
        verify(mockApiClient.get(ApiConstants.categories)).called(1);
        verifyNoMoreInteractions(mockApiClient);
      });

      test('should return only "all" category when API returns empty list', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'all');
        expect(result.first.displayName, 'All');
        verify(mockApiClient.get(ApiConstants.categories)).called(1);
      });

      test('should throw ServerException when API call fails', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenThrow(Exception('Categories service unavailable'));

        // Act & Assert
        expect(
          () => dataSource.getCategories(),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to fetch categories'),
          )),
        );
        verify(mockApiClient.get(ApiConstants.categories)).called(1);
      });

      test('should handle single category', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => ['electronics']);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result.length, 2); // 1 original + 1 "all"
        expect(result.map((c) => c.id), containsAll(['all', 'electronics']));
      });

      test('should handle categories with special characters and spaces', () async {
        // Arrange
        final specialCategories = [
          "men's clothing",
          "women's clothing",
          'books & media',
          'home & garden',
        ];
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => specialCategories);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result.length, 5); // 4 + "all"
        final categoryIds = result.map((c) => c.id).toList();
        expect(categoryIds, contains("men's clothing"));
        expect(categoryIds, contains("women's clothing"));
        expect(categoryIds, contains('books & media'));
        expect(categoryIds, contains('home & garden'));
        expect(categoryIds, contains('all'));
      });

      test('should throw ServerException when response is not a list', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => {'categories': ['electronics']});

        // Act & Assert
        expect(
          () => dataSource.getCategories(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should handle null values in categories list gracefully', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => ['electronics', null, 'clothing']);

        // Act & Assert
        expect(
          () => dataSource.getCategories(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should verify categories are in reversed order with "all" first', () async {
        // Arrange
        final orderedCategories = ['a', 'b', 'c', 'd'];
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => orderedCategories);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result.length, 5);
        // "all" should be first, then reversed order: d, c, b, a
        expect(result[0].id, 'all');
        expect(result[1].id, 'd');
        expect(result[2].id, 'c');
        expect(result[3].id, 'b');
        expect(result[4].id, 'a');
      });
    });

    group('Constructor and dependencies', () {
      test('should create instance with required ApiClient dependency', () {
        // Act
        final instance = ProductRemoteDataSourceImpl(apiClient: mockApiClient);

        // Assert
        expect(instance, isA<ProductRemoteDataSourceImpl>());
        expect(instance, isA<ProductRemoteDataSource>());
      });
    });

    group('Integration scenarios', () {
      test('should handle multiple concurrent API calls', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenAnswer((_) async => []);
        when(mockApiClient.get(ApiConstants.categories))
            .thenAnswer((_) async => ['electronics']);
        when(mockApiClient.get('${ApiConstants.products}/1'))
            .thenAnswer((_) async => {
              'id': 1,
              'title': 'Test',
              'price': 10.0,
              'description': 'Test',
              'category': 'test',
              'image': 'test.jpg',
              'rating': {'rate': 4.0, 'count': 1},
            });

        // Act
        final futures = [
          dataSource.getProducts(),
          dataSource.getCategories(),
          dataSource.getProductById(1),
        ];
        final results = await Future.wait(futures);

        // Assert
        expect(results[0], isA<List<ProductDto>>());
        expect(results[1], isA<List<Category>>());
        expect(results[2], isA<ProductDto>());
        
        verify(mockApiClient.get(ApiConstants.products)).called(1);
        verify(mockApiClient.get(ApiConstants.categories)).called(1);
        verify(mockApiClient.get('${ApiConstants.products}/1')).called(1);
      });

      test('should handle network timeout scenarios', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.products))
            .thenThrow(Exception('Connection timeout'));

        // Act & Assert
        expect(
          () => dataSource.getProducts(),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Connection timeout'),
          )),
        );
      });
    });
  });
}