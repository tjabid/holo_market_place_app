import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart_item.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/cart_repository.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/add_to_cart.dart';

@GenerateMocks([CartRepository])
import 'add_to_cart_usecase_test.mocks.dart';

void main() {
  late AddToCartUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = AddToCartUseCase(mockRepository);
  });

  const testProduct1 = Product(
    id: 1,
    title: 'Test Product 1',
    price: 29.99,
    description: 'Test description',
    category: 'Test Category',
    image: 'test.png',
    rating: 4.5,
    ratingCount: 100,
  );

  const testProduct2 = Product(
    id: 2,
    title: 'Test Product 2',
    price: 39.99,
    description: 'Test description 2',
    category: 'Test Category',
    image: 'test2.png',
    rating: 4.0,
    ratingCount: 50,
  );

  final testCartItem1 = CartItem(
    id: '1',
    product: testProduct1,
    quantity: 2,
    selectedSize: 'M',
  );

  const emptyCart = Cart(
    id: 1,
    items: [],
    shippingCost: 0.0,
  );

  final cartWithItem = Cart(
    id: 1,
    items: [testCartItem1],
    shippingCost: 5.0,
  );

  group('AddToCartUseCase', () {
    group('Adding new items', () {
      test('should add new product to empty cart', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
          selectedSize: 'M',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.product.id, testProduct1.id);
            expect(cart.items.first.quantity, 1);
            expect(cart.items.first.selectedSize, 'M');
          },
        );
        verify(mockRepository.updateCart(any)).called(1);
      });

      test('should add new product to cart with existing items', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithItem,
          product: testProduct2,
          selectedSize: 'L',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 2);
            expect(cart.items.any((item) => item.product.id == testProduct2.id), true);
            expect(cart.items.where((item) => item.product.id == testProduct2.id).first.quantity, 1);
            expect(cart.items.where((item) => item.product.id == testProduct2.id).first.selectedSize, 'L');
          },
        );
        verify(mockRepository.updateCart(any)).called(1);
      });

      test('should add product without size selection', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.selectedSize, null);
            expect(cart.items.first.quantity, 1);
          },
        );
      });
    });

    group('Updating existing items', () {
      test('should increment quantity when same product and size already exists', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithItem,
          product: testProduct1,
          selectedSize: 'M',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.quantity, 3); // Original 2 + 1
            expect(cart.items.first.product.id, testProduct1.id);
            expect(cart.items.first.selectedSize, 'M');
          },
        );
        verify(mockRepository.updateCart(any)).called(1);
      });

      test('should add separate item when same product but different size', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithItem,
          product: testProduct1,
          selectedSize: 'L', // Different size
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 2);
            final mSize = cart.items.where((item) => item.selectedSize == 'M').first;
            final lSize = cart.items.where((item) => item.selectedSize == 'L').first;
            expect(mSize.quantity, 2); // Original quantity
            expect(lSize.quantity, 1); // New item
          },
        );
      });
    });

    group('Error handling', () {
      test('should return CacheFailure when repository updateCart fails', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenThrow(Exception('Repository error'));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to add item to cart'));
            expect(failure.message, contains('Repository error'));
          },
          (cart) => fail('Should return failure'),
        );
      });

      test('should return failure when cart operations throw unexpected exception', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenThrow(StateError('Unexpected state error'));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
          selectedSize: 'M',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Failed to add item to cart'));
            expect(failure.message, contains('Bad state: Unexpected state error'));
          },
          (cart) => fail('Should return failure'),
        );
      });
    });

    group('Edge cases', () {
      test('should handle product with id 0', () async {
        // Arrange
        const productWithZeroId = Product(
          id: 0,
          title: 'Zero ID Product',
          price: 10.0,
          description: 'Test',
          category: 'Test',
          image: 'test.png',
          rating: 1.0,
          ratingCount: 1,
        );
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: productWithZeroId,
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.product.id, 0);
          },
        );
      });

      test('should calculate correct totals after adding items', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1, // Price: 29.99
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.subtotal, 29.99);
            expect(cart.total, 29.99); // No shipping cost
            expect(cart.itemCount, 1);
          },
        );
      });
    });

    group('Repository interactions', () {
      test('should call updateCart exactly once on success', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        await useCase(
          currentCart: emptyCart,
          product: testProduct1,
        );

        // Assert
        verify(mockRepository.updateCart(any)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should pass correct cart to repository', () async {
        // Arrange
        Cart? capturedCart;
        when(mockRepository.updateCart(any))
            .thenAnswer((invocation) async {
          capturedCart = invocation.positionalArguments[0] as Cart;
          return const Right(null);
        });

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
          selectedSize: 'M',
        );

        // Assert
        expect(capturedCart, isNotNull);
        expect(capturedCart!.items.length, 1);
        expect(capturedCart!.items.first.product.id, testProduct1.id);
        
        // Verify returned cart matches what was passed to repository
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) => expect(cart, equals(capturedCart)),
        );
      });
    });

    group('Cart item ID generation', () {
      test('should use product id as cart item id', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.first.id, testProduct1.id.toString());
          },
        );
      });
    });
  });
}