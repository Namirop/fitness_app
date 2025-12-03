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
            current is GetExistingWorkoutsLoading ||
            current is GetExistingWorkoutsSuccess ||
            current is GetExistingWorkoutsFailure,
        builder: (context, state) {
          if (state is GetExistingWorkoutsLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white38),
            );
          }

          if (state is GetExistingWorkoutsSuccess) {
            if (state.workouts.isNotEmpty) {
              return ListView.builder(
                itemCount:
                    state.workouts.length +
                    1, // +1 pour la carte 'Ajout' de fin
                itemBuilder: (context, int i) {
                  if (i == state.workouts.length) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddWorkoutScreen(),
                          ),
                        );
                        // Ne pas oublier cette ligne pour faire comprendre qu'en revenant de la page d'ajout, on doit bien appeler de nouveau cette état, pour que le blocbuilder
                        // se rebuild sur base des current indiqué => pour permettre une recharge au retour
                        context.read<WorkoutBloc>().add(GetExistingWorkouts());
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

                  final workout = state.workouts[i];
                  return GestureDetector(
                    onDoubleTap: () {},
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${workout.title} -"),
                          SizedBox(width: 10),
                          Text(DateFormat('d MMM yyyy').format(workout.date)),
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
                    context.read<WorkoutBloc>().add(GetExistingWorkouts());
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

          if (state is GetExistingWorkoutsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
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
