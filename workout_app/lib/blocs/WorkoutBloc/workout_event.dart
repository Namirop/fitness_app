import 'package:workout_app/data/entities/workout/exercise_entity.dart';
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

class SetSelectedCalendarDate extends WorkoutEvent {
  final DateTime date;
  SetSelectedCalendarDate(this.date);
}

class SetEditingWorkout extends WorkoutEvent {
  final bool isEditingMode;
  final WorkoutEntity? workout;
  SetEditingWorkout({required this.isEditingMode, this.workout});
}

// CACHE MANAGEMENT
class HasCache extends WorkoutEvent {
  HasCache();
}

class NewCache extends WorkoutEvent {}

// EXERCISE MANAGEMENT
class SearchExercises extends WorkoutEvent {
  final String query;
  SearchExercises(this.query);
}

class AddExercise extends WorkoutEvent {
  final ExerciseEntity exercise;
  AddExercise({required this.exercise});
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

// OTHER
class ResetToEmptyWorkout extends WorkoutEvent {}
