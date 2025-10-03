import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/get_products_by_category.dart';
import '../../features/products/domain/usecases/get_categories.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/settings_service.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Products
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

  // Core
  sl.registerLazySingleton(() => ApiClient(client: sl()));

  // External
  sl.registerLazySingleton(() => http.Client());
  
}
