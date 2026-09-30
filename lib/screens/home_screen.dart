import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
 
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
 
  @override
  //state declaration
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
//home screen state 
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
 
//designed to handle cleanup of resources associated with the user interaction with the search function
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
 
 //in the case that the query component in the search field is left empty: sets search results state to false
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty && _showSearchResults) {
      setState(() => _showSearchResults = false);
    }
  }

  // Runs the category search (Enter key or search icon)
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _showSearchResults = true);
    ref.read(productNotifierProvider.notifier).searchProducts(query);
  }
 
  void _scanBarcode() async {
    final capture = await showAiBarcodeScanner(context);
    final barcode = capture?.firstRawValue;
    if (barcode == null) {
      return;
    }
    final product = await ref.read(productNotifierProvider.notifier).scanBarcode(barcode);

    if (!mounted) return; 
    if (product != null) {
      _navigateToProductDetail(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Calories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // scan button + search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: _scanBarcode,
                        icon: const Icon(Icons.barcode_reader),
                        label: const Text('Scan Product'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: 'Search by category',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onChanged: _onSearchChanged,
                              onSubmitted: (_) => _performSearch(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _performSearch,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // recent products
              if (!_showSearchResults && state.recentProducts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Recent Products',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearRecentProducts,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),  
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.recentProducts.length,
                    itemBuilder: (context, index) =>
                        _buildRecentProductCard(state.recentProducts[index]), 
                  ),
              ],

              // search results 
              if (_showSearchResults) _buildSearchResults(state),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentProductCard(Product product) {
    final kcal = product.nutriments?.energyKcal100g;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: product.imageFrontUrl != null
                    ? Image.network(
                        product.imageFrontUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                kcal != null ? '${kcal.toStringAsFixed(0)} kcal' : 'N/A',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchResults(ProductState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }
    
    if (state.searchResults.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final product = state.searchResults[index];
        return _buildProductCard(product);
      },
    );
  }
  
  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (product.imageFrontUrl != null)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    product.imageFrontUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image),
                  ),
                )
              else
                SizedBox(
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.image_not_supported),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.nutriments != null)
                      Row(
                        children: [
                          _buildNutrientTag('Calories', '${product.nutriments!.energyKcal100g?.toStringAsFixed(0) ?? 'N/A'} kcal'),
                          const SizedBox(width: 8),
                          _buildNutrientTag('Protein', '${product.nutriments!.proteins100g?.toStringAsFixed(1) ?? 'N/A'}g'),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNutrientTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
  
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
  
  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsSheet(),
    );
  }
  
  void _clearRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_products');
    ref.invalidate(productNotifierProvider);
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No products found'),
          SizedBox(height: 8),
          Text('Try different search terms'),
        ],
      ),
    );
  }
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Theme'),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              ref.read(themeModeProvider.notifier).state = selection.first;
            },
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version 1.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Close'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
