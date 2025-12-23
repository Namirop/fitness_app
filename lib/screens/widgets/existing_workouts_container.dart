import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/screens/add_workout_screen.dart';

class ExistingWorkoutsContainer extends StatefulWidget {
  const ExistingWorkoutsContainer({super.key});

  @override
  State<ExistingWorkoutsContainer> createState() =>
      _ExistingWorkoutsContainerState();
}

class _ExistingWorkoutsContainerState extends State<ExistingWorkoutsContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.black12,
      child: BlocBuilder<WorkoutBloc, WorkoutState>(
        buildWhen: (previous, current) =>
            previous.existingWorkoutsStatus != current.existingWorkoutsStatus,
        builder: (context, state) {
          if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white38),
            );
          }

          if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.success) {
            if (state.existingWorkouts.isNotEmpty) {
              final workouts = state.existingWorkouts;
              final now = DateTime.now();
              // Trouve le lundi de la semaine actuelle
              final monday = now.subtract(Duration(days: now.weekday - 1));
              // Trouve le dimanche
              final sunday = monday.add(Duration(days: 6));

              // Filtre les workouts de cette semaine
              final workoutsOfTheWeek = workouts.where((w) {
                return w.date.isAfter(monday.subtract(Duration(days: 1))) &&
                    w.date.isBefore(sunday.add(Duration(days: 1)));
              }).toList();
              return ListView.builder(
                itemCount:
                    workoutsOfTheWeek.length +
                    1, // +1 pour la carte 'Ajout' de fin
                itemBuilder: (context, int i) {
                  if (i == workoutsOfTheWeek.length) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddWorkoutScreen(),
                          ),
                        );
                        // Ne pas oublier cette ligne pour faire comprendre qu'en revenant de la page d'ajout, on doit bien appeler de nouveau cette état, pour que le blocbuilder
                        // se rebuild sur base des current indiqué => pour permettre une recharge au retour
                        if (mounted) {
                          context.read<WorkoutBloc>().add(
                            GetExistingWorkouts(),
                          );
                        }
                      },
                      child: Card(
                        color: Colors.white10,
                        child: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, size: 35, color: Colors.white70),
                              SizedBox(width: 10),
                              Text(
                                "Ajouter un workout",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onDoubleTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWorkoutScreen(
                            workoutToEdit: workoutsOfTheWeek[i],
                          ),
                        ),
                      );
                      context.read<WorkoutBloc>().add(GetExistingWorkouts());
                    },
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${workoutsOfTheWeek[i].title} -"),
                          SizedBox(width: 10),
                          Text(
                            DateFormat(
                              'd MMM yyyy',
                            ).format(workoutsOfTheWeek[i].date),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddWorkoutScreen(),
                      ),
                    );
                    if (mounted) {
                      context.read<WorkoutBloc>().add(GetExistingWorkouts());
                    }
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              );
            }
          }

          if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.existingWorkoutsErrorString!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WorkoutBloc>().add(GetExistingWorkouts());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Fallback : load au lieu d'erreur
          return Center(
            child: CircularProgressIndicator(color: Colors.white38),
          );
        },
      ),
    );
  }
}
