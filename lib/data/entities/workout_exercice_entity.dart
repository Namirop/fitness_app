import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/exercice_entity.dart';

part 'g.dart/workout_exercice_entity.g.dart';

@HiveType(typeId: 2)
class WorkoutExerciceEntity {
  // On connait le workout lié à cette exercice, donc pas besoin d'un champs "WorkoutEntity workout"
  @HiveField(0)
  final ExerciceEntity exercise;
  @HiveField(1)
  final int sets;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final int weight;

  const WorkoutExerciceEntity({
    required this.exercise,
    this.sets = 3,
    this.reps = 10,
    this.weight = 20,
  });

  static final empty = WorkoutExerciceEntity(
    exercise: ExerciceEntity.empty
  );

  WorkoutExerciceEntity copyWith({
    ExerciceEntity? exercise,
    int? sets,
    int? reps,
    int? weight,
  }) {
    return WorkoutExerciceEntity(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
  
}