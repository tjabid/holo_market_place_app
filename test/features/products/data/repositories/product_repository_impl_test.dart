import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:holo_market_place_app/core/error/exceptions.dart';
import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/data/datasources/product/product_local_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/product/product_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/dto/product_dto.dart';
import 'package:holo_market_place_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';
import 'package:flutter/material.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([ProductRemoteDataSource, ProductLocalDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('ProductRepositoryImpl', () {
    // Test data
    const testProductDto = ProductDto(
      id: 1,
      title: 'Test Product',
      price: 99.99,
      description: 'Test description',
      category: 'electronics',
      image: 'https://example.com/image.jpg',
      rating: 4.5,
      ratingCount: 100,
    );

    const testProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 99.99,
      description: 'Test description',
      category: 'electronics',
      image: 'https://example.com/image.jpg',
      rating: 4.5,
      ratingCount: 100,
    );

    const testCategory = Category(
      id: 'electronics',
      displayName: 'Electronics',
      icon: Icons.devices,
    );

    group('getProducts', () {
      test('should return cached products when cache is not empty', () async {
        // Arrange
        final cachedProducts = [testProduct];
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => cachedProducts);

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result, equals(Right(cachedProducts)));
        verify(mockLocalDataSource.getCachedProducts()).called(1);
        verifyNever(mockRemoteDataSource.getProducts());
        verifyNever(mockLocalDataSource.cacheProducts(any));
      });

      test('should fetch from remote and cache when local cache is empty', () async {
        // Arrange
        final remoteProducts = [testProductDto];
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenAnswer((_) async => remoteProducts);
        when(mockLocalDataSource.cacheProducts(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (products) {
            expect(products.length, 1);
            expect(products.first.id, testProduct.id);
            expect(products.first.title, testProduct.title);
          },
        );

        verify(mockLocalDataSource.getCachedProducts()).called(1);
        verify(mockRemoteDataSource.getProducts()).called(1);
        verify(mockLocalDataSource.cacheProducts(any)).called(1);
      });

      test('should return ServerFailure when remote throws ServerException', () async {
        // Arrange
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Server error');
          },
          (products) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when remote throws NetworkException', () async {
        // Arrange
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenThrow(const NetworkException('Network error'));

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'Network error');
          },
          (products) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (products) => fail('Expected failure but got success'),
        );
      });
    });

    group('getProductById', () {
      test('should return product when remote call succeeds', () async {
        // Arrange
        when(mockRemoteDataSource.getProductById(1))
            .thenAnswer((_) async => testProductDto);

        // Act
        final result = await repository.getProductById(1);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (product) {
            expect(product.id, testProduct.id);
            expect(product.title, testProduct.title);
          },
        );

        verify(mockRemoteDataSource.getProductById(1)).called(1);
      });

      test('should return ServerFailure when remote throws ServerException', () async {
        // Arrange
        when(mockRemoteDataSource.getProductById(1))
            .thenThrow(const ServerException('Product not found'));

        // Act
        final result = await repository.getProductById(1);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Product not found');
          },
          (product) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when remote throws NetworkException', () async {
        // Arrange
        when(mockRemoteDataSource.getProductById(1))
            .thenThrow(const NetworkException('No internet connection'));

        // Act
        final result = await repository.getProductById(1);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'No internet connection');
          },
          (product) => fail('Expected failure but got success'),
        );
      });

      test('should return Unexpected Error when remote throws Exception', () async {
        // Arrange
        when(mockRemoteDataSource.getProductById(1))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getProductById(1);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (product) => fail('Expected failure but got success'),
        );
      });
    });

    group('getProductsByCategory', () {
      test('should return cached products when local cache has data', () async {
        // Arrange
        final cachedProducts = [testProduct];
        when(mockLocalDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => cachedProducts);

        // Act
        final result = await repository.getProductsByCategory('electronics');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (products) {
            expect(products, equals(cachedProducts));
          },
        );

        verify(mockLocalDataSource.getProductsByCategory('electronics')).called(1);
        verifyNever(mockRemoteDataSource.getProductsByCategory(any));
      });

      test('should fetch from remote when local cache is empty', () async {
        // Arrange
        final remoteProducts = [testProductDto];
        when(mockLocalDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => remoteProducts);

        // Act
        final result = await repository.getProductsByCategory('electronics');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (products) {
            expect(products.length, 1);
            expect(products.first.category, 'electronics');
          },
        );

        verify(mockLocalDataSource.getProductsByCategory('electronics')).called(1);
        verify(mockRemoteDataSource.getProductsByCategory('electronics')).called(1);
      });

      test('should return ServerFailure when remote throws ServerException', () async {
        // Arrange
        when(mockLocalDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProductsByCategory('electronics'))
            .thenThrow(const ServerException('Category not found'));

        // Act
        final result = await repository.getProductsByCategory('electronics');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Category not found');
          },
          (products) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when remote throws ServerException', () async {
        // Arrange
        when(mockLocalDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProductsByCategory('electronics'))
            .thenThrow(const NetworkException('No internet connection'));

        // Act
        final result = await repository.getProductsByCategory('electronics');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'No internet connection');
          },
          (products) => fail('Expected failure but got success'),
        );
      });

      test('should return Unexpected Error when remote throws Exception', () async {
        // Arrange
        final exception = Exception('Unexpected error');
        when(mockLocalDataSource.getProductsByCategory('electronics'))
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProductsByCategory('electronics'))
            .thenThrow(exception);

        // Act
        final result = await repository.getProductsByCategory('electronics');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Unexpected error: $exception');
          },
          (products) => fail('Expected failure but got success'),
        );
      });
    });

    group('getCategories', () {
      test('should return cached categories when cache is not empty', () async {
        // Arrange
        final cachedCategories = [testCategory];
        when(mockLocalDataSource.getCachedCategories())
            .thenAnswer((_) async => cachedCategories);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (categories) {
            expect(categories, equals(cachedCategories));
          },
        );

        verify(mockLocalDataSource.getCachedCategories()).called(1);
        verifyNever(mockRemoteDataSource.getCategories());
        verifyNever(mockLocalDataSource.cacheCategories(any));
      });

      test('should fetch from remote and cache when local cache is empty', () async {
        // Arrange
        final remoteCategories = [testCategory];
        when(mockLocalDataSource.getCachedCategories())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCategories())
            .thenAnswer((_) async => remoteCategories);
        when(mockLocalDataSource.cacheCategories(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (categories) {
            expect(categories, equals(remoteCategories));
          },
        );

        verify(mockLocalDataSource.getCachedCategories()).called(1);
        verify(mockRemoteDataSource.getCategories()).called(1);
        verify(mockLocalDataSource.cacheCategories(remoteCategories)).called(1);
      });

      test('should return ServerFailure when remote throws ServerException', () async {
        // Arrange
        when(mockLocalDataSource.getCachedCategories())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCategories())
            .thenThrow(const ServerException('Categories unavailable'));

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Categories unavailable');
          },
          (categories) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when remote throws NetworkException', () async {
        // Arrange
        when(mockLocalDataSource.getCachedCategories())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCategories())
            .thenThrow(const NetworkException('Connection timeout'));

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'Connection timeout');
          },
          (categories) => fail('Expected failure but got success'),
        );
      });

      test('should return Unexpected error when remote throws ServerFailure', () async {
        // Arrange
        final exception = Exception('Unexpected error');
        when(mockLocalDataSource.getCachedCategories())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getCategories())
            .thenThrow(exception);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Unexpected error: $exception');
          },
          (categories) => fail('Expected failure but got success'),
        );
      });
    });

    group('edge cases', () {
      test('should handle empty product lists correctly', () async {
        // Arrange
        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenAnswer((_) async => []);
        when(mockLocalDataSource.cacheProducts(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (products) {
            expect(products, isEmpty);
          },
        );
      });

      test('should handle large product lists correctly', () async {
        // Arrange
        final largeProductList = List.generate(1000, (index) => ProductDto(
          id: index,
          title: 'Product $index',
          price: 10.0 + index,
          description: 'Description $index',
          category: 'category${index % 5}',
          image: 'https://example.com/image$index.jpg',
          rating: 1.0 + (index % 5),
          ratingCount: index * 10,
        ));

        when(mockLocalDataSource.getCachedProducts())
            .thenAnswer((_) async => []);
        when(mockRemoteDataSource.getProducts())
            .thenAnswer((_) async => largeProductList);
        when(mockLocalDataSource.cacheProducts(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (products) {
            expect(products.length, 1000);
            expect(products.first.id, 0);
            expect(products.last.id, 999);
          },
        );
      });
    });
  });
}