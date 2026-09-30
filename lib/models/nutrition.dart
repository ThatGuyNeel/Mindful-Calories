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
      energyKcal100g: (json['energy-kcal_100g'] as num?)?.toDouble(),
      carbohydrates100g: (json['carbohydrates_100g'] as num?)?.toDouble(),
      proteins100g: (json['proteins_100g'] as num?)?.toDouble(),
      fats100g: (json['fat_100g'] as num?)?.toDouble(),
    );
  }
}