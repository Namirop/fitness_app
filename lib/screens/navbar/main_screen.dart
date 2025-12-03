import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/screens/profil_screen.dart';
import 'package:workout_app/screens/widgets/calendar_preview.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/widgets/existing_workouts_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(GetExistingWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xfffaedcd),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconButton(onTap: () {}, icon: Icons.image),
                      SizedBox(width: 30),
                      Text(
                        '🔥 CALORIES',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Spacer(),
                      CustomIconButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilScreen(),
                            ),
                          );
                        },
                        icon: Icons.person,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Bonjour, Romain.",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(height: 10),
                  CalendarPreview(
                    currentWeek: _getCurrentWeek(),
                    workoutDays: _getWorkoutDays(),
                  ),

                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Text(
                        "ENTRAINEMENT : ",
                        style: TextStyle(fontSize: 15),
                      ),
                      GestureDetector(
                        onDoubleTap: () {
                          context.read<WorkoutBloc>().add(DeleteAllWorkouts());
                          context.read<WorkoutBloc>().add(
                            GetExistingWorkouts(),
                          );
                        },
                        child: const Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ExistingWorkoutsContainer(),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Set<DateTime> _getWorkoutDays() {
    final state = context.read<WorkoutBloc>().state;

    if (state is GetExistingWorkoutsSuccess) {
      return state.workouts.map((w) {
        return DateTime(w.date.year, w.date.month, w.date.day);
      }).toSet();
    }
    return {}; // Si pas Success, retourne Set vide
  }
}
