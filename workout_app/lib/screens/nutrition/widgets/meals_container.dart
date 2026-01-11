import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/enums/meal_type.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';
import 'package:workout_app/screens/nutrition/food_search_screen.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class MealsContainer extends StatefulWidget {
  final List<MealEntity> meals;
  final bool isLoading;
  const MealsContainer({
    super.key,
    required this.meals,
    required this.isLoading,
  });

  @override
  State<MealsContainer> createState() => _MealsContainerState();
}

class _MealsContainerState extends State<MealsContainer> {
  int selectedMealTypeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            onPageChanged: (value) {
              setState(() {
                selectedMealTypeIndex = value;
              });
            },
            itemCount: widget.meals.length,
            itemBuilder: (context, index) {
              return _mealContainer(widget.meals[index]);
            },
          ),
        ),
        _mealsContainerBulletsGenerator(),
      ],
    );
  }

  Widget _mealContainer(MealEntity meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.widgetBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(width: 2, color: AppColors.containerBorderColor),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 235,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIcon(
                          icon: Icon(meal.type.icon, size: 18),
                          topPadding: 3,
                          color: Colors.transparent,
                          size: 17,
                        ),
                        SizedBox(width: 10),
                        Text(meal.type.label, style: TextStyle(fontSize: 18)),
                        Spacer(),
                        Icon(Icons.menu, size: 18),
                      ],
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: meal.foodPortions.isEmpty
                          ? Center(
                              child: CustomIcon(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FoodSearchScreen(mealType: meal.type),
                                    ),
                                  );
                                },
                                size: 60,
                                icon: Icon(Icons.add, size: 40),
                              ),
                            )
                          : _buildMealItem(meal),
                    ),
                    Divider(),
                    _buildMacrosMealInfo(meal),
                    if (meal.foodPortions.isNotEmpty) ...[
                      SizedBox(height: 10),
                      _buildAddButton(meal.type),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMealItem(MealEntity meal) {
    return ListView.builder(
      itemCount: meal.foodPortions.length,
      itemBuilder: (context, index) {
        final foodPortion = meal.foodPortions[index];
        return Column(
          children: [
            Dismissible(
              background: Container(
                color: const Color.fromARGB(172, 244, 67, 54),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(right: 20, top: 5),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                context.read<NutritionBloc>().add(
                  DeleteFoodPortionFromMeal(foodPortion.id),
                );
              },
              key: Key(foodPortion.id.toString()),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            foodPortion.food.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          foodPortion.formattedCalories,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          foodPortion.food.primaryStore,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(131, 0, 0, 0),
                          ),
                        ),
                        Text(
                          "G: ${foodPortion.formattedCarbs} P: ${foodPortion.formattedProteins} L: ${foodPortion.formattedFats}",
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }

  Widget _buildMacrosMealInfo(MealEntity meal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          child: Center(
            child: Text(
              "G: ${meal.formattedCarbs}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        SizedBox(
          child: Center(
            child: Text(
              "P: ${meal.formattedProteins}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        SizedBox(
          child: Center(
            child: Text(
              "L: ${meal.formattedFats}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(MealType mealType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodSearchScreen(mealType: mealType),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color.fromARGB(255, 68, 62, 62),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 20, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Ajouter un aliment",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealsContainerBulletsGenerator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          MealType.values.length - 2,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: index == selectedMealTypeIndex
                  ? const Color.fromARGB(150, 0, 0, 0)
                  : const Color.fromARGB(166, 222, 216, 216),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
