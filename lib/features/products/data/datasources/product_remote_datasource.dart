import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../dto/product_dto.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductDto>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductDto>> getProducts() async {
    try {
      final response = await apiClient.get(ApiConstants.products);
      final List<ProductDto> products = (response as List)
          .map((json) => ProductDto.fromJson(json))
          .toList();
      return products;
    } catch (e) {
      throw ServerException('Failed to fetch products: $e');
    }
  }
}
