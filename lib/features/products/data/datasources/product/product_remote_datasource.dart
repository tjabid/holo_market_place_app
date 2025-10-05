import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../../../domain/entities/product/category.dart';
import '../../dto/product_dto.dart';
import '../../mappers/category_mapper.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductDto>> getProducts();
  Future<ProductDto> getProductById(int id);
  Future<List<ProductDto>> getProductsByCategory(String category);
  Future<List<Category>> getCategories();
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

  @override
  Future<ProductDto> getProductById(int id) async {
    try {
      final response = await apiClient.get('${ApiConstants.products}/$id');
      return ProductDto.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch product: $e');
    }
  }

  @override
  Future<List<ProductDto>> getProductsByCategory(String category) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.productsByCategory}/$category',
      );
      final List<ProductDto> products = (response as List)
          .map((json) => ProductDto.fromJson(json))
          .toList();
      return products;
    } catch (e) {
      throw ServerException('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await apiClient.get(ApiConstants.categories);
      final list = List<String>.from(response);
      list.add('all');
      return list.reversed.map((model) => mapStringToCategory(model, false)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch categories: $e');
    }
  }
}
