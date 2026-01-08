import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/utils/snackbar_helper.dart';
import 'package:workout_app/screens/nutrition/widgets/footer_nutrition.dart';
import 'package:workout_app/screens/nutrition/widgets/daily_nutrition_stats_container.dart';
import 'package:workout_app/screens/nutrition/widgets/meals_container.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionBloc>().add(LoadDailyNutrition());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NutritionBloc, NutritionState>(
      listener: (context, nutritionState) async {
        await _handleNutritionStateChanges(nutritionState);
      },
      builder: (context, nutritionState) {
        final currentNutritionDay = nutritionState.currentNutritionDay;
        final isLoading =
            nutritionState.selectedNutritionDateStatus ==
                SelectedNutritionDateStatus.loading ||
            nutritionState.addFoodPortionStatus ==
                AddFoodPortionStatus.loading ||
            nutritionState.deleteFoodPortionStatus ==
                DeleteFoodPortionStatus.loading;
        return BlocConsumer<ProfilBloc, ProfilState>(
          listener: (context, profilState) {
            _handleProfilStateChanges(profilState);
          },
          builder: (context, profilState) {
            final profil = profilState.currentProfil;
            return Scaffold(
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.screenBackground,
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
                                    FooterNutrition(
                                      date: currentNutritionDay.date,
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
                                      nutritionDay: currentNutritionDay,
                                      profil: profil,
                                      isLoading: isLoading,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          MealsContainer(
                            meals: currentNutritionDay.meals,
                            isLoading: isLoading,
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
      },
    );
  }

  Future<void> _handleProfilStateChanges(ProfilState profilState) async {
    if (!mounted) return;
    if (profilState.loadProfilStatus == LoadProfilStatus.failure) {
      SnackbarHelper.showError(
        context,
        profilState.profilErrorString ?? "Erreur affichage macros target",
      );
    }
  }

  Future<void> _handleNutritionStateChanges(
    NutritionState nutritionState,
  ) async {
    if (!mounted) return;

    if (nutritionState.selectedNutritionDateStatus ==
        SelectedNutritionDateStatus.failure) {
      SnackbarHelper.showError(
        context,
        nutritionState.selectedDateErrorString ?? 'Erreur changement date',
      );
    }
    if (nutritionState.addFoodPortionStatus == AddFoodPortionStatus.success) {
      SnackbarHelper.showSuccess(
        context,
        nutritionState.addFoodPortionSuccessString ?? 'Aliment ajouté',
      );
      Future.microtask(() {
        context.read<NutritionBloc>().add(ResetAddFoodStatus());
      });
    }
    if (nutritionState.addFoodPortionStatus == AddFoodPortionStatus.failure) {
      SnackbarHelper.showError(
        context,
        nutritionState.addFoodPortionErrorString ?? "Erreur lors de l'ajout",
      );
      Future.microtask(() {
        context.read<NutritionBloc>().add(ResetAddFoodStatus());
      });
    }
    if (nutritionState.deleteFoodPortionStatus ==
        DeleteFoodPortionStatus.success) {
      SnackbarHelper.showSuccess(
        context,
        nutritionState.deleteFoodPortionSuccessString ?? 'Aliment supprimé',
      );
      Future.microtask(() {
        context.read<NutritionBloc>().add(ResetDeleteFoodStatus());
      });
    }

    if (nutritionState.deleteFoodPortionStatus ==
        DeleteFoodPortionStatus.failure) {
      SnackbarHelper.showError(
        context,
        nutritionState.deleteFoodPortionSuccessString ??
            'Erreur lors de la suppresion',
      );
      Future.microtask(() {
        context.read<NutritionBloc>().add(ResetDeleteFoodStatus());
      });
    }
  }
}
