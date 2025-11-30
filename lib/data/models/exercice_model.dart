import 'package:workout_app/data/entities/exercice_entity.dart';

class ExerciceModel extends ExerciceEntity {
  ExerciceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl
  });

  factory ExerciceModel.fromEntity(ExerciceEntity entity) {
    return ExerciceModel(
      id: entity.id, 
      name: entity.name, 
      description: entity.description,
      imageUrl: entity.imageUrl
      );
  }

  factory ExerciceModel.fromJson(Map<String, dynamic> json) {
    return ExerciceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl']
    );
  }

   Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "imageUrl": imageUrl
  };
}