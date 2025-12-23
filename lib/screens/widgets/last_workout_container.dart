import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/screens/add_workout_screen.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class LastWorkoutContainer extends StatefulWidget {
  const LastWorkoutContainer({super.key});

  @override
  State<LastWorkoutContainer> createState() => LastWorkoutContainerState();
}

class LastWorkoutContainerState extends State<LastWorkoutContainer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      buildWhen: (previous, current) =>
          previous.existingWorkoutsStatus != current.existingWorkoutsStatus,
      builder: (context, state) {
        final workouts = state.existingWorkouts;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final mostRecentWorkout =
            workouts.where((w) {
              final workoutDate = DateTime(
                w.date.year,
                w.date.month,
                w.date.day,
              );
              return workoutDate.isAtSameMomentAs(today);
            }).firstOrNull ??
            (workouts.isNotEmpty
                ? (workouts.toList()..sort((a, b) => b.date.compareTo(a.date)))
                      .first
                : null);

        return Container(
          height: 295,
          decoration: BoxDecoration(
            color: const Color.fromARGB(155, 255, 255, 255),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(FontAwesomeIcons.dumbbell, size: 25),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "Dernière séance : ",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: CustomIconButton(
                            onTap: () async {
                              if (mostRecentWorkout != null) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddWorkoutScreen(
                                      workoutToEdit: mostRecentWorkout,
                                    ),
                                  ),
                                );
                                context.read<WorkoutBloc>().add(
                                  GetExistingWorkouts(),
                                );
                              }
                            },
                            size: 30,
                            color: Colors.transparent,
                            icon: Icon(FontAwesomeIcons.solidEdit, size: 18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: 0.2, // En radians (0.2 ≈ 11 degrés)
                              child: Image.asset(
                                'assets/images/dumbell.png',
                                fit: BoxFit.cover,
                                opacity: const AlwaysStoppedAnimation(0.03),
                              ),
                            ),
                          ),
                          _buildWorkoutContent(state, mostRecentWorkout),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    mostRecentWorkout != null
                        ? GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddWorkoutScreen(),
                                ),
                              );
                              if (mounted) {
                                context.read<WorkoutBloc>().add(
                                  GetExistingWorkouts(),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: const Color.fromARGB(255, 68, 62, 62),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Ajouter un workout",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutContent(
    WorkoutState state,
    WorkoutEntity? mostRecentWorkout,
  ) {
    if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color.fromARGB(97, 122, 44, 44),
        ),
      );
    }

    if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.success) {
      if (mostRecentWorkout != null) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.black),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                child: Text(
                  "${mostRecentWorkout.title} - ${DateFormat('dd', 'fr_FR').format(mostRecentWorkout.date)} ${DateFormat('MMM', 'fr_FR').format(mostRecentWorkout.date)}",
                  style: TextStyle(fontSize: 17, letterSpacing: -0.6),
                ),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Scrollbar(
                thickness: 2,
                radius: Radius.circular(10),
                child: ListView.builder(
                  itemCount: mostRecentWorkout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = mostRecentWorkout.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                        right: 9,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Image.network(
                              exercise.exercise.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.exercise.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            "${exercise.sets}x${exercise.reps}",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: CustomIconButton(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
              );
              if (mounted) {
                context.read<WorkoutBloc>().add(GetExistingWorkouts());
              }
            },
            size: 60,
            icon: Icon(Icons.add, size: 40),
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

    return Center(child: CircularProgressIndicator(color: Colors.white38));
  }
}
