double? _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null; //for null or any unexpected input
}

class Nutrition  {
  final double? energyKcal100g;
  final double? carbohydrates100g;
  final double? proteins100g;
  final double? fats100g;
  
  Nutrition({
    this.energyKcal100g,
    this.carbohydrates100g,
    this.proteins100g,
    this.fats100g,
  });

  Map<String, dynamic> toJson() => {
      'energy-kcal_100g': energyKcal100g,
      'carbohydrates_100g': carbohydrates100g,
      'proteins_100g': proteins100g,
      'fat_100g': fats100g,
  };
  factory Nutrition.fromJson(Map<String, dynamic> json)  {
    return Nutrition(
      energyKcal100g: _toDouble(json['energy-kcal_100g']),
      carbohydrates100g: _toDouble(json['carbohydrates_100g']),
      proteins100g: _toDouble(json['proteins_100g']),
      fats100g: _toDouble(json['fat_100g']),
    );
  }
}