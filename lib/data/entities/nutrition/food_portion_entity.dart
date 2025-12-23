import 'package:workout_app/data/entities/nutrition/food_entity.dart';

class FoodPortionEntity {
  final String? id;
  final FoodEntity food;
  final double quantity;
  final double totalCalories;
  final double totalCarbs;
  final double totalProteins;
  final double totalFats;

  FoodPortionEntity({
    this.id,
    required this.food,
    required this.quantity,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProteins,
    required this.totalFats,
  });

  factory FoodPortionEntity.empty() {
    return FoodPortionEntity(
      id: '',
      food: FoodEntity.empty(),
      quantity: 0,
      totalCalories: 0,
      totalCarbs: 0,
      totalProteins: 0,
      totalFats: 0,
    );
  }

  FoodPortionEntity copyWith({
    String? id,
    FoodEntity? food,
    double? quantity,
    double? totalCalories,
    double? totalCarbs,
    double? totalProteins,
    double? totalFats,
  }) {
    return FoodPortionEntity(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalProteins: totalProteins ?? this.totalProteins,
      totalFats: totalFats ?? this.totalFats,
    );
  }
}
