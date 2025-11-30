import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/screens/calendar_screen.dart';
import 'package:workout_app/screens/add_workout_screen.dart';

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: const Icon(Icons.image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 120),
                        child: Text(
                          '🔥 CALORIES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onDoubleTap: () {
                          /* context.read<WorkoutBloc>().add(
                            AddWorkout(),
                          ); */
                          /* Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ProfilScreen())
                          ); */
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),

                  // -------
                  const SizedBox(height: 15),
                  const Text(
                    "Bonjour, Romain.",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),

                  // -----
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(),
                        ),
                      );
                      context.read<WorkoutBloc>().add(GetExistingWorkouts());
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 248, 227, 178),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Center(child: Text("CALENDRIER")),
                    ),
                  ),

                  // -----
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
                        },
                        child: const Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  /* Container(
                  height: 200,
                  color: Colors.black12,
                  child: BlocBuilder<WorkoutsBloc, WorkoutsState>(
                    builder: (context, state) {
                      if (state is FetchExercicesLoading) {
                        return Center(
                          child: CircularProgressIndicator()
                        );
                      }  if (state is FetchExercicesSuccess) {
                        return ListView.builder(
                          itemCount: state.exercices.length,
                          itemBuilder: (context, int i) {
                            return Card(
                              // METTRE INFO WORKOUT
                            );
                          }
                        );
                      }
                      if (state is FetchExercicesFailure) {
                        return Center(
                          child: Text(state.message),
                        );
                      }
                      else {
                        return Container();
                      }
                    }
                  ),
                ), */
                  Container(
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
                            child: CircularProgressIndicator(
                              color: Colors.white38,
                            ),
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
                                          builder: (context) =>
                                              AddWorkoutScreen(),
                                        ),
                                      );
                                      // Ne pas oublier cette ligne pour faire comprendre qu'en revenant de la page d'ajout, on doit bien appeler de nouveau cette état, pour que le blocbuilder
                                      // se rebuild sur base des current indiqué => pour permettre une recharge au retour
                                      context.read<WorkoutBloc>().add(
                                        GetExistingWorkouts(),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.white10,
                                      child: SizedBox(
                                        width: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add,
                                              size: 35,
                                              color: Colors.white70,
                                            ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(workout.title + " -"),
                                        SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            'd MMM yyyy',
                                          ).format(workout.date),
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
                                  context.read<WorkoutBloc>().add(
                                    GetExistingWorkouts(),
                                  );
                                },
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white60,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25),
                                    ),
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
                                    context.read<WorkoutBloc>().add(
                                      GetExistingWorkouts(),
                                    );
                                  },
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          );
                        }

                        // Fallback : load au lieu d'erreur
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white38,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
