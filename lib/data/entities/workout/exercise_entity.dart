import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'g.dart/exercise_entity.g.dart';

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

  ExerciseEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory ExerciseEntity.empty() {
    return ExerciseEntity(
      id: const Uuid().v1(),
      name: '',
      description: '',
      imageUrl: '',
    );
  }
}
