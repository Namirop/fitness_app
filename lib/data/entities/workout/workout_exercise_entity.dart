import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/workout/exercise_entity.dart';

part 'g.dart/workout_exercice_entity.g.dart';

@HiveType(typeId: 2)
class WorkoutExerciseEntity {
  // On connait le workout lié à cette exercice, donc pas besoin d'un champs "WorkoutEntity workout"
  @HiveField(0)
  final ExerciseEntity exercise;
  @HiveField(1)
  final int sets;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final int weight;

  const WorkoutExerciseEntity({
    required this.exercise,
    this.sets = 3,
    this.reps = 10,
    this.weight = 20,
  });

  factory WorkoutExerciseEntity.empty() {
    return WorkoutExerciseEntity(exercise: ExerciseEntity.empty());
  }

  WorkoutExerciseEntity copyWith({
    ExerciseEntity? exercise,
    int? sets,
    int? reps,
    int? weight,
  }) {
    return WorkoutExerciseEntity(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
}
