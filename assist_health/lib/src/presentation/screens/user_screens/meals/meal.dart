// meal.dart
class Meal {
  final String name;
  final String weight;
  final int calories;
  final List<Nutrient> nutrients;

  Meal({
    required this.name,
    required this.weight,
    required this.calories,
    required this.nutrients,
  });
}

class Nutrient {
  final String name;
  final String amount;

  Nutrient({
    required this.name,
    required this.amount,
  });
}
