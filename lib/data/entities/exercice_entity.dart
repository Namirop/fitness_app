import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'g.dart/exercice_entity.g.dart';

@HiveType(typeId: 0)
class ExerciceEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String imageUrl;

  ExerciceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  static final empty = ExerciceEntity(
    id: const Uuid().v1(),
    name: '',
    description: '',
    imageUrl: '',
  );
}
