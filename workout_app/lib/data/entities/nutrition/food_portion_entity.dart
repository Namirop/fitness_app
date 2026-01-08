import 'package:workout_app/data/entities/nutrition/food_entity.dart';

class FoodPortionEntity {
  final String id;
  final FoodEntity food;
  final double quantity;
  final double totalCalories;
  final double totalCarbs;
  final double totalProteins;
  final double totalFats;

  FoodPortionEntity({
    required this.id,
    required this.food,
    required this.quantity,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProteins,
    required this.totalFats,
  });

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

  String get formattedCarbs => _formatMacro(totalCarbs);
  String get formattedProteins => _formatMacro(totalProteins);
  String get formattedFats => _formatMacro(totalFats);
  String get formattedCalories => totalCalories.round().toString();

  static String _formatMacro(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
