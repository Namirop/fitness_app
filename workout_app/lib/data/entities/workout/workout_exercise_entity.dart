import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/workout/exercise_entity.dart';
part 'workout_exercise_entity.g.dart';

@HiveType(typeId: 2)
class WorkoutExerciseEntity {
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
