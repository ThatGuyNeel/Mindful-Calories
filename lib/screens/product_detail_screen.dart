import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildProductContent(context),
    );
  }

  Widget _buildProductContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: product.imageFrontUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageFrontUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 64),
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 64),
            ),
          ),

          const SizedBox(height: 24),

          // Product name
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Product info cards
          _buildInfoCards(),

          const SizedBox(height: 24),

          // Nutrition info
          if (product.nutriments != null) ...[
            const Text(
              'Nutritional Information (per 100g)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionTable(),
          ],

          const SizedBox(height: 32),

          // Health indicators
          _buildHealthIndicators(),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            'Brand',
            product.productName.split(' ').first, // Simplified
            Icons.store,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTable() {
    final nutrition = product.nutriments!;
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120),
        1: FixedColumnWidth(80),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _buildNutritionRow('Calories (kcal)', nutrition.energyKcal100g?.toStringAsFixed(0) ?? 'N/A'),
        _buildNutritionRow('Carbohydrates', nutrition.carbohydrates100g?.toStringAsFixed(1) ?? 'N/A'),
        _buildNutritionRow('Proteins', nutrition.proteins100g?.toStringAsFixed(1) ?? 'N/A'),
        _buildNutritionRow('Fats', nutrition.fats100g?.toStringAsFixed(1) ?? 'N/A'),
      ],
    );
  }

  TableRow _buildNutritionRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthIndicators() {
    final nutrition = product.nutriments;
    if (nutrition == null) {
      return const SizedBox.shrink();
    }
    
    final kcal = nutrition.energyKcal100g;
    final protein = nutrition.proteins100g;

    final isHighCalories = kcal != null && kcal > 400;
    final isLowCalories = kcal != null && kcal < 150;
    final isHighFat = nutrition.fats100g != null && nutrition.fats100g! > 20;

    // protein(g) per 100 kcal; stays null if it can't be calculated
    double? proteinPer100Kcal;
    if (kcal != null && protein != null && kcal > 0) {
      proteinPer100Kcal = (protein / kcal) * 100;
    }
    final hasExcellentProtein =
        proteinPer100Kcal != null && proteinPer100Kcal > 10;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Indicators',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (isHighCalories)
              _buildHealthIndicator('High Calories', true, Icons.warning, 'High in calories')
            else if(isLowCalories)
              _buildHealthIndicator('Low Calories', true, Icons.check_circle, 'Low in Calories')
            else 
              _buildHealthIndicator('Normal Calories', false, Icons.thumb_up_sharp, 'Moderate calories'),

            const SizedBox(width: 12),

            if (isHighFat)
              _buildHealthIndicator('High Fat', true, Icons.warning, 'High in fat')
            else
              _buildHealthIndicator('Normal Fat', false, Icons.check_circle, 'Good for fat'),

            const SizedBox(width: 12),

            if (hasExcellentProtein)
              _buildHealthIndicator('High protein source', false, Icons.check_circle, 'Excellent protein to calorie ratio'),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthIndicator(String label, bool isWarning, IconData icon, String tooltip) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWarning ? Colors.red.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isWarning ? Colors.red.shade300 : Colors.green.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isWarning ? Colors.red.shade700 : Colors.green.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isWarning ? Colors.red.shade900 : Colors.green.shade900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    tooltip,
                    style: TextStyle(
                      fontSize: 10,
                      color: isWarning ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  