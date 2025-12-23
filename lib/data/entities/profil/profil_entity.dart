import 'package:hive_flutter/adapters.dart';

part 'profil_entity.g.dart';

@HiveType(typeId: 3)
class ProfilEntity {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String gender;
  @HiveField(2)
  final int age;
  @HiveField(3)
  final double weight;
  @HiveField(4)
  final int height;

  ProfilEntity(this.name, this.gender, this.age, this.weight, this.height);

  const ProfilEntity.empty()
    : name = '',
      gender = '',
      age = 0,
      weight = 0.0,
      height = 0;

  bool get isEmpty => name.isEmpty && age == 0 && weight == 0.0;

  // UI helpers
  String get displayName => isEmpty ? '?' : name;
  String get displayAge => age == 0 ? '?' : '$age';
  String get displayWeight => weight == 0 ? '?' : '$weight';
  String get displayHeight => height == 0 ? '?' : '$height';

  ProfilEntity copyWith({
    String? name,
    String? gender,
    int? age,
    double? weight,
    int? height,
  }) {
    return ProfilEntity(
      name ?? this.name,
      gender ?? this.gender,
      age ?? this.age,
      weight ?? this.weight,
      height ?? this.height,
    );
  }
}
