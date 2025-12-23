import 'package:workout_app/data/entities/workout/workout_entity.dart';

abstract class WorkoutEvent {}

// WORKOUT MANAGEMENT
class GetExistingWorkouts extends WorkoutEvent {}

class SubmitWorkout extends WorkoutEvent {}

class UpdateWorkoutDetails extends WorkoutEvent {
  final String? title;
  final String? note;
  final DateTime? date;
  UpdateWorkoutDetails({this.title, this.note, this.date});
}

class DeleteWorkout extends WorkoutEvent {
  final WorkoutEntity workout;
  DeleteWorkout(this.workout);
}

class DeleteAllWorkouts extends WorkoutEvent {}

// CACHE MANAGEMENT
class HasCache extends WorkoutEvent {
  final DateTime? initialDate;
  HasCache(this.initialDate);
}

class ResumeCache extends WorkoutEvent {}

class NewCache extends WorkoutEvent {}

// EXERCISE MANAGEMENT
class AddExercise extends WorkoutEvent {
  final String exerciseId;
  AddExercise({required this.exerciseId});
}

class UpdateExerciseDetails extends WorkoutEvent {
  final int exIndex;
  final int? sets;
  final int? reps;
  final int? weight;
  UpdateExerciseDetails({
    required this.exIndex,
    this.sets,
    this.reps,
    this.weight,
  });
}

class RemoveExercise extends WorkoutEvent {
  final String exerciseId;
  RemoveExercise({required this.exerciseId});
}

class FetchExercises extends WorkoutEvent {
  final String query;
  FetchExercises(this.query);
}

// RESET STATUS
class ResetSaveStatus extends WorkoutEvent {}

class ResetDeleteStatus extends WorkoutEvent {}

class ResetExistingWorkoutStatus extends WorkoutEvent {}

// MISCELLANEOUS
class ResetToEmptyWorkout extends WorkoutEvent {}

class LoadWorkoutForEdit extends WorkoutEvent {
  final WorkoutEntity workoutToEdit;
  LoadWorkoutForEdit(this.workoutToEdit);
}
