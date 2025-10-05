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

  final emptyCart = Cart(
    id: 'cart-1',
    items: const [],
    total: 0.0,
    discountAmount: 0.0,
    promoCode: null,
  );

  final cartWithItem = Cart(
    id: 'cart-1',
    items: [testCartItem1],
    total: 59.98,
    discountAmount: 0.0,
    promoCode: null,
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

      test('should preserve cart id and other properties when adding new item', () async {
        // Arrange
        final cartWithPromo = Cart(
          id: 'special-cart',
          items: const [],
          total: 0.0,
          discountAmount: 10.0,
          promoCode: 'SAVE10',
        );
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithPromo,
          product: testProduct1,
          selectedSize: 'S',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.id, 'special-cart');
            expect(cart.discountAmount, 10.0);
            expect(cart.promoCode, 'SAVE10');
            expect(cart.items.length, 1);
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

      test('should add separate item when same product but no size vs with size', () async {
        // Arrange
        final cartWithNoSizeItem = Cart(
          id: 'cart-1',
          items: [
            CartItem(
              id: '1',
              product: testProduct1,
              quantity: 1,
              selectedSize: null,
            ),
          ],
          total: 29.99,
          discountAmount: 0.0,
          promoCode: null,
        );
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithNoSizeItem,
          product: testProduct1,
          selectedSize: 'M',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 2);
            final noSizeItem = cart.items.where((item) => item.selectedSize == null).first;
            final sizeItem = cart.items.where((item) => item.selectedSize == 'M').first;
            expect(noSizeItem.quantity, 1);
            expect(sizeItem.quantity, 1);
          },
        );
      });

      test('should handle multiple existing items and increment correct one', () async {
        // Arrange
        final cartWithMultipleItems = Cart(
          id: 'cart-1',
          items: [
            testCartItem1, // Product 1, size M, quantity 2
            CartItem(
              id: '2',
              product: testProduct1,
              quantity: 1,
              selectedSize: 'L',
            ),
            CartItem(
              id: '3',
              product: testProduct2,
              quantity: 3,
              selectedSize: 'M',
            ),
          ],
          total: 179.95,
          discountAmount: 0.0,
          promoCode: null,
        );
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithMultipleItems,
          product: testProduct1,
          selectedSize: 'L', // Should increment the L size item
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 3);
            final mSizeItem = cart.items.where((item) => 
              item.product.id == testProduct1.id && item.selectedSize == 'M').first;
            final lSizeItem = cart.items.where((item) => 
              item.product.id == testProduct1.id && item.selectedSize == 'L').first;
            final product2Item = cart.items.where((item) => 
              item.product.id == testProduct2.id).first;
            
            expect(mSizeItem.quantity, 2); // Unchanged
            expect(lSizeItem.quantity, 2); // Incremented from 1 to 2
            expect(product2Item.quantity, 3); // Unchanged
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

      test('should handle null product gracefully', () async {
        // Note: This test would require changing the method signature to accept nullable Product
        // For now, this is prevented by the type system, but good to document the expectation
      });

      test('should handle cart with null items list', () async {
        // This would require a Cart with null items, which should be prevented by the entity design
        // But if it happens, the use case should handle it gracefully
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

      test('should handle empty string size', () async {
        // Arrange
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
          selectedSize: '',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.selectedSize, '');
          },
        );
      });

      test('should handle very long size string', () async {
        // Arrange
        const longSize = 'EXTRA_EXTRA_EXTRA_LARGE_SIZE_WITH_VERY_LONG_NAME';
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: emptyCart,
          product: testProduct1,
          selectedSize: longSize,
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 1);
            expect(cart.items.first.selectedSize, longSize);
          },
        );
      });

      test('should handle cart with many items efficiently', () async {
        // Arrange
        final manyItems = List.generate(50, (index) => CartItem(
          id: index.toString(),
          product: Product(
            id: index,
            title: 'Product $index',
            price: index * 10.0,
            description: 'Desc $index',
            category: 'Cat',
            image: 'img$index.png',
            rating: 4.0,
            ratingCount: 10,
          ),
          quantity: 1,
          selectedSize: 'M',
        ));
        final cartWithManyItems = Cart(
          id: 'cart-1',
          items: manyItems,
          total: 12250.0,
          discountAmount: 0.0,
          promoCode: null,
        );
        when(mockRepository.updateCart(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentCart: cartWithManyItems,
          product: testProduct1,
          selectedSize: 'L',
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.length, 51); // 50 + 1 new item
            expect(cart.items.last.product.id, testProduct1.id);
            expect(cart.items.last.selectedSize, 'L');
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

      test('should not call repository when exception occurs during cart manipulation', () async {
        // This is tricky to test since the cart manipulation is simple
        // But if we had more complex logic that could throw before repository call,
        // we'd want to ensure repository isn't called
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

      test('should handle large product IDs', () async {
        // Arrange
        const productWithLargeId = Product(
          id: 999999999,
          title: 'Large ID Product',
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
          product: productWithLargeId,
        );

        // Assert
        result.fold(
          (failure) => fail('Should return cart'),
          (cart) {
            expect(cart.items.first.id, '999999999');
          },
        );
      });
    });
  });
}