import 'package:workout_app/core/enums/meal_type.dart';
import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';

abstract class NutritionEvent {}

class LoadDailyNutrition extends NutritionEvent {}

class SelectDate extends NutritionEvent {
  final bool isPrevious;
  SelectDate({required this.isPrevious});
}

class SearchFood extends NutritionEvent {
  final String query;
  SearchFood({required this.query});
}

class ClearFoodList extends NutritionEvent {}

class AddFoodPortionToMeal extends NutritionEvent {
  final FoodPortionEntity foodPortion;
  final MealType mealType;
  AddFoodPortionToMeal(this.foodPortion, this.mealType);
}

class DeleteFoodPortionFromMeal extends NutritionEvent {
  final FoodPortionEntity foodPortion;
  final MealType mealType;
  DeleteFoodPortionFromMeal(this.foodPortion, this.mealType);
}

class ResetAddFoodStatus extends NutritionEvent {}

class ResetDeleteFoodStatus extends NutritionEvent {}
