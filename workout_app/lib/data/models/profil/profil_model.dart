import 'package:workout_app/data/entities/profil/profil_entity.dart';

class ProfilModel extends ProfilEntity {
  ProfilModel({
    required super.id,
    required super.name,
    required super.gender,
    required super.age,
    required super.weight,
    required super.height,
    required super.caloriesTarget,
    required super.carbsTarget,
    required super.proteinsTarget,
    required super.fatsTarget,
    required super.activityLevel,
    required super.goal,
  });

  factory ProfilModel.fromEntity(ProfilEntity entity) {
    return ProfilModel(
      id: entity.id,
      name: entity.name,
      gender: entity.gender,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      caloriesTarget: entity.caloriesTarget,
      carbsTarget: entity.carbsTarget,
      proteinsTarget: entity.proteinsTarget,
      fatsTarget: entity.fatsTarget,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
    );
  }

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      gender: json['gender'].toString(),
      age: (json['age'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toInt(),
      caloriesTarget: (json['caloriesTarget'] as num).toDouble(),
      carbsTarget: (json['carbsTarget'] as num).toDouble(),
      proteinsTarget: (json['proteinsTarget'] as num).toDouble(),
      fatsTarget: (json['fatsTarget'] as num).toDouble(),
      activityLevel: json['activityLevel'].toString(),
      goal: json['goal'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'caloriesTarget': caloriesTarget,
      'carbsTarget': carbsTarget,
      'proteinsTarget': proteinsTarget,
      'fatsTarget': fatsTarget,
      'activityLevel': activityLevel,
      'goal': goal,
    };
  }
}
