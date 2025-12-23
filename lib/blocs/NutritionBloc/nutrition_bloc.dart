import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/models/nutrition/food_model.dart';
import 'package:workout_app/data/repositories/nutrition_repository.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository repository;
  NutritionBloc({required this.repository})
    : super(NutritionState(currentNutritionDay: NutritionDayEntity.empty())) {
    on<LoadTodayNutrition>((event, emit) async {
      emit(state.copyWith(selectDateStatus: SelectDateStatus.loading));
      try {
        final previousNutritionDay = state.currentNutritionDay;
        final today = DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd').format(today);
        final nutritionDay = await repository.getNutritionDay(formattedDate);

        emit(
          state.copyWith(
            selectDateStatus: SelectDateStatus.success,
            currentNutritionDay:
                nutritionDay ??
                NutritionDayEntity.empty().copyWith(date: today),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            selectDateStatus: SelectDateStatus.failure,
            selectedDateErrorString: e.toString(),
            currentNutritionDay: NutritionDayEntity.empty().copyWith(
              date: DateTime.now(),
            ),
          ),
        );
      }
    });
    on<SelectDate>((event, emit) async {
      final currentDate = event.isPrevious
          ? state.currentNutritionDay.date.subtract(Duration(days: 1))
          : state.currentNutritionDay.date.add(Duration(days: 1));
      try {
        emit(state.copyWith(selectDateStatus: SelectDateStatus.loading));

        // On transforme DateTime en string YYYY-MM-DD
        final formatedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        // On vérifie que pour la date donné, ya un nutritionDay dans la db.
        final nutritionDay = await repository.getNutritionDay(formatedDate);

        // Si oui, on retourne la date donnée et son nutritionDay.
        // Si non, on retourne la date donné, ainsi qu'un nutritionDay.empty() => rien en DB
        // Ensuite, au premier update d'un empty(), ca mettra à jour dans la db et donc par la suite on pourra retourner le nutritionDay.
        emit(
          state.copyWith(
            selectDateStatus: SelectDateStatus.success,
            currentNutritionDay:
                nutritionDay ??
                NutritionDayEntity.empty().copyWith(date: currentDate),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            selectDateStatus: SelectDateStatus.failure,
            selectedDateErrorString: e.toString(),
            currentNutritionDay: NutritionDayEntity.empty().copyWith(
              date: currentDate,
            ),
          ),
        );
      }
    });

    on<SearchFood>((event, emit) async {
      try {
        emit(state.copyWith(getFoodListStatus: GetFoodListStatus.loading));
        final query = event.query;
        final List<FoodModel> foodList = await repository.getFoodList(query);
        emit(
          state.copyWith(
            getFoodListStatus: GetFoodListStatus.success,
            foodList: foodList,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            getFoodListStatus: GetFoodListStatus.failure,
            getFoodListErrorString: e.toString(),
          ),
        );
      }
    });

    on<AddFoodToMeal>((event, emit) async {
      try {
        emit(
          state.copyWith(addFoodPortionStatus: AddFoodPortionStatus.loading),
        );
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
        // nutritionDay crée avec ID générés coté serveur.
        // c'est un standard/pattern, car ca nous permettra de modifier correctmennt les informations de ce jour, meme si on aurait pu utiliser autre chose (la date par exemple, mais ce n'est pas du tout standard)
        final createdNutritionDay = await repository.saveNutritionDay(
          updatedNutritionDay,
        );
        emit(
          state.copyWith(
            currentNutritionDay: createdNutritionDay,
            addFoodPortionStatus: AddFoodPortionStatus.success,
            addFoodPortionSuccessString: "Aliment correctement ajouté",
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            addFoodPortionStatus: AddFoodPortionStatus.failure,
            addFoodPortionErrorString: e.toString(),
          ),
        );
      }
    });
  }
}
