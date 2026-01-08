import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/data/models/workout/exercise_model.dart';

class WorkoutExerciseModel extends WorkoutExerciseEntity {
  WorkoutExerciseModel({
    required super.exercise,
    required super.sets,
    required super.reps,
    required super.weight,
  });

  factory WorkoutExerciseModel.fromEntity(WorkoutExerciseEntity entity) {
    return WorkoutExerciseModel(
      exercise: entity.exercise,
      sets: entity.sets,
      reps: entity.reps,
      weight: entity.weight,
    );
  }

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      exercise: ExerciseModel.fromJson(json['exercise']),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "exercise": ExerciseModel.fromEntity(exercise).toJson(),
    "sets": sets,
    "reps": reps,
    "weight": weight,
  };
}
