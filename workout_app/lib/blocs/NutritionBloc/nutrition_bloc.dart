import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';
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
      } catch (e) {
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.failure,
            selectedDateErrorString: "Chargement de la journée impossible",
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
      } catch (e) {
        emit(
          state.copyWith(
            selectedNutritionDateStatus: SelectedNutritionDateStatus.failure,
            selectedDateErrorString: "Impossible de séléctionné le jour choisi",
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
      } catch (e) {
        emit(
          state.copyWith(
            getFoodListStatus: GetFoodListStatus.failure,
            getFoodListErrorString: "Recherche impossible",
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

        final indexMeal = currentNutritionDay.meals.indexWhere(
          (meal) => meal.type == event.mealType,
        );

        final currentMeal = currentNutritionDay.meals[indexMeal];

        final updatedFoodPortionsList = [
          ...currentMeal.foodPortions,
          event.foodPortion,
        ];

        final updatedMeal = currentMeal.copyWith(
          foodsPortions: updatedFoodPortionsList,
          totalCalories: updatedFoodPortionsList.fold(
            0.0,
            (sum, fp) => sum! + fp.totalCalories,
          ), // fais l'addition des calories de toutes les portions
          totalCarbs: updatedFoodPortionsList.fold(
            0.0,
            (sum, fp) => sum! + fp.totalCarbs,
          ),
          totalProteins: updatedFoodPortionsList.fold(
            0.0,
            (sum, fp) => sum! + fp.totalProteins,
          ),
          totalFats: updatedFoodPortionsList.fold(
            0.0,
            (sum, fp) => sum! + fp.totalFats,
          ),
        );

        final updatedMealsList = List<MealEntity>.from(
          currentNutritionDay.meals,
        );
        updatedMealsList[indexMeal] = updatedMeal;

        final updatedNutritionDay = currentNutritionDay.copyWith(
          meals: updatedMealsList,
          totalCalories: updatedMealsList.fold(
            0.0,
            (sum, m) => sum! + m.totalCalories,
          ),
          totalCarbs: updatedMealsList.fold(
            0.0,
            (sum, m) => sum! + m.totalCarbs,
          ),
          totalProteins: updatedMealsList.fold(
            0.0,
            (sum, m) => sum! + m.totalProteins,
          ),
          totalFats: updatedMealsList.fold(0.0, (sum, m) => sum! + m.totalFats),
        );

        final receivedNutritionDay = await repository.updateNutritionDay(
          updatedNutritionDay,
        );
        emit(
          state.copyWith(
            currentNutritionDay: receivedNutritionDay,
            addFoodPortionStatus: AddFoodPortionStatus.success,
            addFoodPortionSuccessString: "Aliment ajouté",
            addFoodPortionErrorString: null,
            foodList: List.empty(),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            addFoodPortionStatus: AddFoodPortionStatus.failure,
            addFoodPortionErrorString: "Ajout de la portion impossible",
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
        final foodPortion = event.foodPortion;
        final mealType = event.mealType;
        final currentNutritionDay = state.currentNutritionDay;

        final indexMeal = currentNutritionDay.meals.indexWhere(
          (meal) => meal.type == mealType,
        );

        final currentMeal = currentNutritionDay.meals[indexMeal];

        final updatedFoodPortions = currentMeal.foodPortions
            .where((fp) => fp.id != foodPortion.id)
            .toList();

        final updatedCurrentMeal = currentMeal.copyWith(
          foodsPortions: updatedFoodPortions,
        );

        final updatedMealsList = List<MealEntity>.from(
          currentNutritionDay.meals,
        );

        updatedMealsList[indexMeal] = updatedCurrentMeal;

        final updatedNutritionDay = currentNutritionDay.copyWith(
          meals: updatedMealsList,
        );

        await repository.updateNutritionDay(updatedNutritionDay);
        emit(
          state.copyWith(
            currentNutritionDay: updatedNutritionDay,
            deleteFoodPortionStatus: DeleteFoodPortionStatus.success,
            deleteFoodPortionSuccessString: "Aliment supprimé",
            deleteFoodPortionErrorString: null,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            deleteFoodPortionStatus: DeleteFoodPortionStatus.failure,
            selectedDateErrorString:
                "Erreur lors de la suppression de l'aliment",
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
