import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class DailyNutritionStatsContainer extends StatelessWidget {
  final NutritionDayEntity nutritionDay;
  final ProfilEntity profil;
  final bool isLoading;

  const DailyNutritionStatsContainer({
    super.key,
    required this.nutritionDay,
    required this.profil,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: isLoading
            ? SizedBox(
                height: 270,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      CustomIcon(
                        icon: FaIcon(
                          FontAwesomeIcons.carrot,
                          size: 28,
                          color: Colors.orange,
                        ),
                        size: 40,
                        color: Colors.transparent,
                      ),
                      SizedBox(width: 13),
                      Transform.scale(
                        scaleY: 1,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: nutritionDay.formattedTotalCalories,
                              ),
                              TextSpan(
                                text: ' /',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: '${profil.displayCaloriesTarget} kcal',
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
                      _buildPieChart(),
                      SizedBox(width: 25),
                      Column(
                        children: [
                          _rowMacro(
                            Colors.yellow,
                            "Glucides",
                            nutritionDay.formattedTotalCarbs,
                            profil.displayCarbsTarget,
                          ),
                          SizedBox(height: 10),
                          _rowMacro(
                            Colors.blue,
                            "Protéines",
                            nutritionDay.formattedTotalProteins,
                            profil.displayProteinsTarget,
                          ),
                          SizedBox(height: 10),
                          _rowMacro(
                            Colors.deepPurple,
                            "Lipides",
                            nutritionDay.formattedTotalFats,
                            profil.displayFatsTarget,
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

  // HARD-CODED
  Widget _buildPieChart() {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 75,
              sections: [
                PieChartSectionData(
                  value: 64,
                  color: Colors.blue,
                  radius: 12,
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
                  style: TextStyle(fontSize: 21, color: Colors.grey),
                ),
                Text(
                  '64%',
                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                ),
                Text(
                  '+5%',
                  style: TextStyle(fontSize: 21, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowMacro(
    Color color,
    String macro,
    String totalMacro,
    String targetMacro,
  ) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: 50,
              width: 3,
              color: const Color.fromARGB(78, 192, 191, 191),
            ),
            Container(height: 20, width: 3, color: color),
          ],
        ),
        SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(macro, style: TextStyle(letterSpacing: -0.1, fontSize: 22)),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 134, 134, 134),
                    letterSpacing: -0.7,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: totalMacro,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' /',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    TextSpan(text: targetMacro),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
