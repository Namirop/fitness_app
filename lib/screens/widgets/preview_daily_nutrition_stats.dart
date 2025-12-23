import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';

class PreviewDailyNutritionStats extends StatefulWidget {
  const PreviewDailyNutritionStats({super.key});

  @override
  State<PreviewDailyNutritionStats> createState() =>
      _PreviewDailyNutritionStatsState();
}

class _PreviewDailyNutritionStatsState
    extends State<PreviewDailyNutritionStats> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildContainer(
              'assets/images/carbs_icon.png',
              Colors.yellow,
              "Glucides",
              120,
              480,
            ),
            _buildContainer(
              'assets/images/protein_icon.png',
              Colors.blue,
              "Protéines",
              98,
              392,
            ),
            _buildContainer(
              'assets/images/fats_icon.jpg',
              const Color.fromARGB(255, 218, 233, 84),
              "Lipides",
              52,
              220,
            ),
          ],
        );
      },
    );
  }

  Widget _buildContainer(
    String asset,
    Color color,
    String macro,
    int valuesGr,
    int valueKcal,
  ) {
    return Container(
      height: 150,
      width: 110,
      decoration: BoxDecoration(
        color: const Color.fromARGB(225, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2), // x, y
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(asset, width: 30, color: color),
            SizedBox(height: 10),
            Text(
              macro,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${valuesGr}g",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              children: [
                Text(
                  "/ ${valueKcal} ",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.5),
                  child: Text(
                    "kcal",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
