class FoodEntity {
  final String id;
  final String name;
  final double referenceQuantity;
  final String referenceUnit;
  final double calories;
  final double carbs;
  final double proteins;
  final double fats;
  final bool isFavorite;
  final String store;

  FoodEntity({
    required this.id,
    required this.name,
    required this.referenceQuantity,
    required this.referenceUnit,
    required this.calories,
    required this.carbs,
    required this.proteins,
    required this.fats,
    required this.isFavorite,
    required this.store,
  });

  FoodEntity copyWith({
    String? id,
    String? name,
    double? referenceQuantity,
    String? referenceUnit,
    double? calories,
    double? carbs,
    double? proteins,
    double? fats,
    bool? isFavorite,
    String? store,
  }) {
    return FoodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      referenceQuantity: referenceQuantity ?? this.referenceQuantity,
      referenceUnit: referenceUnit ?? this.referenceUnit,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      isFavorite: isFavorite ?? this.isFavorite,
      store: store ?? this.store,
    );
  }

  String get primaryStore {
    if (store.isEmpty) return '/';
    return store.split(',').first;
  }

  String get formattedCalories => calories.round().toString();
  String get formattedCarbs => _formatMacro(carbs);
  String get formattedProteins => _formatMacro(proteins);
  String get formattedFats => _formatMacro(fats);
  String get formattedQuantity => _formatMacro(referenceQuantity);

  static String _formatMacro(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
