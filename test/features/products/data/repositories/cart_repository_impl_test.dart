import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:holo_market_place_app/core/error/exceptions.dart';
import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_local_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/product/product_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/dto/cart/cart_dto.dart';
import 'package:holo_market_place_app/features/products/data/dto/cart/cart_product_dto.dart';
import 'package:holo_market_place_app/features/products/data/dto/product_dto.dart';
import 'package:holo_market_place_app/features/products/data/repositories/cart_repository_impl.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart_item.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';

import 'cart_repository_impl_test.mocks.dart';

@GenerateMocks([CartRemoteDatasource, CartLocalDatasource, ProductRemoteDataSource])
void main() {
  late CartRepositoryImpl repository;
  late MockCartRemoteDatasource mockCartRemoteDataSource;
  late MockCartLocalDatasource mockCartLocalDataSource;
  late MockProductRemoteDataSource mockProductRemoteDataSource;

  setUp(() {
    mockCartRemoteDataSource = MockCartRemoteDatasource();
    mockCartLocalDataSource = MockCartLocalDatasource();
    mockProductRemoteDataSource = MockProductRemoteDataSource();
    repository = CartRepositoryImpl(
      cartRemoteDatasource: mockCartRemoteDataSource,
      cartLocalDatasource: mockCartLocalDataSource,
      productRemoteDatasource: mockProductRemoteDataSource,
    );
  });

  group('CartRepositoryImpl', () {
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

    final testCartProductDto = CartProductDto(
      productId: 1,
      quantity: 2,
    );

    final testCartDto = CartDto(
      id: 1,
      userId: 1,
      date: '2024-01-01',
      products: [testCartProductDto],
      shippingCost: 5.0,
    );

    final testCartItem = CartItem(
      id: '1',
      product: testProduct,
      quantity: 2,
    );

    final testCart = Cart(
      id: 1,
      items: [testCartItem],
      shippingCost: 5.0,
    );

    group('getCart', () {
      test('should return local cart when available and products are fetched successfully', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => [testProductDto]);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => testCartDto);

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 1);
            expect(cart.items.length, 1);
            expect(cart.items.first.product.id, 1);
            expect(cart.items.first.quantity, 2);
            expect(cart.shippingCost, 5.0);
          },
        );

        verify(mockProductRemoteDataSource.getProducts()).called(1);
        verify(mockCartLocalDataSource.getCart()).called(1);
        verifyNever(mockCartRemoteDataSource.getCart());
        verifyNever(mockCartLocalDataSource.updateCart(any));
      });

      test('should fetch from remote and cache when local cart is null', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => [testProductDto]);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => null);
        when(mockCartRemoteDataSource.getCart())
            .thenAnswer((_) async => testCartDto);
        when(mockCartLocalDataSource.updateCart(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 1);
            expect(cart.items.length, 1);
            expect(cart.shippingCost, 5.0);
          },
        );

        verify(mockProductRemoteDataSource.getProducts()).called(1);
        verify(mockCartLocalDataSource.getCart()).called(1);
        verify(mockCartRemoteDataSource.getCart()).called(1);
        verify(mockCartLocalDataSource.updateCart(testCartDto)).called(1);
      });

      test('should return empty cart when no products are available', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => []);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => testCartDto);

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 1);
            expect(cart.items.length, 1);
            // Product should be empty when not found in products list
            expect(cart.items.first.product.id, 0); // Product.empty().id
            expect(cart.items.first.quantity, 2);
          },
        );
      });

      test('should return ServerFailure when product remote datasource throws ServerException', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenThrow(const ServerException('Product server error'));

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Product server error');
          },
          (cart) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when product remote datasource throws NetworkException', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenThrow(const NetworkException('Network error'));

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'Network error');
          },
          (cart) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when cart remote datasource throws ServerException', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => [testProductDto]);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => null);
        when(mockCartRemoteDataSource.getCart())
            .thenThrow(const ServerException('Cart server error'));

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Cart server error');
          },
          (cart) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(mockProductRemoteDataSource.getProducts())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (cart) => fail('Expected failure but got success'),
        );
      });
    });

    group('clearCart', () {
      test('should successfully clear cart when local datasource succeeds', () async {
        // Arrange
        when(mockCartLocalDataSource.clearCart())
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.clearCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (success) {
            // Success should be void/null for clear cart
          },
        );

        verify(mockCartLocalDataSource.clearCart()).called(1);
      });

      test('should return ServerFailure when local datasource throws ServerException', () async {
        // Arrange
        when(mockCartLocalDataSource.clearCart())
            .thenThrow(const ServerException('Clear cart failed'));

        // Act
        final result = await repository.clearCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Clear cart failed');
          },
          (success) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when local datasource throws NetworkException', () async {
        // Arrange
        when(mockCartLocalDataSource.clearCart())
            .thenThrow(const NetworkException('Network error during clear'));

        // Act
        final result = await repository.clearCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'Network error during clear');
          },
          (success) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(mockCartLocalDataSource.clearCart())
            .thenThrow(Exception('Unexpected clear error'));

        // Act
        final result = await repository.clearCart();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (success) => fail('Expected failure but got success'),
        );
      });
    });

    group('updateCart', () {
      test('should successfully update cart when local datasource succeeds', () async {
        // Arrange
        when(mockCartLocalDataSource.updateCart(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.updateCart(testCart);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (success) {
            // Success should be void/null for update cart
          },
        );

        verify(mockCartLocalDataSource.updateCart(any)).called(1);
      });

      test('should return ServerFailure when local datasource throws ServerException', () async {
        // Arrange
        when(mockCartLocalDataSource.updateCart(any))
            .thenThrow(const ServerException('Update cart failed'));

        // Act
        final result = await repository.updateCart(testCart);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Update cart failed');
          },
          (success) => fail('Expected failure but got success'),
        );
      });

      test('should return NetworkFailure when local datasource throws NetworkException', () async {
        // Arrange
        when(mockCartLocalDataSource.updateCart(any))
            .thenThrow(const NetworkException('Network error during update'));

        // Act
        final result = await repository.updateCart(testCart);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'Network error during update');
          },
          (success) => fail('Expected failure but got success'),
        );
      });

      test('should return ServerFailure when unexpected exception occurs', () async {
        // Arrange
        when(mockCartLocalDataSource.updateCart(any))
            .thenThrow(Exception('Unexpected update error'));

        // Act
        final result = await repository.updateCart(testCart);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unexpected error'));
          },
          (success) => fail('Expected failure but got success'),
        );
      });
    });

    group('unimplemented methods', () {
      test('should throw UnimplementedError for applyPromoCode', () async {
        // Act & Assert
        expect(
          () => repository.applyPromoCode('TEST_CODE'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should throw UnimplementedError for getAvailablePromoCodes', () async {
        // Act & Assert
        expect(
          () => repository.getAvailablePromoCodes(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should throw UnimplementedError for removePromoCode', () async {
        // Act & Assert
        expect(
          () => repository.removePromoCode(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('edge cases', () {
      test('should handle empty cart from remote', () async {
        // Arrange
        final emptyCartDto = CartDto.empty();
        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => []);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => null);
        when(mockCartRemoteDataSource.getCart())
            .thenAnswer((_) async => emptyCartDto);
        when(mockCartLocalDataSource.updateCart(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 0);
            expect(cart.items, isEmpty);
            expect(cart.shippingCost, 0.0);
          },
        );
      });

      test('should handle cart with multiple items', () async {
        // Arrange
        const product1Dto = ProductDto(
          id: 1,
          title: 'Product 1',
          price: 10.0,
          description: 'Description 1',
          category: 'category1',
          image: 'image1.jpg',
          rating: 4.0,
          ratingCount: 50,
        );

        const product2Dto = ProductDto(
          id: 2,
          title: 'Product 2',
          price: 20.0,
          description: 'Description 2',
          category: 'category2',
          image: 'image2.jpg',
          rating: 5.0,
          ratingCount: 100,
        );

        final multiItemCartDto = CartDto(
          id: 2,
          userId: 1,
          date: '2024-01-02',
          products: [
            CartProductDto(productId: 1, quantity: 3),
            CartProductDto(productId: 2, quantity: 1),
          ],
          shippingCost: 10.0,
        );

        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => [product1Dto, product2Dto]);
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => multiItemCartDto);

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 2);
            expect(cart.items.length, 2);
            expect(cart.items.first.quantity, 3);
            expect(cart.items.last.quantity, 1);
            expect(cart.shippingCost, 10.0);
          },
        );
      });

      test('should handle cart with unknown product IDs', () async {
        // Arrange
        final cartWithUnknownProduct = CartDto(
          id: 3,
          userId: 1,
          date: '2024-01-03',
          products: [
            CartProductDto(productId: 999, quantity: 1), // Unknown product
          ],
          shippingCost: 0.0,
        );

        when(mockProductRemoteDataSource.getProducts())
            .thenAnswer((_) async => [testProductDto]); // Only product ID 1
        when(mockCartLocalDataSource.getCart())
            .thenAnswer((_) async => cartWithUnknownProduct);

        // Act
        final result = await repository.getCart();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (cart) {
            expect(cart.id, 3);
            expect(cart.items.length, 1);
            // Should use Product.empty() for unknown product
            expect(cart.items.first.product.id, 0);
            expect(cart.items.first.product.title, '');
            expect(cart.items.first.quantity, 1);
          },
        );
      });
    });
  });
}