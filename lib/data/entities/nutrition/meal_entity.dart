import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';

enum MealType { breakfast, lunch, dinner, snack, custom }

extension MealTypExtension on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Petit-déjeuner';
      case MealType.lunch:
        return 'Diner';
      case MealType.dinner:
        return 'Souper';
      case MealType.snack:
        return 'Collation';
      case MealType.custom:
        return 'Custom';
    }
  }
}

class MealEntity {
  final String id;
  final MealType type;
  final String? customName; // Utilisé uniquement si type == MealType.custom
  final List<FoodPortionEntity> foodPortions;
  final double totalCalories;
  final double totalCarbs;
  final double totalProteins;
  final double totalFats;

  MealEntity({
    required this.id,
    required this.type,
    this.customName,
    required this.foodPortions,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProteins,
    required this.totalFats,
  });

  factory MealEntity.empty() {
    return MealEntity(
      id: '',
      type: MealType.breakfast,
      customName: null,
      foodPortions: [],
      totalCalories: 0,
      totalCarbs: 0,
      totalProteins: 0,
      totalFats: 0,
    );
  }

  MealEntity copyWith({
    String? id,
    MealType? type,
    String? customName,
    List<FoodPortionEntity>? foodsPortions,
    double? totalCalories,
    double? totalCarbs,
    double? totalProteins,
    double? totalFats,
  }) {
    return MealEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      foodPortions: foodsPortions ?? foodPortions,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalProteins: totalProteins ?? this.totalProteins,
      totalFats: totalFats ?? this.totalFats,
    );
  }
}
