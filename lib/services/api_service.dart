import 'package:http/http.dart';
import 'dart:convert';
import 'api_constants.dart';
import '../models/product.dart';
 
class ApiService {
  final Client _client = Client();
  
  // Method to fetch product by barcode
  Future<Product> fetchProductByBarcode(String barcode) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.prod}/$barcode');
    
    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw ApiException('Product not found for barcode: $barcode');
      } else {
        throw ApiException('Failed to fetch product: HTTP ${response.statusCode}');
      }
    } on FormatException {
      throw ApiException('Invalid JSON response format');
    } on ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }
  
  // method to search products by name
  Future<List<Product>> searchProductsByName(
    String query, {
    String? category,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/search')
      ..queryParameters.addAll({
        'search_terms': query,
        'fields': 'id,product_name,ingredients_text_en,'
            'nutriments,image_front_url,food_groups_tags',
      });
    
    if (category != null && category.isNotEmpty) {
      uri.queryParameters['search_categories'] = category;
    }
    
    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Search request timed out'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> productsJson = jsonData['products'] ?? [];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Search failed: HTTP ${response.statusCode}');
      }
    } on FormatException {
      throw ApiException('Invalid search response format');
    } on ClientException catch (e) {
      throw ApiException('Network error during search: ${e.message}');
    }
  }
  
  void dispose() {
    _client.close();
  }
}
 
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}
 
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}