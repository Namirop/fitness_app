import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/models/workout/workout_exercise_model.dart';

class WorkoutModel extends WorkoutEntity {
  WorkoutModel({
    required super.id,
    required super.title,
    required super.note,
    required super.date,
    required super.exercises,
  });

  factory WorkoutModel.fromEntity(WorkoutEntity entity) {
    return WorkoutModel(
      id: entity.id,
      title: entity.title,
      note: entity.note,
      date: entity.date,
      exercises: entity.exercises,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'].toString(),
      title: json['title'].toString(),
      note: json['note'].toString(),
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((ex) => WorkoutExerciseModel.fromJson(ex))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date.toUtc().toIso8601String(),
      'exercises': exercises
          .map((ex) => WorkoutExerciseModel.fromEntity(ex).toJson())
          .toList(),
    };
  }
}
