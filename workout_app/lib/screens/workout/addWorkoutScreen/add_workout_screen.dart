import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/core/utils/dialog_helper.dart';
import 'package:workout_app/core/utils/snackbar_helper.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/widgets/exercise_details_container.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/widgets/exercise_list_container.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/widgets/workout_details_container.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  int? _selectedExerciseIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutBloc>().add(HasCache());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.submitWorkoutStatus != current.submitWorkoutStatus ||
          previous.cacheStatus != current.cacheStatus ||
          previous.deleteWorkoutStatus != current.deleteWorkoutStatus,
      listener: (context, state) async {
        await _handleStateChanges(state);
      },
      builder: (context, state) {
        final workout = state.currentWorkout;
        final exerciseToDisplay = workout.exercises;
        final isSavingOrLoading =
            state.cacheStatus == CacheStatus.loading ||
            state.submitWorkoutStatus == SubmitWorkoutStatus.saving;
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.screenBackground),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Transform.scale(
                                scaleY: 1.15,
                                child: Text(
                                  state.isEditingMode
                                      ? 'MODIFIER LE WORKOUT : '
                                      : 'AJOUTER UN WORKOUT :',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      56,
                                      54,
                                      54,
                                    ),
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                            if (state.isEditingMode)
                              CustomIcon(
                                onTap: () async {
                                  final confirm =
                                      await DialogHelper.showConfirmDialog(
                                        context,
                                        title: "Supprimer le workout actuel ?",
                                        confirmText: "Oui, supprimer",
                                        cancelText: "Non, garder",
                                      );
                                  if (confirm == true && mounted) {
                                    context.read<WorkoutBloc>().add(
                                      DeleteWorkout(workout),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                                size: 30,
                                color: Colors.transparent,
                                icon: Icon(
                                  Icons.delete,
                                  size: 36,
                                  color: const Color.fromARGB(255, 224, 96, 87),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 15),
                        WorkoutDetailsContainer(
                          workout: workout,
                          workoutDays: state.workoutDays,
                          isSavingOrLoading: isSavingOrLoading,
                        ),
                        SizedBox(height: 10),
                        ExerciseListContainer(
                          exercises: exerciseToDisplay,
                          selectedIndex: _selectedExerciseIndex,
                          onSelectionChanged: (index) {
                            setState(() => _selectedExerciseIndex = index);
                          },
                          isSavingOrLoading: isSavingOrLoading,
                        ),
                        SizedBox(height: 10),
                        ExerciseDetailsContainer(
                          exercise:
                              _selectedExerciseIndex != null &&
                                  _selectedExerciseIndex! <
                                      exerciseToDisplay.length
                              ? exerciseToDisplay[_selectedExerciseIndex!]
                              : null,
                          exerciseIndex: _selectedExerciseIndex,
                          isSavingOrLoading: isSavingOrLoading,
                        ),
                        SizedBox(height: 15),
                        _buildSubmitButton(
                          state.isEditingMode,
                          state.submitWorkoutStatus ==
                              SubmitWorkoutStatus.saving,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(bool isEditing, bool isSaving) {
    return GestureDetector(
      onTap: () {
        context.read<WorkoutBloc>().add(SubmitWorkout());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          color: AppColors.buttonColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: isSaving
              ? SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.containerBorderColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIcon(
                      topPadding: 2,
                      icon: Icon(isEditing ? Icons.edit : Icons.add, size: 25),
                      size: 35,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isEditing ? "MODIFIER" : "AJOUTER",
                      style: TextStyle(fontSize: 35, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleStateChanges(WorkoutState state) async {
    if (!mounted) return;
    if (state.cacheStatus == CacheStatus.found) {
      final resume = await DialogHelper.showConfirmDialog(
        context,
        title: "Reprendre le workout en cours ?",
        confirmText: "Oui, reprendre",
        cancelText: "Non, nouveau",
      );
      setState(
        () => _selectedExerciseIndex = null,
      ); // to avoid invalid index errors, and therefore UI display errors.
      if (resume == false) {
        context.read<WorkoutBloc>().add(NewCache());
      }
    }
    if (state.cacheStatus == CacheStatus.failure) {
      SnackbarHelper.showError(
        context,
        state.cacheErrorString ?? 'Erreur cache',
      );
    }
    if (state.submitWorkoutStatus == SubmitWorkoutStatus.success) {
      SnackbarHelper.showSuccess(
        context,
        state.saveWorkoutSuccessString ?? 'Ajout validé',
      );
      // Allows you to return to MainScreen regardless of where you open this page.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (state.submitWorkoutStatus == SubmitWorkoutStatus.failure) {
      SnackbarHelper.showError(
        context,
        state.saveWorkoutErrorString ?? 'Erreur ajout',
      );
    }

    if (state.deleteWorkoutStatus == DeleteWorkoutStatus.success) {
      SnackbarHelper.showSuccess(
        context,
        state.deleteWorkoutSuccessString ?? 'Suppresion validé',
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (state.deleteWorkoutStatus == DeleteWorkoutStatus.failure) {
      SnackbarHelper.showError(
        context,
        state.deleteWorkoutErrorString ?? 'Erreur suppresion',
      );
    }
  }
}
