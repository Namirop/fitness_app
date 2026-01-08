import 'package:workout_app/data/entities/workout/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.videoUrl,
  });

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      description: json['description'].toString(),
      imageUrl: json['imageUrl'].toString(),
      videoUrl: json['videoUrl'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "imageUrl": imageUrl,
    "videoUrl": videoUrl,
  };
}
