import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/workout/exercise_preview_entity.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';

// ============================================================================
// ENUMS POUR DIFFÉRENCIER LES ÉTATS
// ============================================================================

/// État du cache (création/édition de workout en cours)
enum CacheStatus {
  initial, // Pas encore chargé
  loading, // En train de vérifier le cache
  found, // Cache trouvé
  ready, // Prêt à éditer/émettre
  failure, // Erreur lors du chargement du cache
}

// État de la liste des workouts existants
enum ExistingWorkoutsStatus {
  initial, // Pas encore chargé
  loading, // En train de charger depuis l'API
  success, // Chargé avec succès
  failure, // Erreur lors du chargement
}

/// État de la suppression d'un workout
enum DeleteWorkoutStatus {
  initial, // Aucune suppression en cours
  loading, // En train de supprimer
  success, // Supprimé avec succès
  failure, // Erreur lors de la suppression
}

/// État de la recherche d'exercices
enum FetchExercisesStatus {
  initial, // Pas de recherche
  loading, // En train de chercher
  success, // Exercices trouvés
  failure, // Erreur lors de la recherche
}

/// État de la sauvegarde du workout (validation + envoi API)
enum SaveWorkoutStatus {
  initial, // Pas de sauvegarde en cours
  validating, // En train de valider les données
  saving, // En train de sauvegarder (appel API)
  success, // Sauvegardé avec succès
  failure, // Erreur lors de la sauvegarde
}

enum UpdateWorkoutStatus { initial, loading, success, failure }

// ============================================================================
// STATE UNIQUE
// ============================================================================

class WorkoutState extends Equatable {
  final CacheStatus cacheStatus;
  final WorkoutEntity currentWorkout;
  final String? cacheSuccessString;
  final String? cacheErrorString;
  final bool isEditingMode;

  final ExistingWorkoutsStatus existingWorkoutsStatus;
  final List<WorkoutEntity> existingWorkouts;
  final String? existingWorkoutsSuccessString;
  final String? existingWorkoutsErrorString;

  final DeleteWorkoutStatus deleteWorkoutStatus;
  final WorkoutEntity? deletedWorkout;
  final String? deleteWorkoutSuccessString;
  final String? deleteWorkoutErrorString;

  final FetchExercisesStatus fetchExercisesStatus;
  final List<ExercisePreviewEntity> exercises;
  final String? fetchExercisesSuccessString;
  final String? fetchExercisesErrorString;

  final SaveWorkoutStatus saveWorkoutStatus;
  final WorkoutEntity? savedWorkout;
  final String? saveWorkoutErrorString;
  final String? saveWorkoutSuccessString;

  final UpdateWorkoutStatus updateWorkoutStatus;
  final WorkoutEntity? updatedWorkout;
  final String? updateWorkoutSuccessString;
  final String? updateWorkoutErrorString;

  const WorkoutState({
    this.cacheStatus = CacheStatus.initial,
    this.cacheSuccessString,
    required this.currentWorkout,
    this.cacheErrorString,
    this.isEditingMode = false,

    this.existingWorkoutsStatus = ExistingWorkoutsStatus.initial,
    this.existingWorkouts = const [],
    this.existingWorkoutsSuccessString,
    this.existingWorkoutsErrorString,

    this.deleteWorkoutStatus = DeleteWorkoutStatus.initial,
    this.deletedWorkout,
    this.deleteWorkoutSuccessString,
    this.deleteWorkoutErrorString,

    this.fetchExercisesStatus = FetchExercisesStatus.initial,
    this.exercises = const [],
    this.fetchExercisesSuccessString,
    this.fetchExercisesErrorString,

    this.saveWorkoutStatus = SaveWorkoutStatus.initial,
    this.savedWorkout,
    this.saveWorkoutSuccessString,
    this.saveWorkoutErrorString,

    this.updateWorkoutStatus = UpdateWorkoutStatus.initial,
    this.updatedWorkout,
    this.updateWorkoutSuccessString,
    this.updateWorkoutErrorString,
  });

  WorkoutState copyWith({
    // Cache
    CacheStatus? cacheStatus,
    WorkoutEntity? currentWorkout,
    String? cacheSuccessString,
    String? cacheErrorString,
    bool? isEditingMode,

    // Liste workouts existants
    ExistingWorkoutsStatus? existingWorkoutsStatus,
    List<WorkoutEntity>? existingWorkouts,
    String? existingWorkoutsSuccessString,
    String? existingWorkoutsErrorString,

    // Suppression
    DeleteWorkoutStatus? deleteWorkoutStatus,
    WorkoutEntity? deletedWorkout,
    String? deleteWorkoutSuccessString,
    String? deleteWorkoutErrorString,

    // Recherche exercices
    FetchExercisesStatus? fetchExercisesStatus,
    List<ExercisePreviewEntity>? exercises,
    String? fetchExercisesSuccessString,
    String? fetchExercisesErrorString,

    // Sauvegarde
    SaveWorkoutStatus? saveWorkoutStatus,
    WorkoutEntity? updatedWorkout,
    String? saveWorkoutSuccessString,
    String? saveWorkoutErrorString,
  }) {
    return WorkoutState(
      // Cache
      cacheStatus: cacheStatus ?? this.cacheStatus,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      cacheSuccessString: cacheSuccessString,
      cacheErrorString:
          cacheErrorString, // Pas de ?? pour permettre de reset à null
      isEditingMode: isEditingMode ?? this.isEditingMode,

      existingWorkoutsStatus:
          existingWorkoutsStatus ?? this.existingWorkoutsStatus,
      existingWorkouts: existingWorkouts ?? this.existingWorkouts,
      existingWorkoutsSuccessString: existingWorkoutsSuccessString,
      existingWorkoutsErrorString: existingWorkoutsErrorString,

      deleteWorkoutStatus: deleteWorkoutStatus ?? this.deleteWorkoutStatus,
      deletedWorkout: deletedWorkout ?? this.deletedWorkout,
      deleteWorkoutSuccessString: deleteWorkoutSuccessString,
      deleteWorkoutErrorString: deleteWorkoutErrorString,

      fetchExercisesStatus: fetchExercisesStatus ?? this.fetchExercisesStatus,
      exercises: exercises ?? this.exercises,
      fetchExercisesSuccessString: fetchExercisesSuccessString,
      fetchExercisesErrorString: fetchExercisesErrorString,

      saveWorkoutStatus: saveWorkoutStatus ?? this.saveWorkoutStatus,
      savedWorkout: savedWorkout ?? this.savedWorkout,
      saveWorkoutSuccessString: saveWorkoutSuccessString,
      saveWorkoutErrorString: saveWorkoutErrorString,
    );
  }

  Set<DateTime> get workoutDays {
    return existingWorkouts.map((w) {
      return DateTime(w.date.year, w.date.month, w.date.day);
    }).toSet();
  }

  WorkoutEntity? getWorkoutForDate(DateTime date) {
    return existingWorkouts.firstWhereOrNull(
      (w) =>
          w.date.year == date.year &&
          w.date.month == date.month &&
          w.date.day == date.day,
    );
  }

  @override
  List<Object?> get props => [
    // Cache
    cacheStatus,
    currentWorkout,
    cacheSuccessString,
    cacheErrorString,
    isEditingMode,

    // Liste workouts existants
    existingWorkoutsStatus,
    existingWorkouts,
    existingWorkoutsSuccessString,
    existingWorkoutsErrorString,

    // Suppression
    deleteWorkoutStatus,
    deletedWorkout,
    deleteWorkoutSuccessString,
    deleteWorkoutErrorString,

    // Recherche exercices
    fetchExercisesStatus,
    exercises,
    fetchExercisesSuccessString,
    fetchExercisesErrorString,

    // Sauvegarde
    saveWorkoutStatus,
    savedWorkout,
    saveWorkoutSuccessString,
    saveWorkoutErrorString,
  ];
}
