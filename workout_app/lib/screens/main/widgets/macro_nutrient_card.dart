import 'package:flutter/material.dart';
import 'package:workout_app/core/constants/app_constants.dart';

class MacroNutrientCard extends StatelessWidget {
  final String assetPath;
  final Color color;
  final String label;
  final String total;
  final String target;
  final bool isLoading;
  const MacroNutrientCard({
    super.key,
    required this.assetPath,
    required this.color,
    required this.label,
    required this.total,
    required this.target,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: const Color.fromARGB(225, 255, 255, 255),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
        child: isLoading
            ? SizedBox(
                height: 110,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(assetPath, width: 30, color: color),
                  SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${total}g",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "/ $target ",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.5),
                        child: Text(
                          "g",
                          style: TextStyle(
                            fontSize: 12,
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
