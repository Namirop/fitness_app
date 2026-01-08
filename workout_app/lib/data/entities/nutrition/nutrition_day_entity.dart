import 'package:workout_app/data/entities/nutrition/meal_entity.dart';

class NutritionDayEntity {
  final String id;
  final DateTime date;
  final double totalCalories;
  final double totalCarbs;
  final double totalProteins;
  final double totalFats;
  final List<MealEntity> meals;

  NutritionDayEntity({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProteins,
    required this.totalFats,
    required this.meals,
  });

  factory NutritionDayEntity.empty() {
    return NutritionDayEntity(
      id: '',
      date: DateTime.now(),
      totalCalories: 0.0,
      totalCarbs: 0.0,
      totalProteins: 0.0,
      totalFats: 0.0,
      meals: [],
    );
  }

  NutritionDayEntity copyWith({
    String? id,
    DateTime? date,
    double? totalCalories,
    double? totalCarbs,
    double? totalProteins,
    double? totalFats,
    List<MealEntity>? meals,
  }) {
    return NutritionDayEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalProteins: totalProteins ?? this.totalProteins,
      totalFats: totalFats ?? this.totalFats,
      meals: meals ?? this.meals,
    );
  }

  String get formattedTotalCalories => totalCalories.round().toString();
  String get formattedTotalCarbs => _formatMacro(totalCarbs);
  String get formattedTotalProteins => _formatMacro(totalProteins);
  String get formattedTotalFats => _formatMacro(totalFats);
  static String _formatMacro(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
