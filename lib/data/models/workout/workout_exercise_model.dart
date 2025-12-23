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

  Map<String, dynamic> toJson() => {
    "exercice": ExerciseModel.fromEntity(exercise).toJson(),
    "sets": sets,
    "reps": reps,
    "weight": weight,
  };

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      exercise: ExerciseModel.fromJson(json['exercice']),
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'],
    );
  }
}
