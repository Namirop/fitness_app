import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/models/nutrition/meal_model.dart';

class NutritionDayModel extends NutritionDayEntity {
  NutritionDayModel({
    required super.id,
    required super.date,
    required super.totalCalories,
    required super.totalCarbs,
    required super.totalProteins,
    required super.totalFats,
    required super.meals,
  });

  factory NutritionDayModel.fromEntity(NutritionDayEntity entity) {
    return NutritionDayModel(
      id: entity.id,
      date: entity.date,
      totalCalories: entity.totalCalories,
      totalCarbs: entity.totalCarbs,
      totalProteins: entity.totalProteins,
      totalFats: entity.totalFats,
      meals: entity.meals,
    );
  }

  factory NutritionDayModel.fromJson(Map<String, dynamic> json) {
    return NutritionDayModel(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalProteins: (json['totalProteins'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
      meals:
          (json['meals'] as List?)
              ?.map((meal) => MealModel.fromJson(meal))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toUtc().toIso8601String(),
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'totalProteins': totalProteins,
      'totalFats': totalFats,
      'meals': meals
          .map((meal) => MealModel.fromEntity(meal).toJson())
          .toList(),
    };
  }
}
