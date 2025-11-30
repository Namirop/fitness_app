import 'package:workout_app/data/entities/workout_entity.dart';

abstract class WorkoutEvent {}

class GetExistingWorkouts extends WorkoutEvent {}
class AddWorkout extends WorkoutEvent {}
class UpdateWorkoutDetails extends WorkoutEvent {
  final String? title;
  final String? note;
  final DateTime? date;
  UpdateWorkoutDetails({
    this.title,
    this.note,
    this.date
  });
}
class DeleteWorkout extends WorkoutEvent {
  final WorkoutEntity workout;
  DeleteWorkout(this.workout);
}
class DeleteAllWorkouts extends WorkoutEvent {}

class FetchExercices extends WorkoutEvent {
  final String query;
  FetchExercices(this.query);
}

class HasCache extends WorkoutEvent {}
class ResumeCache extends WorkoutEvent {}
class NewCache extends WorkoutEvent {}


class AddExerciseToCache extends WorkoutEvent {
  final String exerciseId;
  AddExerciseToCache(this.exerciseId);
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
    this.weight
  });
}
class RemoveExercise extends WorkoutEvent {
  final String exerciseId;
  RemoveExercise(this.exerciseId);
}
