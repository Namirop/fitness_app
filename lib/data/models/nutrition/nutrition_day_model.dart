import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/models/nutrition/meal_model.dart';

class NutritionDayModel extends NutritionDayEntity {
  NutritionDayModel({
    required super.id,
    required super.date,
    required super.caloriesTarget,
    required super.totalCalories,
    required super.carbsTarget,
    required super.totalCarbs,
    required super.proteinsTarget,
    required super.totalProteins,
    required super.fatsTarget,
    required super.totalFats,
    required super.meals,
  });

  factory NutritionDayModel.fromEntity(NutritionDayEntity entity) {
    return NutritionDayModel(
      id: entity.id,
      date: entity.date,
      caloriesTarget: entity.caloriesTarget,
      totalCalories: entity.totalCalories,
      carbsTarget: entity.carbsTarget,
      totalCarbs: entity.totalCarbs,
      proteinsTarget: entity.proteinsTarget,
      totalProteins: entity.totalProteins,
      fatsTarget: entity.fatsTarget,
      totalFats: entity.totalFats,
      meals: entity.meals,
    );
  }

  // 'toDouble()' car on force tout les champs double, car coté serveur, 'json.Marshal' peut sérialiser certains float64 en int si leur valeur est entière.
  // Du coup on peut recevoir des int là ou on attends des double, donc parser pour éviter erreurs.
  factory NutritionDayModel.fromJson(Map<String, dynamic> json) {
    return NutritionDayModel(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      caloriesTarget: (json['caloriesTarget'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num)
          .toDouble(), // ✅ Force double
      carbsTarget: (json['carbsTarget'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      proteinsTarget: (json['proteinsTarget'] as num).toDouble(),
      totalProteins: (json['totalProteins'] as num).toDouble(),
      fatsTarget: (json['fatsTarget'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
      // retourne une liste vide si meals et null
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
      'date': date.toUtc().toIso8601String(), // conversion en String
      'caloriesTarget': caloriesTarget,
      'totalCalories': totalCalories,
      'carbsTarget': carbsTarget,
      'totalCarbs': totalCarbs,
      'proteinsTarget': proteinsTarget,
      'totalProtein': totalProteins,
      'fatsTarget': fatsTarget,
      'totalFats': totalFats,
      'meals': meals
          .map((meal) => MealModel.fromEntity(meal).toJson())
          .toList(),
    };
  }
}
