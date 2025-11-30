import 'package:workout_app/data/entities/workout_exercice_entity.dart';
import 'package:workout_app/data/models/exercice_model.dart';

class WorkoutExerciceModel extends WorkoutExerciceEntity {
  WorkoutExerciceModel({
    required super.exercise,
    required super.sets,
    required super.reps,
    required super.weight,
  });

  factory WorkoutExerciceModel.fromEntity(WorkoutExerciceEntity entity) {
    return WorkoutExerciceModel(
      exercise: entity.exercise, 
      sets: entity.sets, 
      reps: entity.reps, 
      weight: entity.weight
    );
  }

  Map<String, dynamic> toJson() => {
    "exercice": ExerciceModel.fromEntity(exercise).toJson(),
    "sets": sets,
    "reps": reps,
    "weight": weight
  };

  factory WorkoutExerciceModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciceModel(
      exercise: ExerciceModel.fromJson(json['exercice']), 
      sets: json['sets'], 
      reps: json['reps'], 
      weight: json['weight']
    );
  }
}