class MealItem {
  final String id;        // backend _id
  final String name;
  final double calories;
  final double quantity; // ✅ allow decimals
  final String unit;     // cup / roti / glass / estimated
  final double grams;

  MealItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.quantity,
    required this.unit,
    required this.grams,
  });

  // ---------- JSON (LOCAL STORAGE) ----------
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'quantity': quantity,
    'unit': unit,
    'grams': grams,
  };

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'],
      name: json['name'],
      calories: (json['calories'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] ?? 'estimated',
      grams: (json['grams'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
