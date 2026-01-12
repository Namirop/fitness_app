import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/core/errors/api_exception.dart';
import 'package:workout_app/data/dto/add_food_portion_dto.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/repositories/nutrition_repository.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository repository;
  NutritionBloc({required this.repository})
    : super(NutritionState(currentNutritionDay: NutritionDayEntity.empty())) {
    on<LoadDailyNutrition>((event, emit) async {
      emit(
        state.copyWith(
          selectedNutritionDateStatus: SelectedNutritionDateStatus.loading,
          selectedDateErrorString: null,
        ),
      );
      final today = DateTime.now();
      try {
        final formattedDate = DateFormat('yyyy-MM-dd').format(today);
        final nutritionDay = await repository.getNutritionDay(formattedDate);
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.success,
            currentNutritionDay: nutritionDay,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.failure,
            selectedDateErrorString: e.toString(),
          ),
        );
      }
    });

    on<SelectDate>((event, emit) async {
      emit(
        state.copyWith(
          selectedNutritionDateStatus: SelectedNutritionDateStatus.loading,
          selectedDateErrorString: null,
        ),
      );
      final currentDate = event.isPrevious
          ? state.currentNutritionDay.date.subtract(Duration(days: 1))
          : state.currentNutritionDay.date.add(Duration(days: 1));
      try {
        final formatedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        final nutritionDay = await repository.getNutritionDay(formatedDate);
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.success,
            currentNutritionDay: nutritionDay,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.failure,
            selectedDateErrorString: e.toString(),
          ),
        );
      }
    });

    on<SearchFood>((event, emit) async {
      emit(
        state.copyWith(
          getFoodListStatus: GetFoodListStatus.loading,
          getFoodListErrorString: null,
        ),
      );
      try {
        final query = event.query;
        final foods = await repository.getFoodList(query);
        emit(
          state.copyWith(
            getFoodListStatus: GetFoodListStatus.success,
            foodList: foods,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            getFoodListStatus: GetFoodListStatus.failure,
            getFoodListErrorString: e.toString(),
          ),
        );
      }
    });

    on<ClearFoodList>((event, emit) {
      emit(
        state.copyWith(
          getFoodListStatus: GetFoodListStatus.success,
          foodList: List.empty(),
        ),
      );
    });

    on<AddFoodPortionToMeal>((event, emit) async {
      emit(
        state.copyWith(
          addFoodPortionStatus: AddFoodPortionStatus.loading,
          addFoodPortionSuccessString: null,
          addFoodPortionErrorString: null,
        ),
      );
      try {
        final currentNutritionDay = state.currentNutritionDay;
        final nutritionDayId = currentNutritionDay.id;

        final indexMeal = currentNutritionDay.meals.indexWhere(
          (meal) => meal.type == event.mealType,
        );

        final currentMeal = currentNutritionDay.meals[indexMeal];
        final mealId = currentMeal.id;

        final dto = AddFoodPortionDto(
          nutritionDayId: nutritionDayId,
          mealId: mealId,
          foodId: event.foodId,
          quantity: event.quantity,
        );

        final updatedNutritionDay = await repository.addFoodPortion(dto);

        emit(
          state.copyWith(
            currentNutritionDay: updatedNutritionDay,
            addFoodPortionStatus: AddFoodPortionStatus.success,
            addFoodPortionSuccessString: "Aliment ajouté",
            addFoodPortionErrorString: null,
            foodList: List.empty(),
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            addFoodPortionStatus: AddFoodPortionStatus.failure,
            addFoodPortionErrorString: e.toString(),
            addFoodPortionSuccessString: null,
          ),
        );
      }
    });

    on<DeleteFoodPortionFromMeal>((event, emit) async {
      emit(
        state.copyWith(
          deleteFoodPortionStatus: DeleteFoodPortionStatus.loading,
          deleteFoodPortionErrorString: null,
          deleteFoodPortionSuccessString: null,
        ),
      );
      try {
        final updatedNutritionDay = await repository.deleteFoodPortion(
          event.foodPortionId,
        );
        emit(
          state.copyWith(
            currentNutritionDay: updatedNutritionDay,
            deleteFoodPortionStatus: DeleteFoodPortionStatus.success,
            deleteFoodPortionSuccessString: "Aliment supprimé",
            deleteFoodPortionErrorString: null,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            deleteFoodPortionStatus: DeleteFoodPortionStatus.failure,
            deleteFoodPortionErrorString: e.toString(),
            deleteFoodPortionSuccessString: null,
          ),
        );
      }
    });

    on<ResetAddFoodStatus>((event, emit) {
      emit(
        state.copyWith(
          addFoodPortionStatus: AddFoodPortionStatus.initial,
          addFoodPortionSuccessString: null,
          addFoodPortionErrorString: null,
        ),
      );
    });

    on<ResetDeleteFoodStatus>((event, emit) {
      emit(
        state.copyWith(
          deleteFoodPortionStatus: DeleteFoodPortionStatus.initial,
          deleteFoodPortionSuccessString: null,
          selectedDateErrorString: null,
        ),
      );
    });
  }
}
