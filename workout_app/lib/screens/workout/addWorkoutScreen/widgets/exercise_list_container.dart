import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/workout/exercise_search_screen.dart';

class ExerciseListContainer extends StatelessWidget {
  final List<WorkoutExerciseEntity> exercises;
  final int? selectedIndex;
  final Function(int?) onSelectionChanged;
  final bool isSavingOrLoading;
  const ExerciseListContainer({
    super.key,
    required this.exercises,
    this.selectedIndex,
    required this.onSelectionChanged,
    required this.isSavingOrLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: isSavingOrLoading
            ? SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      CustomIcon(
                        topPadding: 4,
                        icon: const FaIcon(FontAwesomeIcons.dumbbell, size: 22),
                        size: 40,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Exercices :",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      CustomIcon(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseSearchScreen(),
                            ),
                          );
                        },
                        topPadding: 5,
                        size: 35,
                        icon: Icon(Icons.add, size: 28),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: exercises.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun exercice",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : _buildExerciseList(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (_, index) {
        final ex = exercises[index];
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onDoubleTap: () {
            onSelectionChanged(isSelected ? null : index);
          },
          onLongPress: () {
            onSelectionChanged(isSelected ? null : index);
            context.read<WorkoutBloc>().add(
              RemoveExercise(exerciseId: ex.exercise.id),
            );
          },
          child: Card(
            color: isSelected
                ? Color.fromARGB(255, 243, 243, 241)
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ex.exercise.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: const Color.fromARGB(255, 167, 106, 84),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      ex.exercise.name,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: -0.5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
