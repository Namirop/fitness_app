import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';
import 'package:workout_app/data/models/nutrition/food_model.dart';

class FoodPortionModel extends FoodPortionEntity {
  FoodPortionModel({
    required super.id,
    required super.food,
    required super.quantity,
    required super.totalCalories,
    required super.totalCarbs,
    required super.totalProteins,
    required super.totalFats,
  });

  factory FoodPortionModel.fromEntity(FoodPortionEntity entity) {
    return FoodPortionModel(
      id: entity.id,
      food: entity.food,
      quantity: entity.quantity,
      totalCalories: entity.totalCalories,
      totalCarbs: entity.totalCarbs,
      totalProteins: entity.totalProteins,
      totalFats: entity.totalFats,
    );
  }

  factory FoodPortionModel.fromJson(Map<String, dynamic> json) {
    return FoodPortionModel(
      id: json['id'].toString(),
      food: FoodModel.fromJson(json['food']),
      quantity: (json['quantity'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalProteins: (json['totalProteins'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': FoodModel.fromEntity(food).toJson(),
      'quantity': quantity,
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'totalProteins': totalProteins,
      'totalFats': totalFats,
    };
  }
}
