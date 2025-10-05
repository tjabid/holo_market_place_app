import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_local_datasource.dart';
import 'package:holo_market_place_app/features/products/data/dto/cart/cart_dto.dart';
import 'package:holo_market_place_app/features/products/data/dto/cart/cart_product_dto.dart';

@GenerateMocks([SharedPreferences])
import 'cart_local_datasource_test.mocks.dart';

void main() {
  late CartLocalDatasourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = CartLocalDatasourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('CartLocalDatasourceImpl', () {
    final testCartProducts = [
      CartProductDto(
        productId: 1,
        quantity: 2,
        selectedSize: 'M',
      ),
      CartProductDto(
        productId: 2,
        quantity: 1,
        selectedSize: 'L',
      ),
    ];

    final testCartDto = CartDto(
      id: 1,
      userId: 123,
      date: '2025-10-05',
      products: testCartProducts,
      shippingCost: 15.99,
    );

    final testCartJson = {
      'id': 1,
      'userId': 123,
      'date': '2025-10-05',
      'products': [
        {
          'productId': 1,
          'quantity': 2,
          'selectedSize': 'M',
        },
        {
          'productId': 2,
          'quantity': 1,
          'selectedSize': 'L',
        },
      ],
      'shippingCost': 15.99,
    };

    group('getCart', () {
      test('should return CartDto when cart data exists in SharedPreferences', () async {
        // Arrange
        final cartJsonString = json.encode(testCartJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(cartJsonString);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<CartDto>());
        expect(result!.id, 1);
        expect(result.userId, 123);
        expect(result.date, '2025-10-05');
        expect(result.products.length, 2);
        expect(result.products[0].productId, 1);
        expect(result.products[0].quantity, 2);
        expect(result.products[0].selectedSize, 'M');
        expect(result.products[1].productId, 2);
        expect(result.products[1].quantity, 1);
        expect(result.products[1].selectedSize, 'L');
        expect(result.shippingCost, 15.99);
        
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
        verifyNoMoreInteractions(mockSharedPreferences);
      });

      test('should return null when no cart data exists in SharedPreferences', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNull);
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
        verifyNoMoreInteractions(mockSharedPreferences);
      });

      test('should return empty cart when cart data is empty JSON', () async {
        // Arrange
        final emptyCartJson = {
          'id': 0,
          'userId': 0,
          'date': '',
          'products': [],
          'shippingCost': 0,
        };
        final emptyCartJsonString = json.encode(emptyCartJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(emptyCartJsonString);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 0);
        expect(result.userId, 0);
        expect(result.date, '');
        expect(result.products, isEmpty);
        expect(result.shippingCost, 0);
      });

      test('should handle cart with no shipping cost (defaults to 0)', () async {
        // Arrange
        final cartWithoutShippingJson = {
          'id': 1,
          'userId': 123,
          'date': '2025-10-05',
          'products': [
            {
              'productId': 1,
              'quantity': 1,
              'selectedSize': 'M',
            },
          ],
          // No shippingCost field
        };
        final cartJsonString = json.encode(cartWithoutShippingJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(cartJsonString);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result!.shippingCost, 0); // Should default to 0
      });

      test('should handle cart with large number of products', () async {
        // Arrange
        final largeProductList = List.generate(100, (index) => {
          'productId': index + 1,
          'quantity': (index % 5) + 1,
          'selectedSize': ['S', 'M', 'L', 'XL'][index % 4],
        });
        final largeCartJson = {
          'id': 1,
          'userId': 123,
          'date': '2025-10-05',
          'products': largeProductList,
          'shippingCost': 25.99,
        };
        final cartJsonString = json.encode(largeCartJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(cartJsonString);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result!.products.length, 100);
        expect(result.products.first.productId, 1);
        expect(result.products.last.productId, 100);
      });

      test('should throw exception when JSON is invalid', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn('invalid json string');

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<FormatException>()),
        );
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
      });

      test('should throw exception when JSON structure is invalid', () async {
        // Arrange
        final invalidCartJson = {
          'invalid_field': 'invalid_value',
          // Missing required fields
        };
        final invalidJsonString = json.encode(invalidCartJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(invalidJsonString);

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle products with null selectedSize', () async {
        // Arrange
        final cartWithNullSizeJson = {
          'id': 1,
          'userId': 123,
          'date': '2025-10-05',
          'products': [
            {
              'productId': 1,
              'quantity': 2,
              'selectedSize': null,
            },
          ],
          'shippingCost': 0,
        };
        final cartJsonString = json.encode(cartWithNullSizeJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(cartJsonString);

        // Act
        final result = await dataSource.getCart();

        // Assert
        expect(result, isNotNull);
        expect(result!.products.length, 1);
        expect(result.products[0].selectedSize, isNull);
      });
    });

    group('updateCart', () {
      test('should save cart data to SharedPreferences as JSON string', () async {
        // Arrange
        final expectedJsonString = json.encode(testCartJson);
        when(mockSharedPreferences.setString('CART_DATA', expectedJsonString))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.updateCart(testCartDto);

        // Assert
        verify(mockSharedPreferences.setString('CART_DATA', expectedJsonString)).called(1);
        verifyNoMoreInteractions(mockSharedPreferences);
      });

      test('should save cart with single product', () async {
        // Arrange
        final singleProductCart = CartDto(
          id: 2,
          userId: 456,
          date: '2025-10-06',
          products: [
            CartProductDto(
              productId: 3,
              quantity: 5,
              selectedSize: 'XL',
            ),
          ],
          shippingCost: 5.99,
        );
        final expectedJson = {
          'id': 2,
          'userId': 456,
          'date': '2025-10-06',
          'products': [
            {
              'productId': 3,
              'quantity': 5,
              'selectedSize': 'XL',
            },
          ],
          'shippingCost': 5.99,
        };
        final expectedJsonString = json.encode(expectedJson);
        when(mockSharedPreferences.setString('CART_DATA', expectedJsonString))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.updateCart(singleProductCart);

        // Assert
        verify(mockSharedPreferences.setString('CART_DATA', expectedJsonString)).called(1);
      });

      test('should handle cart with zero shipping cost', () async {
        // Arrange
        final zeroShippingCart = CartDto(
          id: 1,
          userId: 123,
          date: '2025-10-05',
          products: testCartProducts,
          shippingCost: 0.0,
        );
        final expectedJson = {
          'id': 1,
          'userId': 123,
          'date': '2025-10-05',
          'products': [
            {
              'productId': 1,
              'quantity': 2,
              'selectedSize': 'M',
            },
            {
              'productId': 2,
              'quantity': 1,
              'selectedSize': 'L',
            },
          ],
          'shippingCost': 0.0,
        };
        final expectedJsonString = json.encode(expectedJson);
        when(mockSharedPreferences.setString('CART_DATA', expectedJsonString))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.updateCart(zeroShippingCart);

        // Assert
        verify(mockSharedPreferences.setString('CART_DATA', expectedJsonString)).called(1);
      });

      test('should handle SharedPreferences failure', () async {
        // Arrange
        when(mockSharedPreferences.setString('CART_DATA', any))
            .thenThrow(Exception('SharedPreferences error'));

        // Act & Assert
        expect(
          () => dataSource.updateCart(testCartDto),
          throwsA(isA<Exception>()),
        );
        verify(mockSharedPreferences.setString('CART_DATA', any)).called(1);
      });

    });

    group('clearCart', () {
      test('should remove cart data from SharedPreferences', () async {
        // Arrange
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearCart();

        // Assert
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
        verifyNoMoreInteractions(mockSharedPreferences);
      });

      test('should handle removal when no cart data exists', () async {
        // Arrange
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenAnswer((_) async => false);

        // Act
        await dataSource.clearCart();

        // Assert
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
        verifyNoMoreInteractions(mockSharedPreferences);
      });

      test('should handle SharedPreferences failure during clear', () async {
        // Arrange
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenThrow(Exception('SharedPreferences clear error'));

        // Act & Assert
        expect(
          () => dataSource.clearCart(),
          throwsA(isA<Exception>()),
        );
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
      });

      test('should complete successfully even if key does not exist', () async {
        // Arrange
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenAnswer((_) async => false); // Key didn't exist

        // Act
        await dataSource.clearCart();

        // Assert
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
        // Should not throw any exception
      });
    });

    group('Integration scenarios', () {
      test('should save and retrieve cart correctly (round trip)', () async {
        // Arrange
        final cartJsonString = json.encode(testCartJson);
        when(mockSharedPreferences.setString('CART_DATA', cartJsonString))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(cartJsonString);

        // Act
        await dataSource.updateCart(testCartDto);
        final retrievedCart = await dataSource.getCart();

        // Assert
        expect(retrievedCart, isNotNull);
        expect(retrievedCart!.id, testCartDto.id);
        expect(retrievedCart.userId, testCartDto.userId);
        expect(retrievedCart.date, testCartDto.date);
        expect(retrievedCart.products.length, testCartDto.products.length);
        expect(retrievedCart.shippingCost, testCartDto.shippingCost);
        
        verify(mockSharedPreferences.setString('CART_DATA', cartJsonString)).called(1);
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
      });

      test('should clear cart and return null on subsequent get', () async {
        // Arrange
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(null);

        // Act
        await dataSource.clearCart();
        final retrievedCart = await dataSource.getCart();

        // Assert
        expect(retrievedCart, isNull);
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
      });

      test('should handle multiple rapid operations', () async {
        // Arrange
        when(mockSharedPreferences.setString('CART_DATA', any))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('CART_DATA'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(null);

        // Act
        await dataSource.updateCart(testCartDto);
        await dataSource.clearCart();
        final cartAfterClear = await dataSource.getCart();
        await dataSource.updateCart(testCartDto);

        // Assert
        expect(cartAfterClear, isNull); // getCart after clear should return null
        verify(mockSharedPreferences.setString('CART_DATA', any)).called(2);
        verify(mockSharedPreferences.remove('CART_DATA')).called(1);
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
      });
    });

    group('Constructor and dependencies', () {
      test('should create instance with required SharedPreferences dependency', () {
        // Act
        final instance = CartLocalDatasourceImpl(sharedPreferences: mockSharedPreferences);

        // Assert
        expect(instance, isA<CartLocalDatasourceImpl>());
        expect(instance, isA<CartLocalDatasource>());
      });
    });

    group('Constants and keys', () {
      test('should use correct storage key', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(null);

        // Act
        await dataSource.getCart();

        // Assert
        verify(mockSharedPreferences.getString('CART_DATA')).called(1);
        // Verifies the correct key is being used
      });
    });

    group('Error handling edge cases', () {
      test('should handle empty string from SharedPreferences', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn('');

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle whitespace string from SharedPreferences', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn('   ');

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle malformed JSON with partial cart data', () async {
        // Arrange
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn('{"id": 1, "userId":'); // Incomplete JSON

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle JSON with wrong data types', () async {
        // Arrange
        final wrongTypeJson = {
          'id': 'string_instead_of_int',
          'userId': 123,
          'date': '2025-10-05',
          'products': [],
          'shippingCost': 0,
        };
        final wrongTypeJsonString = json.encode(wrongTypeJson);
        when(mockSharedPreferences.getString('CART_DATA'))
            .thenReturn(wrongTypeJsonString);

        // Act & Assert
        expect(
          () => dataSource.getCart(),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}