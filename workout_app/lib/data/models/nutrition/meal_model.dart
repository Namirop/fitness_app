import 'package:workout_app/core/enums/meal_type.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';
import 'package:workout_app/data/models/nutrition/food_portion_model.dart';

class MealModel extends MealEntity {
  MealModel({
    required super.id,
    required super.type,
    required super.customName,
    required super.foodPortions,
    required super.totalCalories,
    required super.totalCarbs,
    required super.totalProteins,
    required super.totalFats,
  });

  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      type: entity.type,
      customName: entity.customName,
      foodPortions: entity.foodPortions,
      totalCalories: entity.totalCalories,
      totalCarbs: entity.totalCarbs,
      totalProteins: entity.totalProteins,
      totalFats: entity.totalFats,
    );
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'].toString(),
      type: MealType.values.firstWhere((e) => e.name == json['type']),
      customName: json['customName'].toString(),
      foodPortions:
          (json['foodPortions'] as List?)
              ?.map((fp) => FoodPortionModel.fromJson(fp))
              .toList() ??
          [],
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalProteins: (json['totalProteins'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'customName': customName,
      'foodPortions': foodPortions
          .map((food) => FoodPortionModel.fromEntity(food).toJson())
          .toList(),
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'totalProteins': totalProteins,
      'totalFats': totalFats,
    };
  }
}
