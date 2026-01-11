import 'package:workout_app/core/enums/meal_type.dart';

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
  final double quantity;
  final String foodId;
  final MealType mealType;
  AddFoodPortionToMeal(this.quantity, this.foodId, this.mealType);
}

class DeleteFoodPortionFromMeal extends NutritionEvent {
  final String foodPortionId;
  DeleteFoodPortionFromMeal(this.foodPortionId);
}

class ResetAddFoodStatus extends NutritionEvent {}

class ResetDeleteFoodStatus extends NutritionEvent {}
