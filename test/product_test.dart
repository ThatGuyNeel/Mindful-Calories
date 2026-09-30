import 'package:flutter_test/flutter_test.dart';
import 'package:mhaje_assignment/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a complete product', () {
      final p = Product.fromJson({
        'id': '123',
        'product_name': 'Peanut Butter',
        'ingredients_text_en': 'Peanuts, salt',
        'food_groups_tags': ['en:legumes'],
        'nutriments': {'energy-kcal_100g': 588, 'proteins_100g': 25},
        'image_front_url': 'https://img/front.jpg',
      });

      expect(p.id, '123');
      expect(p.productName, 'Peanut Butter');
      expect(p.ingredientsTextEn, 'Peanuts, salt');
      expect(p.foodGroupsTags, ['en:legumes']);
      expect(p.nutriments, isNotNull);
      expect(p.imageFrontUrl, 'https://img/front.jpg');
    });

    test('empty JSON does not crash and uses safe defaults', () {
      final p = Product.fromJson({});

      expect(p.id, '');
      expect(p.productName, 'Unknown Product');
      expect(p.foodGroupsTags, isEmpty);
      expect(p.nutriments, isNull);
      expect(p.imageFrontUrl, isNull);
    });

    test('explicit nulls are handled', () {
      final p = Product.fromJson({
        'id': null,
        'product_name': null,
        'food_groups_tags': null,
        'nutriments': null,
      });

      expect(p.productName, 'Unknown Product');
      expect(p.foodGroupsTags, isEmpty);
      expect(p.nutriments, isNull);
    });

    test('numbers sent as strings inside nutriments do not throw', () {
      // when the API sometimes sends "9.5" instead of 9.5
      expect(
        () => Product.fromJson({
          'nutriments': {'proteins_100g': '9.5', 'energy-kcal_100g': '400'},
        }),
        returnsNormally,
      );
    });

    //when the product_name is missing
    test('blank product_name falls back to Unknown Product', () {
      // for when the API returns "" rather than omitting the field.
      final p = Product.fromJson({'product_name': ''});
      expect(p.productName, 'Unknown Product');
    });
  });
}