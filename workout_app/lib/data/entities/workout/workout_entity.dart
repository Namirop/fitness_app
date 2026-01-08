import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
part 'g.dart/workout_entity.g.dart';

@HiveType(typeId: 1)
class WorkoutEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String note;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final List<WorkoutExerciseEntity> exercises;

  WorkoutEntity({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.exercises,
  });

  factory WorkoutEntity.empty() {
    return WorkoutEntity(
      id: '',
      title: '',
      note: '',
      date: DateTime.now(),
      exercises: [],
    );
  }
  WorkoutEntity copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? date,
    List<WorkoutExerciseEntity>? exercises,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
    );
  }
}
