import 'package:hive_flutter/adapters.dart';

part 'exercise_entity.g.dart';

@HiveType(typeId: 0)
class ExerciseEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String imageUrl;
  @HiveField(4)
  final String? videoUrl;

  ExerciseEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
  });

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? videoUrl,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
