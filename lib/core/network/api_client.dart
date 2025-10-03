import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw ServerException('Resource not found');
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ServerException('Request failed: ${response.statusCode}');
    }
  }
}
