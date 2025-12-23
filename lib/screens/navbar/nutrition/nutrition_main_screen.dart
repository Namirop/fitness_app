import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/data/entities/nutrition/meal_entity.dart';
import 'package:workout_app/screens/navbar/nutrition/food_search_screen.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/widgets/daily_nutrition_stats_container.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> {
  int selectedMealTypeIndex = 0;

  @override
  void initState() {
    context.read<NutritionBloc>().add(LoadTodayNutrition());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NutritionBloc, NutritionState>(
      buildWhen: (previous, current) {
        final prevDate = previous.currentNutritionDay.date;
        final currDate = current.currentNutritionDay.date;

        return prevDate.year != currDate.year ||
            prevDate.month != currDate.month ||
            prevDate.day != currDate.day;
      },
      listener: (context, state) {
        if (state.selectDateStatus == SelectDateStatus.failure) {
          _showSnackBar(state.selectedDateErrorString ?? 'Erreur', Colors.red);
          return;
        }

        if (state.addFoodPortionStatus == AddFoodPortionStatus.failure) {
          _showSnackBar(
            state.addFoodPortionErrorString ?? 'Erreur',
            Colors.red,
          );
          return;
        }
      },
      builder: (context, state) {
        final currentNutritionDay = state.currentNutritionDay;

        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 238, 228, 206),
                    Color.fromARGB(255, 243, 239, 227),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomIconButton(
                                      onTap: () {
                                        context.read<NutritionBloc>().add(
                                          SelectDate(isPrevious: true),
                                        );
                                      },
                                      icon: Icon(Icons.chevron_left, size: 28),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      "${DateFormat('dd', 'fr_FR').format(currentNutritionDay.date)} ${DateFormat('MMM', 'fr_FR').format(currentNutritionDay.date)}",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    SizedBox(width: 15),
                                    CustomIconButton(
                                      onTap: () {
                                        context.read<NutritionBloc>().add(
                                          SelectDate(isPrevious: false),
                                        );
                                      },
                                      icon: Icon(Icons.chevron_right, size: 28),
                                    ),
                                    Spacer(),
                                    CustomIconButton(
                                      onTap: () {},
                                      icon: PopupMenuButton<String>(
                                        icon: Icon(Icons.add),
                                        color: Colors.white,
                                        iconSize: 25,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 5,
                                        offset: Offset(25, 48),
                                        onSelected: (value) {},
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'option1',
                                            height: 30,
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.pizzaSlice,
                                                  color: Colors.orange,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Ajouter une recette',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuDivider(),
                                          PopupMenuItem(
                                            value: 'option2',
                                            height: 30,
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.folderOpen,
                                                  color: Colors.orange,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Statistiques',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Transform.scale(
                                  scaleY: 0.9,
                                  child: Text(
                                    "Nutrition :",
                                    style: TextStyle(
                                      fontSize: 43,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                DailyNutritionStatsContainer(
                                  currentNutritionDay: currentNutritionDay,
                                  isLoading:
                                      state.selectDateStatus ==
                                      SelectDateStatus.loading,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 175,
                        child:
                            state.selectDateStatus == SelectDateStatus.loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 184, 89, 83),
                                ),
                              )
                            : PageView.builder(
                                onPageChanged: (value) {
                                  setState(() {
                                    selectedMealTypeIndex = value;
                                  });
                                },
                                itemCount: currentNutritionDay.meals.length,
                                itemBuilder: (context, index) {
                                  return _mealContainer(
                                    currentNutritionDay.meals[index],
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            MealType.values.length - 1,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mealContainer(MealEntity meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          color: const Color.fromARGB(155, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: const Color.fromARGB(52, 121, 85, 72),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.lunch_dining_rounded, size: 18),
                  ),
                  SizedBox(width: 10),
                  Text(meal.type.label, style: TextStyle(fontSize: 18)),
                ],
              ),
              SizedBox(height: 15),
              Expanded(
                child: meal.foodPortions.isEmpty
                    ? Center(
                        child: CustomIconButton(
                          onTap: () async {
                            await Navigator.push(
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
                    : ListView.builder(
                        itemCount: meal.foodPortions.length,
                        itemBuilder: (context, index) {
                          final fooPortions = meal.foodPortions[index];
                          return ListTile(
                            title: Text(fooPortions.food.name),
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
              ),
              if (meal.foodPortions.isNotEmpty) ...[
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FoodSearchScreen(mealType: meal.type),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }
}
