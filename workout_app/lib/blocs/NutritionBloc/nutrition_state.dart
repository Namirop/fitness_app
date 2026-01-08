import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/nutrition/food_entity.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';

enum SelectedNutritionDateStatus { initial, loading, success, failure }

enum GetFoodListStatus { initial, loading, success, failure }

enum AddFoodPortionStatus { initial, loading, success, failure }

enum DeleteFoodPortionStatus { initial, loading, success, failure }

class NutritionState extends Equatable {
  final NutritionDayEntity currentNutritionDay;
  final SelectedNutritionDateStatus selectedNutritionDateStatus;
  final String? selectedDateErrorString;

  final GetFoodListStatus getFoodListStatus;
  final List<FoodEntity> foodList;
  final String? getFoodListErrorString;

  final AddFoodPortionStatus addFoodPortionStatus;
  final String? addFoodPortionErrorString;
  final String? addFoodPortionSuccessString;

  final DeleteFoodPortionStatus deleteFoodPortionStatus;
  final String? deleteFoodPortionErrorString;
  final String? deleteFoodPortionSuccessString;

  const NutritionState({
    required this.currentNutritionDay,
    this.selectedNutritionDateStatus = SelectedNutritionDateStatus.initial,
    this.selectedDateErrorString,
    this.foodList = const [],
    this.getFoodListStatus = GetFoodListStatus.initial,
    this.getFoodListErrorString,
    this.addFoodPortionStatus = AddFoodPortionStatus.initial,
    this.addFoodPortionErrorString,
    this.addFoodPortionSuccessString,
    this.deleteFoodPortionStatus = DeleteFoodPortionStatus.initial,
    this.deleteFoodPortionErrorString,
    this.deleteFoodPortionSuccessString,
  });

  NutritionState copyWith({
    NutritionDayEntity? currentNutritionDay,
    SelectedNutritionDateStatus? selectedNutritionDateStatus,
    String? selectedDateErrorString,

    GetFoodListStatus? getFoodListStatus,
    List<FoodEntity>? foodList,
    String? getFoodListErrorString,

    AddFoodPortionStatus? addFoodPortionStatus,
    String? addFoodPortionErrorString,
    String? addFoodPortionSuccessString,

    DeleteFoodPortionStatus? deleteFoodPortionStatus,
    String? deleteFoodPortionErrorString,
    String? deleteFoodPortionSuccessString,
  }) {
    return NutritionState(
      currentNutritionDay: currentNutritionDay ?? this.currentNutritionDay,
      selectedNutritionDateStatus:
          selectedNutritionDateStatus ?? this.selectedNutritionDateStatus,
      selectedDateErrorString: selectedDateErrorString,
      foodList: foodList ?? this.foodList,
      getFoodListStatus: getFoodListStatus ?? this.getFoodListStatus,
      getFoodListErrorString: getFoodListErrorString,
      addFoodPortionStatus: addFoodPortionStatus ?? this.addFoodPortionStatus,
      addFoodPortionErrorString: addFoodPortionErrorString,
      addFoodPortionSuccessString: addFoodPortionSuccessString,

      deleteFoodPortionStatus:
          deleteFoodPortionStatus ?? this.deleteFoodPortionStatus,
      deleteFoodPortionErrorString: deleteFoodPortionErrorString,
      deleteFoodPortionSuccessString: deleteFoodPortionSuccessString,
    );
  }

  @override
  List<Object?> get props => [
    currentNutritionDay,
    selectedNutritionDateStatus,
    selectedDateErrorString,
    getFoodListStatus,
    foodList,
    getFoodListErrorString,
    addFoodPortionStatus,
    addFoodPortionErrorString,
    addFoodPortionSuccessString,
    deleteFoodPortionStatus,
    deleteFoodPortionErrorString,
    deleteFoodPortionSuccessString,
  ];
}
