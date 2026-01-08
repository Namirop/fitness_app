// Service responsable de la gestion du cache local des workouts via Hive.
// Responsabilités :
// - Sauvegarder/récupérer le workout en cours de création
// - Nettoyer le cache

import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';

class WorkoutCacheService {
  final Box<WorkoutEntity> _box;

  WorkoutCacheService(this._box);

  // Permet de récupérer le workout en cours
  // Retourne null si pas de workout en cours
  WorkoutEntity? getCachedWorkout() {
    return _box.get("current");
  }

  // Un put sur la box est une opération async donc renvoie par logique un Future<void>
  Future<void> saveCachedWorkout(WorkoutEntity workout) async {
    await _box.put("current", workout);
  }

  Future<void> clearCachedWorkout() async {
    await _box.delete("current");
  }
}
