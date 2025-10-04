import 'package:get_it/get_it.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_local_datasource.dart';
import 'package:holo_market_place_app/features/products/data/datasources/cart/cart_remote_datasource.dart';
import 'package:holo_market_place_app/features/products/data/repositories/cart_repository_impl.dart';
import 'package:holo_market_place_app/features/products/domain/repositories/cart_repository.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/add_to_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/get_cart.dart';
import 'package:holo_market_place_app/features/products/domain/usecases/cart/remove_from_cart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/get_products_by_category.dart';
import '../../features/products/domain/usecases/get_categories.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/presentation/cubit/cart_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient(client: sl()));

  // External
  sl.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features 

  // - Products - 
  // Cubits
  sl.registerFactory(
    () => ProductsCubit(
      getProductsUseCase: sl(),
      getProductsByCategoryUseCase: sl(),
      getCategoriesUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );

  // Cart 

  // Use Cases
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      cartRemoteDatasource: sl(),
      cartLocalDatasource: sl(),
      productRemoteDatasource: sl(),
      ),
  );

  // Data sources
  sl.registerLazySingleton<CartRemoteDatasource>(
    () => CartRemoteDatasourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CartLocalDatasource>(
    () => CartLocalDatasourceImpl(sharedPreferences: sl()),
  );

  // Cubit - factory creates new instance when needed
  sl.registerFactory(() => CartCubit(
    getCartUseCase: sl(),
  ));
}