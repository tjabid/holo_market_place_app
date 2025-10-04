import 'package:dartz/dartz.dart';
import 'package:holo_market_place_app/core/error/exceptions.dart';
import 'package:holo_market_place_app/core/error/failures.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_local_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/dto/cart/cart_dto.dart';
import 'package:holo_market_place_app/features/products/data/mappers/product_mapper.dart';
import 'package:holo_market_place_app/features/products/domain/entities/cart/cart.dart';

import '../../domain/repositories/cart_repository.dart';
import '../mappers/cart_mapper.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDatasource cartRemoteDatasource;
  final CartLocalDatasource cartLocalDatasource;
  final ProductRemoteDataSource productRemoteDatasource;

  CartRepositoryImpl(
      {required this.cartRemoteDatasource,
      required this.cartLocalDatasource,
      required this.productRemoteDatasource});

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final productsResult = await productRemoteDatasource.getProducts();
      final products =
          productsResult.map((model) => mapProductEntity(model)).toList();

      final localCart = await cartLocalDatasource.getCart();
      if (localCart != null) {
        return Right(mapCartDtoToEntity(localCart, products));
      }

      final remoteDto = await cartRemoteDatasource.getCart();
      return Right(mapCartDtoToEntity(remoteDto, products));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<void> addToCart(int productId, int quantity) {
    // TODO: implement addToCart
    throw UnimplementedError();
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) {
    // TODO: implement updateQuantity
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromCart(int productId) {
    // TODO: implement removeFromCart
    throw UnimplementedError();
  }

  @override
  Future<void> clearCart() {
    // TODO: implement clearCart
    throw UnimplementedError();
  }

  @override
  Future<void> applyPromoCode(String promoCode) {
    // TODO: implement applyPromoCode
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getAvailablePromoCodes() {
    // TODO: implement getAvailablePromoCodes
    throw UnimplementedError();
  }

  @override
  Future<void> removePromoCode() {
    // TODO: implement removePromoCode
    throw UnimplementedError();
  }
}
