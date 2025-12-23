import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';
import 'package:workout_app/screens/widgets/calendar_preview.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/widgets/preview_daily_nutrition_stats.dart';
import 'package:workout_app/screens/widgets/last_workout_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfilBloc>().add(GetCachedProfil());
    context.read<WorkoutBloc>().add(GetExistingWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Container(
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconButton(
                          onTap: () {},
                          icon: Icon(Icons.image, size: 30),
                        ),
                        SizedBox(width: 30),
                        Text(
                          '🔥 CALORIES',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Spacer(),
                        CustomIconButton(
                          onTap: () =>
                              context.read<NavigationCubit>().goToPage(3),
                          icon: Icon(Icons.person, size: 30),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    BlocConsumer<ProfilBloc, ProfilState>(
                      buildWhen: (current, previous) =>
                          previous.currentProfil != current.currentProfil,
                      listener: (context, state) {
                        if (state.loadProfilInfosStatus ==
                            LoadProfilInfosStatus.failure) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.profilInfoErrorString ??
                                    "Erreur preload nom",
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                189,
                                80,
                                73,
                              ),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                                textColor: Colors.white,
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
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
      },
    );
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
