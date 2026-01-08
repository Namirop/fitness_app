import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class ExerciseDetailsContainer extends StatefulWidget {
  final WorkoutExerciseEntity? exercise;
  final int? exerciseIndex;
  final bool isSavingOrLoading;
  const ExerciseDetailsContainer({
    super.key,
    this.exercise,
    this.exerciseIndex,
    required this.isSavingOrLoading,
  });

  @override
  State<ExerciseDetailsContainer> createState() =>
      _ExerciseDetailsContainerState();
}

class _ExerciseDetailsContainerState extends State<ExerciseDetailsContainer> {
  Timer? _debounceSets;
  Timer? _debounceReps;
  Timer? _debounceWeight;

  @override
  void dispose() {
    _debounceSets?.cancel();
    _debounceReps?.cancel();
    _debounceWeight?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 12),
        // “_selectedExerciseIndex! >= workout.exercises.length” => 1 >= 1 → true → displays "Select an exercise" instead of crashing
        child: widget.isSavingOrLoading
            ? SizedBox(
                height: 175,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : widget.exercise == null
            ? const Center(
                child: Text(
                  "Sélectionnez un exercice",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : _buildExerciseDetails(),
      ),
    );
  }

  Widget _buildExerciseDetails() {
    final ex = widget.exercise!;
    final index = widget.exerciseIndex!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSlider(
          icon: CustomIcon(
            icon: Icon(Icons.document_scanner, size: 20),
            size: 35,
          ),
          label: "Sets",
          min: 1,
          max: 10,
          initialValue: ex.sets.toDouble(),
          onChanged: (value) {
            _debounceSets?.cancel();
            _debounceSets = Timer(const Duration(milliseconds: 500), () {
              context.read<WorkoutBloc>().add(
                UpdateExerciseDetails(exIndex: index, sets: value.toInt()),
              );
            });
          },
        ),
        SizedBox(width: 15),
        _buildSlider(
          icon: const Icon(Icons.repeat, size: 20),
          label: "Reps",
          min: 1,
          max: 20,
          initialValue: ex.reps.toDouble(),
          onChanged: (value) {
            _debounceReps?.cancel();
            _debounceReps = Timer(const Duration(milliseconds: 500), () {
              context.read<WorkoutBloc>().add(
                UpdateExerciseDetails(exIndex: index, reps: value.toInt()),
              );
            });
          },
        ),
        const SizedBox(width: 15),
        _buildSlider(
          icon: const FaIcon(FontAwesomeIcons.weightHanging, size: 17),
          label: "Weight",
          min: 1,
          max: 150,
          initialValue: ex.weight.toDouble(),
          onChanged: (value) {
            _debounceWeight?.cancel();
            _debounceWeight = Timer(const Duration(milliseconds: 500), () {
              context.read<WorkoutBloc>().add(
                UpdateExerciseDetails(exIndex: index, weight: value.toInt()),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSlider({
    required Widget icon,
    required String label,
    required double min,
    required double max,
    required double initialValue,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            CustomIcon(icon: icon, size: 35),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 80,
          height: 80,
          child: SleekCircularSlider(
            min: min,
            max: max,
            initialValue: initialValue,
            appearance: CircularSliderAppearance(
              size: 80,
              customColors: CustomSliderColors(
                trackColor: Color.fromARGB(52, 121, 85, 72),
                progressBarColor: Colors.black,
                dotColor: Colors.black,
              ),
              customWidths: CustomSliderWidths(
                trackWidth: 3,
                progressBarWidth: 3,
                handlerSize: 5,
              ),
              infoProperties: InfoProperties(
                mainLabelStyle: const TextStyle(fontSize: 30),
                modifier: (double value) => '${value.toInt()}',
              ),
            ),
            onChange: onChanged,
          ),
        ),
      ],
    );
  }
}
