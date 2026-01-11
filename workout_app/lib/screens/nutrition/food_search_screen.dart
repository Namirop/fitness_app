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
import 'package:workout_app/screens/nutrition/widgets/food_portion_dialog.dart';
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
                      _buildTopUIPage(),
                      SizedBox(height: 10),
                      _buildLabelsSection(),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                      child: sections[selectedSectionIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopUIPage() {
    return Row(
      children: [
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: const Color.fromARGB(127, 248, 249, 248),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 4, 12, 4),
            child: Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
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
                      style: TextStyle(fontSize: 20, color: Colors.black),
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
                ),
                CustomIcon(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      context.read<NutritionBloc>().add(ClearFoodList());
                    });
                  },
                  size: 25,
                  icon: FaIcon(FontAwesomeIcons.remove, size: 12),
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
            context.read<NutritionBloc>().add(ClearFoodList());
            Navigator.pop(context);
          },
          color: Colors.transparent,
          icon: FaIcon(FontAwesomeIcons.remove, size: 22),
        ),
      ],
    );
  }

  Widget _buildLabelsSection() {
    return Row(
      children: List.generate(SectionName.values.length, (index) {
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Center(
                child: Transform.scale(
                  scaleY: 0.9,
                  child: Text(section.label, style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
        );
      }),
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
              ? Center(
                  child: Text(
                    "Veuillez rechercher un aliment.",
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                )
              : _buildFoodListViewItem(state.foodList);
        }
        if (state.getFoodListStatus == GetFoodListStatus.failure) {
          return Center(child: Text(state.getFoodListErrorString ?? 'Erreur'));
        }

        return Center(child: CircularProgressIndicator(color: Colors.white38));
      },
    );
  }

  Widget _buildFoodListViewItem(List<FoodEntity> foodList) {
    return ListView.builder(
      itemCount: foodList.length,
      itemBuilder: (context, index) {
        final food = foodList[index];
        return GestureDetector(
          onTap: () async {
            final parentContext = context;
            final quantity = await showDialog(
              context: context,
              builder: (dialogContext) => FoodPortionDialog(food: food),
            );
            if (quantity != null) {
              parentContext.read<NutritionBloc>().add(
                AddFoodPortionToMeal(quantity, food.id, widget.mealType),
              );
              parentContext.read<NavigationCubit>().goToPage(2);
              Navigator.of(parentContext).pop();
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              food.name,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "${food.primaryStore}, ${food.formattedQuantity}${food.referenceUnit}",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color.fromARGB(131, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          food.formattedCalories,
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color.fromARGB(185, 11, 66, 11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "G: ${food.formattedCarbs} P: ${food.formattedProteins} L: ${food.formattedFats}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
