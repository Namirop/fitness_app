import 'package:workout_app/data/entities/nutrition/meal_entity.dart';

class NutritionDayEntity {
  final String id;
  final DateTime date;
  final double caloriesTarget;
  final double totalCalories;
  final double carbsTarget;
  final double totalCarbs;
  final double proteinsTarget;
  final double totalProteins;
  final double fatsTarget;
  final double totalFats;
  final List<MealEntity> meals;

  NutritionDayEntity({
    required this.id,
    required this.date,
    required this.caloriesTarget,
    required this.totalCalories,
    required this.carbsTarget,
    required this.totalCarbs,
    required this.proteinsTarget,
    required this.totalProteins,
    required this.fatsTarget,
    required this.totalFats,
    required this.meals,
  });

  factory NutritionDayEntity.empty() {
    return NutritionDayEntity(
      id: '',
      date: DateTime.now(),
      caloriesTarget: 0,
      totalCalories: 0,
      carbsTarget: 0,
      totalCarbs: 0,
      proteinsTarget: 0,
      totalProteins: 0,
      fatsTarget: 0,
      totalFats: 0,
      meals: [
        MealEntity.empty().copyWith(type: MealType.breakfast),
        MealEntity.empty().copyWith(type: MealType.lunch),
        MealEntity.empty().copyWith(type: MealType.dinner),
        MealEntity.empty().copyWith(type: MealType.snack),
      ],
    );
  }

  NutritionDayEntity copyWith({
    String? id,
    DateTime? date,
    double? caloriesTarget,
    double? totalCalories,
    double? carbsTarget,
    double? totalCarbs,
    double? proteinsTarget,
    double? totalProteins,
    double? fatsTarget,
    double? totalFats,
    List<MealEntity>? meals,
  }) {
    return NutritionDayEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      totalCalories: totalCalories ?? this.totalCalories,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      proteinsTarget: proteinsTarget ?? this.proteinsTarget,
      totalProteins: totalProteins ?? this.totalProteins,
      fatsTarget: fatsTarget ?? this.fatsTarget,
      totalFats: totalFats ?? this.totalFats,
      meals: meals ?? this.meals,
    );
  }
}
