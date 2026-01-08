import 'package:workout_app/core/enums/meal_type.dart';
import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';

class MealEntity {
  final String id;
  final MealType type;
  final String? customName;
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

  String get formattedCalories => totalCalories.round().toString();
  String get formattedCarbs => _formatMacro(totalCarbs);
  String get formattedProteins => _formatMacro(totalProteins);
  String get formattedFats => _formatMacro(totalFats);

  static String _formatMacro(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
