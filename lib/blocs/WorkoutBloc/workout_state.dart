import 'package:workout_app/data/entities/exercice_preview_entity.dart';
import 'package:workout_app/data/entities/workout_entity.dart';

// 'WorkoutState' est le state de base pour tous les states liés aux workouts.
// Tous les states portent une référence au workout actuel (nullable)
// Cela permet au BLoC d'accéder à `state.workout` dans n'importe quel handler, sans avoir à caster ou vérifier le type du state.
// Voir PDF pour rappel sur classe abstraite et leur lien avec les states
abstract class WorkoutState {
  final WorkoutEntity? workout;
  WorkoutState({this.workout});
}

/// State initial (aucune opération en cours)
final class WorkoutInitialState extends WorkoutState {
  WorkoutInitialState() : super(workout: null);
}

// ============================================================================
// STATES POUR LA GESTION DU CACHE (création de workout en cours)
// ============================================================================

final class CacheLoading extends WorkoutState {
  CacheLoading({WorkoutEntity? workout}) : super(workout: workout);
}

final class CacheFound extends WorkoutState {
  CacheFound(WorkoutEntity workout) : super(workout: workout);
}

final class CacheReady extends WorkoutState {
  CacheReady(WorkoutEntity workout) : super(workout: workout);
}

final class CacheFailure extends WorkoutState {
  final String message;
  CacheFailure(this.message, {WorkoutEntity? workout}) : super(workout: workout);
}

// ============================================================================
// STATES POUR RÉCUPÉRER LES WORKOUTS EXISTANTS (historique)
// ============================================================================

final class GetExistingWorkoutsLoading extends WorkoutState {
  GetExistingWorkoutsLoading({WorkoutEntity? workout}) : super(workout: workout);
}

final class GetExistingWorkoutsSuccess extends WorkoutState {
  final List<WorkoutEntity> workouts;
  
  GetExistingWorkoutsSuccess(
    this.workouts, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

final class GetExistingWorkoutsFailure extends WorkoutState {
  final String message;
  
  GetExistingWorkoutsFailure(
    this.message, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

// ============================================================================
// STATES POUR LA RECHERCHE D'EXERCICES
// ============================================================================

final class FetchExercicesLoading extends WorkoutState {
  FetchExercicesLoading({WorkoutEntity? workout}) : super(workout: workout);
}

final class FetchExercicesSuccess extends WorkoutState {
  final List<ExercisePreviewEntity> exercices;
  
  FetchExercicesSuccess(
    this.exercices, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

final class FetchExercicesFailure extends WorkoutState {
  final String message;
  
  FetchExercicesFailure(
    this.message, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

// ============================================================================
// STATES POUR SAUVEGARDER LE WORKOUT (envoi vers l'API)
// ============================================================================

final class AddWorkoutLoading extends WorkoutState {
  AddWorkoutLoading({WorkoutEntity? workout}) : super(workout: workout);
}

final class AddWorkoutSuccess extends WorkoutState {
  AddWorkoutSuccess({WorkoutEntity? workout}) : super(workout: workout);
}

final class AddWorkoutFailure extends WorkoutState {
  final String message;
  
  AddWorkoutFailure(
    this.message, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

// ============================================================================
// STATES POUR SUPPRIMER UN WORKOUT
// ============================================================================

final class DeleteWorkoutLoading extends WorkoutState {
  DeleteWorkoutLoading({WorkoutEntity? workout}) : super(workout: workout);
}

final class DeleteWorkoutSuccess extends WorkoutState {
  DeleteWorkoutSuccess({WorkoutEntity? workout}) : super(workout: workout);
}

final class DeleteWorkoutFailure extends WorkoutState {
  final String message;
  
  DeleteWorkoutFailure(
    this.message, {
    WorkoutEntity? workout,
  }) : super(workout: workout);
}

// ============================================================================
// STATES POUR VERIRICATION VALIDATION WORKOUT
// ============================================================================

final class WorkoutValidationError extends WorkoutState {
  final String message;
  WorkoutValidationError(this.message, {WorkoutEntity? workout}) 
    : super(workout: workout);
}

// ============================================================================
// STATES POUR CONFIRMATION WORKOUT
// ============================================================================

final class SavingWorkout extends WorkoutState {
  SavingWorkout({WorkoutEntity? workout}) : super(workout: workout);
}

final class WorkoutSaved extends WorkoutState {
  final String message;
  WorkoutSaved(this.message, {WorkoutEntity? workout}) 
    : super(workout: workout);
}

final class WorkoutSavedError extends WorkoutState {
  final String message;
  WorkoutSavedError(this.message, {WorkoutEntity? workout}) 
    : super(workout: workout);
}