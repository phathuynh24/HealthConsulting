class Meal {
  final String name;
  final double weight;
  final double calories;
  final List<Nutrition> nutrients;
  late final List<Ingredient> ingredients;
  final List<dynamic> warnings;

  Meal({
    required this.name,
    required this.weight,
    required this.calories,
    required this.nutrients,
    required this.ingredients,
    required this.warnings,
  });

  // Phương thức fromMap
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['customName'] ?? map['originalName'],
      weight: (map['weight'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
      nutrients: (map['nutrients'] as List<dynamic>?)
              ?.map((item) => Nutrition.fromMap(item))
              .toList() ??
          [],
      ingredients: (map['ingredients'] as List<dynamic>?)
              ?.map((item) => Ingredient.fromMap(item))
              .toList() ??
          [],
      warnings: map['warnings'] ?? [],
    );
  }
}

class Ingredient {
  final String name_en;
  final String name_vi;
  final double quantity;
  final double calories;

  Ingredient({
    required this.name_en,
    required this.name_vi,
    required this.quantity,
    required this.calories,
  });

  // Phương thức fromMap
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name_en: map['name_en'] ?? '',
      name_vi: map['name_vi'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
    );
  }
}

class Nutrition {
  final String name;
  final double amount;

  Nutrition({
    required this.name,
    required this.amount,
  });

  // Phương thức fromMap
  factory Nutrition.fromMap(Map<String, dynamic> map) {
    return Nutrition(
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }
}
