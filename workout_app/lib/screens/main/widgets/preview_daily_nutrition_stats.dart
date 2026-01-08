import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/screens/main/widgets/macro_nutrient_card.dart';

class PreviewDailyNutritionStats extends StatelessWidget {
  const PreviewDailyNutritionStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, nutritionState) {
        return BlocBuilder<ProfilBloc, ProfilState>(
          builder: (context, profilState) {
            final nutritionDay = nutritionState.currentNutritionDay;
            final profil = profilState.currentProfil;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MacroNutrientCard(
                  assetPath: 'assets/images/carbs_icon.png',
                  color: Colors.yellow,
                  label: "Glucides",
                  total: nutritionDay.formattedTotalCarbs,
                  target: profil.displayCarbsTarget,
                ),
                MacroNutrientCard(
                  assetPath: 'assets/images/protein_icon.png',
                  color: Colors.blue,
                  label: "Protéines",
                  total: nutritionDay.formattedTotalProteins,
                  target: profil.displayProteinsTarget,
                ),
                MacroNutrientCard(
                  assetPath: 'assets/images/carbs_icon.png',
                  color: const Color.fromARGB(255, 218, 233, 84),
                  label: "Lipides",
                  total: nutritionDay.formattedTotalFats,
                  target: profil.displayFatsTarget,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
