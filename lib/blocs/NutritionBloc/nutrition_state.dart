import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/nutrition/food_entity.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';

enum SelectDateStatus { initial, loading, success, failure }

enum GetFoodListStatus { initial, loading, success, failure }

enum AddFoodPortionStatus { initial, loading, success, failure }

class NutritionState extends Equatable {
  final NutritionDayEntity currentNutritionDay;
  final SelectDateStatus selectDateStatus;
  final String? selectedDateErrorString;

  final List<FoodEntity> foodList;
  final GetFoodListStatus getFoodListStatus;
  final String? getFoodListErrorString;

  final AddFoodPortionStatus addFoodPortionStatus;
  final String? addFoodPortionErrorString;
  final String? addFoodPortionSuccessString;

  const NutritionState({
    required this.currentNutritionDay,
    this.selectDateStatus = SelectDateStatus.initial,
    this.selectedDateErrorString,
    this.foodList = const [],
    this.getFoodListStatus = GetFoodListStatus.initial,
    this.getFoodListErrorString,
    this.addFoodPortionStatus = AddFoodPortionStatus.initial,
    this.addFoodPortionErrorString,
    this.addFoodPortionSuccessString,
  });

  NutritionState copyWith({
    NutritionDayEntity? currentNutritionDay,
    SelectDateStatus? selectDateStatus,
    String? selectedDateErrorString,

    List<FoodEntity>? foodList,
    GetFoodListStatus? getFoodListStatus,
    String? getFoodListErrorString,

    AddFoodPortionStatus? addFoodPortionStatus,
    String? addFoodPortionErrorString,
    String? addFoodPortionSuccessString,
  }) {
    return NutritionState(
      currentNutritionDay: currentNutritionDay ?? this.currentNutritionDay,
      selectDateStatus: selectDateStatus ?? this.selectDateStatus,
      selectedDateErrorString:
          selectedDateErrorString ?? this.selectedDateErrorString,
      foodList: foodList ?? this.foodList,
      getFoodListStatus: getFoodListStatus ?? this.getFoodListStatus,
      getFoodListErrorString:
          getFoodListErrorString ?? this.getFoodListErrorString,
      addFoodPortionStatus: addFoodPortionStatus ?? this.addFoodPortionStatus,
      addFoodPortionErrorString:
          addFoodPortionErrorString ?? this.addFoodPortionErrorString,
      addFoodPortionSuccessString:
          addFoodPortionSuccessString ?? this.addFoodPortionSuccessString,
    );
  }

  @override
  List<Object?> get props => [
    currentNutritionDay,
    selectDateStatus,
    selectedDateErrorString,
    foodList,
    getFoodListStatus,
    getFoodListErrorString,
    addFoodPortionStatus,
    addFoodPortionErrorString,
    addFoodPortionSuccessString,
  ];
}
