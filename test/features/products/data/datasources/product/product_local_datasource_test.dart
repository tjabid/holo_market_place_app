import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:holo_market_place_app/features/products/data/datasources/product/product_local_datasource.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/product.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';

void main() {
  late ProductLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = ProductLocalDataSourceImpl();
  });

  group('ProductLocalDataSourceImpl', () {
    final testProducts = [
      const Product(
        id: 1,
        title: 'Electronics Product',
        price: 299.99,
        description: 'High-tech electronics device',
        category: 'electronics',
        image: 'https://example.com/electronics.jpg',
        rating: 4.5,
        ratingCount: 150,
      ),
      const Product(
        id: 2,
        title: 'Clothing Item',
        price: 49.99,
        description: 'Comfortable clothing',
        category: 'clothing',
        image: 'https://example.com/clothing.jpg',
        rating: 4.0,
        ratingCount: 80,
      ),
      const Product(
        id: 3,
        title: 'Another Electronics',
        price: 199.99,
        description: 'More electronics',
        category: 'Electronics', // Different case
        image: 'https://example.com/electronics2.jpg',
        rating: 4.7,
        ratingCount: 200,
      ),
      const Product(
        id: 4,
        title: 'Jewelry Item',
        price: 799.99,
        description: 'Beautiful jewelry piece',
        category: 'jewelery',
        image: 'https://example.com/jewelry.jpg',
        rating: 4.9,
        ratingCount: 50,
      ),
    ];

    final testCategories = [
      const Category(
        id: 'all',
        displayName: 'All',
        icon: Icons.category,
        isSelected: true,
      ),
      const Category(
        id: 'electronics',
        displayName: 'Electronics',
        icon: Icons.devices,
        isSelected: false,
      ),
      const Category(
        id: 'clothing',
        displayName: 'Clothing',
        icon: Icons.shopping_bag,
        isSelected: false,
      ),
    ];

    group('Product caching', () {
      test('should cache products successfully', () async {
        // Act
        await dataSource.cacheProducts(testProducts);

        // Assert
        expect(dataSource.allProducts, equals(testProducts));
        expect(dataSource.allProducts.length, testProducts.length);
      });

      test('should return cached products', () async {
        // Arrange
        await dataSource.cacheProducts(testProducts);

        // Act
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, equals(testProducts));
        expect(result.length, testProducts.length);
        expect(result[0].id, 1);
        expect(result[0].title, 'Electronics Product');
        expect(result[1].id, 2);
        expect(result[1].title, 'Clothing Item');
      });

      test('should return empty list when no products cached', () async {
        // Act
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Product>>());
      });

      test('should replace cached products when caching new ones', () async {
        // Arrange
        const initialProducts = [
          Product(
            id: 999,
            title: 'Initial Product',
            price: 10.0,
            description: 'Initial',
            category: 'initial',
            image: 'initial.jpg',
            rating: 1.0,
            ratingCount: 1,
          ),
        ];
        await dataSource.cacheProducts(initialProducts);

        // Act
        await dataSource.cacheProducts(testProducts);
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, equals(testProducts));
        expect(result.length, testProducts.length);
        expect(result.any((p) => p.id == 999), false);
        expect(result.any((p) => p.id == 1), true);
      });

      test('should handle caching empty product list', () async {
        // Arrange
        await dataSource.cacheProducts(testProducts);

        // Act
        await dataSource.cacheProducts([]);
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, isEmpty);
        expect(dataSource.allProducts, isEmpty);
      });

      test('should handle caching large number of products', () async {
        // Arrange
        final largeProductList = List.generate(1000, (index) => Product(
          id: index,
          title: 'Product $index',
          price: index * 10.0,
          description: 'Description $index',
          category: 'category${index % 5}',
          image: 'image$index.jpg',
          rating: 1.0 + (index % 5),
          ratingCount: index + 1,
        ));

        // Act
        await dataSource.cacheProducts(largeProductList);
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result.length, 1000);
        expect(result.first.id, 0);
        expect(result.last.id, 999);
      });
    });

    group('Category caching', () {
      test('should cache categories successfully', () async {
        // Act
        await dataSource.cacheCategories(testCategories);

        // Assert
        expect(dataSource.categories, equals(testCategories));
        expect(dataSource.categories.length, testCategories.length);
      });

      test('should return cached categories', () async {
        // Arrange
        await dataSource.cacheCategories(testCategories);

        // Act
        final result = await dataSource.getCachedCategories();

        // Assert
        expect(result, equals(testCategories));
        expect(result.length, testCategories.length);
        expect(result[0].id, 'all');
        expect(result[0].displayName, 'All');
        expect(result[0].isSelected, true);
        expect(result[1].id, 'electronics');
        expect(result[1].isSelected, false);
      });

      test('should return empty list when no categories cached', () async {
        // Act
        final result = await dataSource.getCachedCategories();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Category>>());
      });

      test('should replace cached categories when caching new ones', () async {
        // Arrange
        const initialCategories = [
          Category(
            id: 'initial',
            displayName: 'Initial',
            icon: Icons.category,
            isSelected: false,
          ),
        ];
        await dataSource.cacheCategories(initialCategories);

        // Act
        await dataSource.cacheCategories(testCategories);
        final result = await dataSource.getCachedCategories();

        // Assert
        expect(result, equals(testCategories));
        expect(result.length, testCategories.length);
        expect(result.any((c) => c.id == 'initial'), false);
        expect(result.any((c) => c.id == 'all'), true);
      });

      test('should handle caching empty category list', () async {
        // Arrange
        await dataSource.cacheCategories(testCategories);

        // Act
        await dataSource.cacheCategories([]);
        final result = await dataSource.getCachedCategories();

        // Assert
        expect(result, isEmpty);
        expect(dataSource.categories, isEmpty);
      });

      test('should maintain category selection state', () async {
        // Arrange
        const categoriesWithDifferentSelection = [
          Category(
            id: 'electronics',
            displayName: 'Electronics',
            icon: Icons.devices,
            isSelected: true,
          ),
          Category(
            id: 'clothing',
            displayName: 'Clothing',
            icon: Icons.shopping_bag,
            isSelected: false,
          ),
        ];

        // Act
        await dataSource.cacheCategories(categoriesWithDifferentSelection);
        final result = await dataSource.getCachedCategories();

        // Assert
        expect(result[0].isSelected, true);
        expect(result[1].isSelected, false);
      });
    });

    group('Product retrieval by ID', () {
      setUp(() async {
        await dataSource.cacheProducts(testProducts);
      });

      test('should return product when found by ID', () async {
        // Act
        final result = await dataSource.getProductById(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.title, 'Electronics Product');
        expect(result.price, 299.99);
        expect(result.category, 'electronics');
      });

      test('should return null when product not found by ID', () async {
        // Act
        final result = await dataSource.getProductById(999);

        // Assert
        expect(result, isNull);
      });

      test('should return first product when multiple products have same ID (edge case)', () async {
        // Arrange
        const duplicateProducts = [
          Product(
            id: 1,
            title: 'First Product',
            price: 10.0,
            description: 'First',
            category: 'test',
            image: 'first.jpg',
            rating: 1.0,
            ratingCount: 1,
          ),
          Product(
            id: 1,
            title: 'Second Product',
            price: 20.0,
            description: 'Second',
            category: 'test',
            image: 'second.jpg',
            rating: 2.0,
            ratingCount: 2,
          ),
        ];
        await dataSource.cacheProducts(duplicateProducts);

        // Act
        final result = await dataSource.getProductById(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.title, 'First Product');
        expect(result.price, 10.0);
      });

      test('should handle ID 0', () async {
        // Arrange
        const productWithZeroId = Product(
          id: 0,
          title: 'Zero ID Product',
          price: 0.0,
          description: 'Zero',
          category: 'zero',
          image: 'zero.jpg',
          rating: 0.0,
          ratingCount: 0,
        );
        await dataSource.cacheProducts([productWithZeroId]);

        // Act
        final result = await dataSource.getProductById(0);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 0);
        expect(result.title, 'Zero ID Product');
      });

      test('should handle negative ID', () async {
        // Act
        final result = await dataSource.getProductById(-1);

        // Assert
        expect(result, isNull);
      });

      test('should handle very large ID', () async {
        // Act
        final result = await dataSource.getProductById(999999999);

        // Assert
        expect(result, isNull);
      });

      test('should return null when no products cached', () async {
        // Arrange
        final emptyDataSource = ProductLocalDataSourceImpl();

        // Act
        final result = await emptyDataSource.getProductById(1);

        // Assert
        expect(result, isNull);
      });
    });

    group('Products by category', () {
      setUp(() async {
        await dataSource.cacheProducts(testProducts);
      });

      test('should return products matching category (case insensitive)', () async {
        // Act
        final result = await dataSource.getProductsByCategory('electronics');

        // Assert
        expect(result.length, 2); // Both electronics products
        expect(result[0].id, 1);
        expect(result[0].category, 'electronics');
        expect(result[1].id, 3);
        expect(result[1].category, 'Electronics'); // Different case but should match
      });

      test('should return products with exact case match', () async {
        // Act
        final result = await dataSource.getProductsByCategory('clothing');

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 2);
        expect(result[0].category, 'clothing');
        expect(result[0].title, 'Clothing Item');
      });

      test('should handle case insensitive matching', () async {
        // Act
        final upperCaseResult = await dataSource.getProductsByCategory('ELECTRONICS');
        final lowerCaseResult = await dataSource.getProductsByCategory('electronics');
        final mixedCaseResult = await dataSource.getProductsByCategory('Electronics');

        // Assert
        expect(upperCaseResult.length, 2);
        expect(lowerCaseResult.length, 2);
        expect(mixedCaseResult.length, 2);
        expect(upperCaseResult, equals(lowerCaseResult));
        expect(lowerCaseResult, equals(mixedCaseResult));
      });

      test('should return empty list when category not found', () async {
        // Act
        final result = await dataSource.getProductsByCategory('nonexistent');

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Product>>());
      });

      test('should handle empty category string', () async {
        // Act
        final result = await dataSource.getProductsByCategory('');

        // Assert
        expect(result, isEmpty);
      });

      test('should handle categories with special characters', () async {
        // Arrange
        const specialProducts = [
          Product(
            id: 100,
            title: "Men's Shirt",
            price: 59.99,
            description: 'Nice shirt',
            category: "men's clothing",
            image: 'shirt.jpg',
            rating: 4.0,
            ratingCount: 30,
          ),
          Product(
            id: 101,
            title: "Women's Dress",
            price: 89.99,
            description: 'Beautiful dress',
            category: "women's clothing",
            image: 'dress.jpg',
            rating: 4.5,
            ratingCount: 40,
          ),
        ];
        await dataSource.cacheProducts([...testProducts, ...specialProducts]);

        // Act
        final mensResult = await dataSource.getProductsByCategory("men's clothing");
        final womensResult = await dataSource.getProductsByCategory("women's clothing");

        // Assert
        expect(mensResult.length, 1);
        expect(mensResult[0].id, 100);
        expect(womensResult.length, 1);
        expect(womensResult[0].id, 101);
      });

      test('should return all products for each category correctly', () async {
        // Act
        final electronicsProducts = await dataSource.getProductsByCategory('electronics');
        final clothingProducts = await dataSource.getProductsByCategory('clothing');
        final jewelryProducts = await dataSource.getProductsByCategory('jewelery');

        // Assert
        expect(electronicsProducts.length, 2);
        expect(clothingProducts.length, 1);
        expect(jewelryProducts.length, 1);
        
        // Verify correct products are returned
        expect(electronicsProducts.map((p) => p.id), containsAll([1, 3]));
        expect(clothingProducts.map((p) => p.id), contains(2));
        expect(jewelryProducts.map((p) => p.id), contains(4));
      });

      test('should maintain product order from cache', () async {
        // Act
        final result = await dataSource.getProductsByCategory('electronics');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 1); // First electronics product in cache
        expect(result[1].id, 3); // Second electronics product in cache
      });

      test('should return empty list when no products cached', () async {
        // Arrange
        final emptyDataSource = ProductLocalDataSourceImpl();

        // Act
        final result = await emptyDataSource.getProductsByCategory('electronics');

        // Assert
        expect(result, isEmpty);
      });

      test('should handle whitespace in category names', () async {
        // Arrange
        const productWithSpaces = Product(
          id: 200,
          title: 'Spaced Category Product',
          price: 25.99,
          description: 'Product with spaces',
          category: ' electronics ',
          image: 'spaced.jpg',
          rating: 3.0,
          ratingCount: 10,
        );
        await dataSource.cacheProducts([...testProducts, productWithSpaces]);

        // Act
        final exactResult = await dataSource.getProductsByCategory(' electronics ');
        final trimmedResult = await dataSource.getProductsByCategory('electronics');

        // Assert
        expect(exactResult.length, 1);
        expect(exactResult[0].id, 200);
        expect(trimmedResult.length, 2); // Original electronics products, not the spaced one
      });
    });

    group('Data persistence and state', () {
      test('should maintain separate product and category caches', () async {
        // Act
        await dataSource.cacheProducts(testProducts);
        await dataSource.cacheCategories(testCategories);

        // Assert
        final products = await dataSource.getCachedProducts();
        final categories = await dataSource.getCachedCategories();
        
        expect(products.length, testProducts.length);
        expect(categories.length, testCategories.length);
        expect(products, equals(testProducts));
        expect(categories, equals(testCategories));
      });

      test('should not affect other operations when caching products', () async {
        // Arrange
        await dataSource.cacheCategories(testCategories);

        // Act
        await dataSource.cacheProducts(testProducts);

        // Assert
        final categories = await dataSource.getCachedCategories();
        expect(categories, equals(testCategories)); // Categories should remain unchanged
      });

      test('should not affect other operations when caching categories', () async {
        // Arrange
        await dataSource.cacheProducts(testProducts);

        // Act
        await dataSource.cacheCategories(testCategories);

        // Assert
        final products = await dataSource.getCachedProducts();
        expect(products, equals(testProducts)); // Products should remain unchanged
      });

      test('should handle multiple instances independently', () async {
        // Arrange
        final dataSource1 = ProductLocalDataSourceImpl();
        final dataSource2 = ProductLocalDataSourceImpl();
        
        const products1 = [
          Product(
            id: 1,
            title: 'DataSource 1 Product',
            price: 10.0,
            description: 'DS1',
            category: 'test1',
            image: 'ds1.jpg',
            rating: 1.0,
            ratingCount: 1,
          ),
        ];
        
        const products2 = [
          Product(
            id: 2,
            title: 'DataSource 2 Product',
            price: 20.0,
            description: 'DS2',
            category: 'test2',
            image: 'ds2.jpg',
            rating: 2.0,
            ratingCount: 2,
          ),
        ];

        // Act
        await dataSource1.cacheProducts(products1);
        await dataSource2.cacheProducts(products2);

        // Assert
        final result1 = await dataSource1.getCachedProducts();
        final result2 = await dataSource2.getCachedProducts();
        
        expect(result1.length, 1);
        expect(result2.length, 1);
        expect(result1[0].id, 1);
        expect(result2[0].id, 2);
        expect(result1[0].title, 'DataSource 1 Product');
        expect(result2[0].title, 'DataSource 2 Product');
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null-safe operations gracefully', () async {
        // These operations should not throw even with empty cache
        expect(() => dataSource.getCachedProducts(), returnsNormally);
        expect(() => dataSource.getCachedCategories(), returnsNormally);
        expect(() => dataSource.getProductById(1), returnsNormally);
        expect(() => dataSource.getProductsByCategory('test'), returnsNormally);
      });

      test('should complete futures properly', () async {
        // All operations should return proper futures
        final productsFuture = dataSource.getCachedProducts();
        final categoriesFuture = dataSource.getCachedCategories();
        final productByIdFuture = dataSource.getProductById(1);
        final productsByCategoryFuture = dataSource.getProductsByCategory('test');

        expect(productsFuture, isA<Future<List<Product>>>());
        expect(categoriesFuture, isA<Future<List<Category>>>());
        expect(productByIdFuture, isA<Future<Product?>>());
        expect(productsByCategoryFuture, isA<Future<List<Product>>>());

        // Wait for completion
        await Future.wait([
          productsFuture,
          categoriesFuture,
          productByIdFuture,
          productsByCategoryFuture,
        ]);
      });

      test('should handle rapid successive operations', () async {
        // Arrange & Act
        final futures = List.generate(100, (index) async {
          await dataSource.cacheProducts([
            Product(
              id: index,
              title: 'Product $index',
              price: index.toDouble(),
              description: 'Desc $index',
              category: 'cat$index',
              image: 'img$index.jpg',
              rating: 1.0,
              ratingCount: 1,
            ),
          ]);
          return dataSource.getCachedProducts();
        });

        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 100);
        expect(results.last.length, 1); // Last operation should have 1 product
        expect(results.last[0].id, 99); // Last product should have id 99
      });
    });
  });
}