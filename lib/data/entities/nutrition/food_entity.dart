class FoodEntity {
  final String id;
  final String name;
  final double referenceQuantity; // 100 (grammes) ou 1 (pièce/unité)
  final String referenceUnit; // "g", "ml", "unité", "pièce"
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

  factory FoodEntity.empty() {
    return FoodEntity(
      id: '',
      name: '',
      referenceQuantity: 0,
      referenceUnit: '',
      calories: 0,
      carbs: 0,
      proteins: 0,
      fats: 0,
      isFavorite: false,
      store: '',
    );
  }

  String get primaryStore {
    if (store.isEmpty) return '/';
    return store.split(',').first;
  }

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
}
