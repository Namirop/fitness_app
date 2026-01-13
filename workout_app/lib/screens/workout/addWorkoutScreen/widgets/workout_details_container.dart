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
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.workout.title);
    _noteController = TextEditingController(text: widget.workout.note);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debounceTitle?.cancel();
    _debounceNote?.cancel();
    _titleController.dispose();
    _noteController.dispose();
  }

  @override
  void didUpdateWidget(WorkoutDetailsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout.title != widget.workout.title) {
      _titleController.text = widget.workout.title;
    }
    if (oldWidget.workout.note != widget.workout.note) {
      _noteController.text = widget.workout.note;
    }
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
                height: 195,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.containerBorderColor,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomIcon(
                            size: 45,
                            icon: const FaIcon(
                              FontAwesomeIcons.dumbbell,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Workout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
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
                        size: 40,
                        color: Colors.transparent,
                        icon: Icon(
                          Icons.restart_alt,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildTitleField(),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDateContainer(workout.date),
                      ),
                      SizedBox(width: 10),
                      Expanded(flex: 3, child: _buildNoteField()),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(
          color: AppColors.containerBorderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: _titleController,
          cursorColor: Colors.black87,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Titre de l'entraînement",
            hintStyle: TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.normal,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (query) {
            _debounceTitle?.cancel();
            _debounceTitle = Timer(const Duration(milliseconds: 600), () {
              if (query.length > 2) {
                context.read<WorkoutBloc>().add(
                  UpdateWorkoutDetails(title: query),
                );
              }
            });
          },
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
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: AppColors.containerBorderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.black54),
            SizedBox(height: 6),
            Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(
          color: AppColors.containerBorderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _noteController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: Colors.black87,
          style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
          decoration: InputDecoration(
            hintText: "Notes...",
            hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            _debounceNote?.cancel();
            _debounceNote = Timer(const Duration(milliseconds: 600), () {
              context.read<WorkoutBloc>().add(
                UpdateWorkoutDetails(note: value),
              );
            });
          },
        ),
      ),
    );
  }
}
