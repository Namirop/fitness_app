import 'package:workout_app/data/entities/nutrition/food_entity.dart';

class FoodModel extends FoodEntity {
  FoodModel({
    required super.id,
    required super.name,
    required super.referenceQuantity,
    required super.referenceUnit,
    required super.calories,
    required super.carbs,
    required super.proteins,
    required super.fats,
    required super.isFavorite,
    required super.store,
  });

  factory FoodModel.fromEntity(FoodEntity entity) {
    return FoodModel(
      id: entity.id,
      name: entity.name,
      referenceQuantity: entity.referenceQuantity,
      referenceUnit: entity.referenceUnit,
      calories: entity.calories,
      carbs: entity.carbs,
      proteins: entity.proteins,
      fats: entity.fats,
      isFavorite: entity.isFavorite,
      store: entity.store,
    );
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      referenceQuantity: (json['referenceQuantity'] as num).toDouble(),
      referenceUnit: json['referenceUnit'].toString(),
      calories: (json['calories'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      store: json['store'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'referenceQuantity': referenceQuantity,
      'referenceUnit': referenceUnit,
      'calories': calories,
      'carbs': carbs,
      'proteins': proteins,
      'fats': fats,
      'isFavorite': isFavorite,
      'store': store,
    };
  }
}
