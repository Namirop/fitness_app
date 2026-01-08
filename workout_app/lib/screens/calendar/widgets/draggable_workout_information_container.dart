import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/widgets/exercise_list_item.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/add_workout_screen.dart';

class DraggableWorkoutInformationContainer extends StatefulWidget {
  final WorkoutEntity workout;
  const DraggableWorkoutInformationContainer({
    super.key,
    required this.workout,
  });

  @override
  State<DraggableWorkoutInformationContainer> createState() =>
      _DraggableWorkoutInformationContainerState();
}

class _DraggableWorkoutInformationContainerState
    extends State<DraggableWorkoutInformationContainer> {
  final GlobalKey _contentKey = GlobalKey();
  double _maxChildSize = 0.95;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMaxSize();
    });
  }

  void _updateMaxSize() {
    final RenderBox? renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final contentHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        _maxChildSize = (contentHeight / screenHeight).clamp(0.15, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.15,
      maxChildSize: _maxChildSize,
      snap: true,
      snapSizes: [0.15, 0.45, _maxChildSize],
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            key: _contentKey,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 243, 241, 235),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.large),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 130),
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Workout",
                                  style: TextStyle(
                                    fontSize: 70,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: const Color.fromARGB(
                                      255,
                                      11,
                                      66,
                                      11,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SizedBox(width: 20),
                                CustomIcon(
                                  onTap: () {
                                    context.read<WorkoutBloc>().add(
                                      SetEditingWorkout(
                                        isEditingMode: true,
                                        workout: workout,
                                      ),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddWorkoutScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit, size: 30),
                                  topPadding: 15,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                _buildDetailsWorkoutLabels(workout.title),
                                SizedBox(width: 10),
                                _buildDetailsWorkoutLabels(
                                  "${DateFormat('dd', 'fr_FR').format(workout.date)} ${DateFormat('MMM', 'fr_FR').format(workout.date)}",
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 3, 0, 5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(197, 235, 222, 196),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.small,
                                ),
                                border: Border.all(
                                  width: 1.2,
                                  color: AppColors.containerBorderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Note :",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: const Color.fromARGB(
                                        255,
                                        11,
                                        66,
                                        11,
                                      ),
                                    ),
                                  ),
                                  workout.note == ''
                                      ? Text(
                                          "Ajouter une note",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Text(
                                          workout.note,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            _workoutInformationContainer(workout),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _workoutInformationContainer(WorkoutEntity workout) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          children: [
            Row(
              children: [
                CustomIcon(
                  size: 35,
                  icon: Icon(FontAwesomeIcons.dumbbell, size: 25),
                  topPadding: 4,
                ),
                SizedBox(width: 30),
                Text(
                  "Séance : ",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
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
                  ExerciseListItem(
                    exercises: workout.exercises,
                    isExpanded: false,
                    iconSize: 65,
                    fontSize: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsWorkoutLabels(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 235, 222, 196),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 2),
        child: Transform.scale(
          scaleY: 0.9,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 25,
              color: const Color.fromARGB(255, 11, 66, 11),
            ),
          ),
        ),
      ),
    );
  }
}
