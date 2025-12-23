import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class DailyNutritionStatsContainer extends StatelessWidget {
  final NutritionDayEntity? currentNutritionDay;
  final bool isLoading;

  const DailyNutritionStatsContainer({
    required this.currentNutritionDay,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: const Color.fromARGB(155, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 2,
          color: const Color.fromARGB(52, 121, 85, 72),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 184, 89, 83),
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      CustomIconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.carrot,
                          size: 22,
                          color: Colors.orange,
                        ),
                        size: 40,
                        color: Colors.transparent,
                      ),
                      SizedBox(width: 10),
                      Transform.scale(
                        scaleY: 1.1,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "${currentNutritionDay!.totalCalories}",
                              ),
                              TextSpan(
                                text: ' /',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: "${currentNutritionDay!.caloriesTarget}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 180,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius:
                                    70, // Augmenter pour agrandir le cercle
                                sections: [
                                  PieChartSectionData(
                                    value: 64,
                                    color: Colors.blue,
                                    radius:
                                        12, // Augmenter pour épaissir les segments
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 20,
                                    color: Colors.yellow,
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: 16,
                                    color: Colors.purple,
                                    radius: 12,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Day 8',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '64%',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '+5%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      Column(
                        children: [
                          _rowMacro(
                            Colors.yellow,
                            "Glucides",
                            currentNutritionDay!.totalCarbs,
                            currentNutritionDay!.carbsTarget,
                          ),
                          SizedBox(height: 10),
                          _rowMacro(
                            Colors.blue,
                            "Protéines",
                            currentNutritionDay!.totalProteins,
                            currentNutritionDay!.proteinsTarget,
                          ),
                          SizedBox(height: 10),
                          _rowMacro(
                            Colors.deepPurple,
                            "Lipides",
                            currentNutritionDay!.totalFats,
                            currentNutritionDay!.fatsTarget,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _rowMacro(
    Color color,
    String macro,
    double totalMacro,
    double targetMacro,
  ) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: 35,
              width: 2,
              color: const Color.fromARGB(78, 192, 191, 191),
            ),
            Container(height: 15, width: 2, color: color),
          ],
        ),
        SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                macro,
                style: TextStyle(letterSpacing: -0.1, fontSize: 17),
              ),
            ),
            SizedBox(height: 1),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: const Color.fromARGB(255, 134, 134, 134),
                  letterSpacing: -0.7,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: "${totalMacro}",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' /',
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  TextSpan(text: "${targetMacro}"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
