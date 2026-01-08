import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/screens/widgets/exercise_list_item.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/add_workout_screen.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class LastWorkoutContainer extends StatelessWidget {
  const LastWorkoutContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      buildWhen: (previous, current) =>
          previous.existingWorkouts != current.existingWorkouts,
      builder: (context, state) {
        final lastWorkout = state.getLastWorkout();
        return Container(
          decoration: BoxDecoration(
            color: AppColors.widgetBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            border: Border.all(width: 2, color: AppColors.containerBorderColor),
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
                          child: CustomIcon(
                            onTap: () {
                              if (lastWorkout != null) {
                                context.read<WorkoutBloc>().add(
                                  SetEditingWorkout(
                                    isEditingMode: true,
                                    workout: lastWorkout,
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddWorkoutScreen(),
                                  ),
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
                    SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Image.asset(
                                'assets/images/dumbell.png',
                                fit: BoxFit.cover,
                                opacity: const AlwaysStoppedAnimation(0.03),
                              ),
                            ),
                          ),
                          _buildWorkoutContent(state, lastWorkout, context),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    if (lastWorkout != null) _buildAddWorkoutButton(context),
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
    WorkoutEntity? lastWorkout,
    BuildContext context,
  ) {
    if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color.fromARGB(97, 122, 44, 44),
        ),
      );
    }

    if (state.existingWorkoutsStatus == ExistingWorkoutsStatus.success) {
      if (lastWorkout != null) {
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
                  "${lastWorkout.title} - ${DateFormat('dd', 'fr_FR').format(lastWorkout.date)} ${DateFormat('MMM', 'fr_FR').format(lastWorkout.date)}",
                  style: TextStyle(fontSize: 17, letterSpacing: -0.6),
                ),
              ),
            ),
            SizedBox(height: 5),
            ExerciseListItem(exercises: lastWorkout.exercises),
          ],
        );
      } else {
        return Center(
          child: CustomIcon(
            onTap: () {
              context.read<WorkoutBloc>().add(
                SetEditingWorkout(isEditingMode: false),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
              );
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

  Widget _buildAddWorkoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<WorkoutBloc>().add(
          SetEditingWorkout(isEditingMode: false),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          color: AppColors.buttonColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIcon(
                topPadding: 2,
                icon: Icon(Icons.add),
                size: 25,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                "Ajouter un workout",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
