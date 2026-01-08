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
  @HiveField(5)
  final double caloriesTarget;
  @HiveField(6)
  final double carbsTarget;
  @HiveField(7)
  final double proteinsTarget;
  @HiveField(8)
  final double fatsTarget;
  @HiveField(9)
  final String activityLevel;
  @HiveField(10)
  final String goal;
  @HiveField(11)
  final String id;

  ProfilEntity({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.caloriesTarget,
    required this.carbsTarget,
    required this.proteinsTarget,
    required this.fatsTarget,
    required this.activityLevel,
    required this.goal,
  });

  factory ProfilEntity.empty() {
    return ProfilEntity(
      id: '',
      name: '',
      gender: '',
      age: 0,
      weight: 0.0,
      height: 0,
      caloriesTarget: 0.0,
      carbsTarget: 0.0,
      proteinsTarget: 0.0,
      fatsTarget: 0.0,
      activityLevel: '',
      goal: '',
    );
  }

  ProfilEntity copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    double? weight,
    int? height,
    double? caloriesTarget,
    double? carbsTarget,
    double? proteinsTarget,
    double? fatsTarget,
    String? activityLevel,
    String? goal,
  }) {
    return ProfilEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      proteinsTarget: proteinsTarget ?? this.proteinsTarget,
      fatsTarget: fatsTarget ?? this.fatsTarget,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  bool get isEmpty =>
      name.isEmpty &&
      gender.isEmpty &&
      age == 0 &&
      weight == 0.0 &&
      height == 0;

  String get displayName => isEmpty ? 'User' : name;
  String get displayGender => isEmpty ? 'Femme' : gender;
  String get displayAge => isEmpty ? '30' : '$age';
  String get displayWeight => isEmpty ? '55' : '$weight';
  String get displayHeight => isEmpty ? '160' : '$height';
  String get displayCaloriesTarget => '${caloriesTarget.round()}';
  String get displayCarbsTarget => '${carbsTarget.round()}';
  String get displayProteinsTarget => '${proteinsTarget.round()}';
  String get displayFatsTarget => '${fatsTarget.round()}';
}
