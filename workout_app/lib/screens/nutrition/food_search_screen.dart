import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/enums/meal_type.dart';
import 'package:workout_app/core/enums/search_food_section_type.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';
import 'package:workout_app/data/entities/nutrition/food_entity.dart';
import 'package:workout_app/data/entities/nutrition/food_portion_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class FoodSearchScreen extends StatefulWidget {
  final MealType mealType;
  const FoodSearchScreen({super.key, required this.mealType});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  int selectedSectionIndex = 0;
  final _searchController = TextEditingController();

  Timer? _debounceFoodSearch;
  List<Widget> get sections => [
    _librarySection(),
    _recipesSection(),
    _favoriteSection(),
  ];

  @override
  void dispose() {
    _debounceFoodSearch?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.screenBackground),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 10, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(127, 248, 249, 248),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.small,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 4, 12, 4),
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      cursorColor: Colors.black,
                                      cursorWidth: 1.0,
                                      cursorHeight: 18.0,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-ZÀ-ÿ\s]'),
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Rechercher',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                      onChanged: (value) {
                                        _debounceFoodSearch?.cancel();
                                        _debounceFoodSearch = Timer(
                                          const Duration(milliseconds: 500),
                                          () {
                                            context.read<NutritionBloc>().add(
                                              SearchFood(query: value),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  CustomIcon(
                                    onTap: () {
                                      setState(() {
                                        _searchController.clear();
                                        context.read<NutritionBloc>().add(
                                          ClearFoodList(),
                                        );
                                      });
                                    },
                                    size: 25,
                                    icon: FaIcon(
                                      FontAwesomeIcons.remove,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          CustomIcon(
                            onTap: () {},
                            color: Colors.transparent,
                            icon: FaIcon(Icons.barcode_reader, size: 22),
                          ),
                          Spacer(),
                          CustomIcon(
                            onTap: () {
                              context.read<NutritionBloc>().add(
                                ClearFoodList(),
                              );
                              Navigator.pop(context);
                            },
                            color: Colors.transparent,
                            icon: FaIcon(FontAwesomeIcons.remove, size: 22),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: List.generate(SectionName.values.length, (
                          index,
                        ) {
                          final section = SectionName.values[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSectionIndex = index;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                color: index == selectedSectionIndex
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: index == selectedSectionIndex
                                    ? BorderRadius.circular(8)
                                    : BorderRadius.circular(0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  0,
                                  10,
                                  0,
                                ),
                                child: Center(
                                  child: Transform.scale(
                                    scaleY: 0.9,
                                    child: Text(
                                      section.label,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppBorderRadius.large),
                        topRight: Radius.circular(AppBorderRadius.large),
                      ),
                      color: const Color.fromARGB(141, 255, 255, 255),
                    ),
                    child: sections[selectedSectionIndex],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _favoriteSection() {
    return Center(child: Text("Favoris"));
  }

  Widget _recipesSection() {
    return Center(child: Text("Recettes"));
  }

  Widget _librarySection() {
    return BlocBuilder<NutritionBloc, NutritionState>(
      buildWhen: (previous, current) =>
          previous.getFoodListStatus != current.getFoodListStatus,
      builder: (context, state) {
        if (state.getFoodListStatus == GetFoodListStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color.fromARGB(255, 189, 60, 51),
            ),
          );
        }
        if (state.getFoodListStatus == GetFoodListStatus.success) {
          return state.foodList.isEmpty
              ? Center(child: Text("Rechercher un aliment"))
              : ListView.builder(
                  itemCount: state.foodList.length,
                  itemBuilder: (context, index) {
                    final food = state.foodList[index];
                    return GestureDetector(
                      onTap: () async {
                        final parentContext = context;
                        final validation = await _showPortionDialog(food);
                        if (validation == true) {
                          parentContext.read<NavigationCubit>().goToPage(2);
                        }
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            food.primaryStore,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "${food.referenceQuantity}${food.referenceUnit}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Spacer(),
                              Column(
                                children: [
                                  Text(food.formattedCalories),
                                  SizedBox(height: 5),
                                  Text(
                                    "G: ${food.formattedCarbs} P: ${food.formattedProteins} L: ${food.formattedFats}",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        }
        if (state.getFoodListStatus == GetFoodListStatus.failure) {
          return Center(child: Text(state.getFoodListErrorString ?? 'Erreur'));
        }

        return Center(child: CircularProgressIndicator(color: Colors.white38));
      },
    );
  }

  Future<bool?> _showPortionDialog(FoodEntity food) async {
    double totalCalories = food.calories;
    double totalCarbs = food.carbs;
    double totalFats = food.fats;
    double totalProteins = food.proteins;
    double quantity = food.referenceQuantity;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      // StatefulBuilder because the context of the dialogBox is different, otherwise do not rebuild after setState
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Creating a temporary FoodPortionEntity to use getters
          final tempPortion = FoodPortionEntity(
            id: food.id,
            food: food,
            quantity: quantity,
            totalCalories: totalCalories,
            totalCarbs: totalCarbs,
            totalProteins: totalProteins,
            totalFats: totalFats,
          );
          return AlertDialog(
            title: Text("${food.name} - ${food.primaryStore}"),
            content: SizedBox(
              height: 80,
              child: Column(
                children: [
                  Text(
                    "G: ${tempPortion.formattedCarbs} P: ${tempPortion.formattedProteins} L: ${tempPortion.formattedFats} - ${tempPortion.formattedCalories}kcal",
                    maxLines: 1,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 248, 249, 248),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 15, 0),
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                cursorColor: Colors.black,
                                cursorWidth: 1.0,
                                cursorHeight: 20.0,
                                decoration: InputDecoration(
                                  hintText: '${food.referenceQuantity}',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                onChanged: (value) {
                                  final parsedQuantity = double.tryParse(value);
                                  if (parsedQuantity == null) return;
                                  setDialogState(() {
                                    quantity = parsedQuantity;
                                    totalCalories =
                                        food.calories *
                                        quantity /
                                        food.referenceQuantity;
                                    totalCarbs =
                                        food.carbs *
                                        quantity /
                                        food.referenceQuantity;
                                    totalProteins =
                                        food.proteins *
                                        quantity /
                                        food.referenceQuantity;
                                    totalFats =
                                        food.fats *
                                        quantity /
                                        food.referenceQuantity;
                                  });
                                },
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            food.referenceUnit,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<NutritionBloc>().add(
                    AddFoodPortionToMeal(
                      FoodPortionEntity(
                        id: '',
                        food: food,
                        quantity: quantity,
                        totalCalories: totalCalories,
                        totalCarbs: totalCarbs,
                        totalProteins: totalProteins,
                        totalFats: totalFats,
                      ),
                      widget.mealType,
                    ),
                  );
                  Navigator.pop(context, true);
                  Navigator.pop(context);
                },
                child: const Text('Valider la portion'),
              ),
            ],
          );
        },
      ),
    );
  }
}
