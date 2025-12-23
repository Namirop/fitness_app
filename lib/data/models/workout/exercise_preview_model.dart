import 'package:workout_app/data/entities/workout/exercise_preview_entity.dart';

class ExercisePreviewModel extends ExercisePreviewEntity {
  ExercisePreviewModel({
    required super.exerciseId,
    required super.name,
    required super.imageUrl,
  });

  factory ExercisePreviewModel.fromJson(Map<String, dynamic> json) {
    return ExercisePreviewModel(
      exerciseId: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
