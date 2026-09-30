import 'nutrition.dart';
class Product  {
  final String id;
  final String productName;
  final String? ingredientsTextEn;
  final List<String>? foodGroupsTags;
  final Nutrition? nutriments;
  final String? imageFrontUrl;
  final String? imageNutritionUrl;
  final String? imageIngredientsUrl;
  
  Product({
    required this.id,
    required this.productName,
    this.ingredientsTextEn,
    this.foodGroupsTags,
    this.nutriments,
    this.imageFrontUrl,
    this.imageNutritionUrl,
    this.imageIngredientsUrl,
  });
  
  Map<String, dynamic> toJson() => {
      'id': id,
      'product_name': productName,
      'ingredients_text_en': ingredientsTextEn,
      'food_groups_tags': foodGroupsTags,
      'nutriments': nutriments?.toJson(),
      'image_front_url': imageFrontUrl,
      'image_nutrition_url': imageNutritionUrl,
      'image_ingredients_url': imageIngredientsUrl,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    // elements nested in 'product' key
    final productData = json['product'] ?? json;
    final name = productData['product_name'];
   
    return Product(
      id: productData['id'] ?? '',
       productName: (name is String && name.trim().isNotEmpty)
        ? name.trim()
        : 'Unknown Product',
      ingredientsTextEn: productData['ingredients_text_en'],
      foodGroupsTags: List<String>.from(productData['food_groups_tags'] ?? []),
      nutriments: productData['nutriments'] != null
          ? Nutrition.fromJson(productData['nutriments'])
          : null,
      imageFrontUrl: productData['image_front_url'],
      imageNutritionUrl: productData['image_nutrition_url'],
      imageIngredientsUrl: productData['image_ingredients_url'],
    );
  }
}