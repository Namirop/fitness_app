import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';

abstract class NutritionEvent {}

class SelectDate extends NutritionEvent {
  final bool isPrevious;
  SelectDate({required this.isPrevious});
}

class LoadTodayNutrition extends NutritionEvent {}

class SearchFood extends NutritionEvent {
  final String query;
  SearchFood({required this.query});
}

class AddFoodToMeal extends NutritionEvent {
  final FoodPortionEntity foodPortion;
  final MealType mealType;
  AddFoodToMeal(this.foodPortion, this.mealType);
}
