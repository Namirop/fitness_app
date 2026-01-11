import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_event.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_state.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/utils/snackbar_helper.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';
import 'package:workout_app/screens/main/widgets/calendar_preview.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/main/widgets/preview_daily_nutrition_stats.dart';
import 'package:workout_app/screens/main/widgets/last_workout_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionBloc>().add(LoadDailyNutrition());
      context.read<ProfilBloc>().add(GetCachedProfil());
      context.read<WorkoutBloc>().add(GetExistingWorkouts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.screenBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIcon(onTap: () {}, icon: Icon(Icons.image, size: 30)),
                    SizedBox(width: 15),
                    BlocBuilder<NutritionBloc, NutritionState>(
                      buildWhen: (previous, current) =>
                          previous.currentNutritionDay.totalCalories !=
                          current.currentNutritionDay.totalCalories,
                      builder: (context, state) {
                        if (state.selectedNutritionDateStatus ==
                            SelectedNutritionDateStatus.loading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 60,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }
                        return Text(
                          '🔥 ${state.currentNutritionDay.formattedTotalCalories} KCAL',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    CustomIcon(
                      onTap: () => context.read<NavigationCubit>().goToPage(3),
                      icon: Icon(Icons.person, size: 30),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                BlocConsumer<ProfilBloc, ProfilState>(
                  buildWhen: (current, previous) =>
                      previous.currentProfil != current.currentProfil ||
                      previous.loadProfilStatus != current.loadProfilStatus,
                  listener: (context, state) async {
                    await _handleProfilStateChanges(state);
                  },
                  builder: (context, state) {
                    if (state.loadProfilStatus == LoadProfilStatus.loading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 60,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }
                    return Text(
                      "Bonjour, ${state.currentProfil.displayName}",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CalendarPreview(currentWeek: _getCurrentWeek()),
                const SizedBox(height: 20),
                LastWorkoutContainer(),
                const SizedBox(height: 10),
                const Text(
                  "Infos nutritionnels journalière : ",
                  style: TextStyle(
                    fontSize: 25,
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 15),
                PreviewDailyNutritionStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleProfilStateChanges(ProfilState state) async {
    if (state.loadProfilStatus == LoadProfilStatus.failure) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        state.profilErrorString ?? "Erreur affichage nom",
      );
    }
  }

  List<DateTime> _getCurrentWeek() {
    final now = DateTime.now();

    // Trouve le lundi de la semaine actuelle
    // weedkays: 1 = lundi, 7 = dimanche
    final monday = now.subtract(Duration(days: now.weekday - 1));

    // Génère les 7 jours
    return List.generate(7, (index) {
      return monday.add(Duration(days: index));
    });
  }
}
