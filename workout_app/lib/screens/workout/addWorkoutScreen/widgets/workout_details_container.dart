import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/utils/dialog_helper.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class WorkoutDetailsContainer extends StatefulWidget {
  final WorkoutEntity workout;
  final Set<DateTime> workoutDays;
  final bool isSavingOrLoading;
  const WorkoutDetailsContainer({
    super.key,
    required this.workout,
    required this.workoutDays,
    required this.isSavingOrLoading,
  });

  @override
  State<WorkoutDetailsContainer> createState() =>
      _WorkoutDetailsContainerState();
}

class _WorkoutDetailsContainerState extends State<WorkoutDetailsContainer> {
  Timer? _debounceTitle;
  Timer? _debounceNote;
  static const double _workoutDetailsHeight = 195;

  @override
  void dispose() {
    _debounceTitle?.cancel();
    _debounceNote?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: widget.isSavingOrLoading
            ? SizedBox(
                height: _workoutDetailsHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIcon(
                        size: 45,
                        icon: const FaIcon(
                          FontAwesomeIcons.stopwatch,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Workout :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(width: 10),
                      CustomIcon(
                        onTap: () async {
                          final confirm = await DialogHelper.showConfirmDialog(
                            context,
                            title: "Réinitialiser tous les champs ?",
                            confirmText: "Oui, réinitialiser",
                            cancelText: "Non, garder",
                          );
                          if (confirm == true && mounted) {
                            context.read<WorkoutBloc>().add(
                              ResetToEmptyWorkout(),
                            );
                          }
                        },
                        topPadding: 5,
                        size: 25,
                        icon: Icon(Icons.restart_alt_sharp, size: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTitleContainer(workout.title),
                              SizedBox(height: 7),
                              _buildDateContainer(workout.date),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        _buildNoteContainer(workout.note),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleContainer(String title) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(87, 235, 209, 137),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: TextFormField(
            key: ValueKey('workout_title_${DateTime.now().toString()}'),
            initialValue: title,
            decoration: InputDecoration(
              hintText: "Titre",
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 11),
            onChanged: (query) {
              _debounceTitle?.cancel();
              _debounceTitle = Timer(const Duration(milliseconds: 500), () {
                if (query.length > 2) {
                  context.read<WorkoutBloc>().add(
                    UpdateWorkoutDetails(title: query),
                  );
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateContainer(DateTime date) {
    return GestureDetector(
      onTap: () async {
        final workoutDate = DateTime(date.year, date.month, date.day);

        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          selectableDayPredicate: (DateTime pickerDate) {
            final normalizedPickerDate = DateTime(
              pickerDate.year,
              pickerDate.month,
              pickerDate.day,
            );
            if (normalizedPickerDate == workoutDate) {
              return true;
            }

            return !widget.workoutDays.contains(normalizedPickerDate);
          },
        );

        if (selectedDate != null) {
          context.read<WorkoutBloc>().add(
            UpdateWorkoutDetails(date: selectedDate),
          );
        }
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color.fromARGB(87, 235, 209, 137),
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContainer(String note) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(87, 235, 209, 137),
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: TextFormField(
              key: ValueKey('workout_note_${DateTime.now().toString()}'),
              initialValue: note,
              decoration: InputDecoration(
                hintText: "Note",
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 11),
              onChanged: (value) {
                _debounceNote?.cancel();
                _debounceNote = Timer(const Duration(milliseconds: 500), () {
                  context.read<WorkoutBloc>().add(
                    UpdateWorkoutDetails(note: value),
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
