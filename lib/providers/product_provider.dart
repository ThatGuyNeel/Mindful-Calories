import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/product.dart';
 
class ProductState {
  final List<Product> recentProducts;
  final List<Product> searchResults;
  final Product? selectedProduct;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedCategory;
  
  ProductState({
    this.recentProducts = const [],
    this.searchResults = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory,
  });
  
  ProductState copyWith({
    List<Product>? recentProducts,
    List<Product>? searchResults,
    Product? selectedProduct,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ProductState(
      recentProducts: recentProducts ?? this.recentProducts,
      searchResults: searchResults ?? this.searchResults,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
 
class ProductNotifier extends StateNotifier<ProductState> {
  final ApiService _apiService;
  final Future<SharedPreferences> _prefs;
  
  ProductNotifier(this._apiService, this._prefs) : super(ProductState()) {
    _loadRecentProducts();
  }
  
  Future<void> _loadRecentProducts() async {
    final prefs = await _prefs;
    final recentProductsJson = prefs.getStringList('recent_products') ?? [];
    final recentProducts = recentProductsJson
      .map((productJson) => Product.fromJson(jsonDecode(productJson)))
      .toList();
    state = state.copyWith(recentProducts: recentProducts, isLoading: false);
  }
  
  Future<void> saveRecentProduct(Product product) async {
    final prefs = await _prefs;
    final recentProducts = prefs.getStringList('recent_products') ?? [];
    
    // Adds to beginning if not already in list
    final productJson = jsonEncode(product.toJson());
    if (!recentProducts.contains(productJson)) {
      recentProducts.insert(0, productJson);
      // Keeps the last 10 products at maximum
      if (recentProducts.length > 10) {
        recentProducts.removeRange(10, recentProducts.length);
      }
      await prefs.setStringList('recent_products', recentProducts);
      await _loadRecentProducts();
    }
  }
  
  Future<Product?> scanBarcode(String barcode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _apiService.fetchProductByBarcode(barcode);
      try {
        await saveRecentProduct(product);
      } catch (e, stack) {
        debugPrint('Failed to save recent product: $e');
        debugPrintStack(stackTrace: stack);
      }
      state = state.copyWith(
          selectedProduct: product,
          isLoading: false,
      );
      return product;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      return null;
    }
  }
  
  Future<void> searchProducts(String category) async {
    final query = category.trim();
    if (query.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchQuery: query,
      selectedCategory: query,
    );

    try {
      final results = await _apiService.searchProductsByName(query);
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
  void selectProduct(Product product) {
    state = state.copyWith(selectedProduct: product);
  }
  
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
 
final productNotifierProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final prefs = ref.read(sharedPreferencesProvider.future);
  return ProductNotifier(apiService, prefs);
});
 
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
}, name: 'sharedPreferencesProvider');
