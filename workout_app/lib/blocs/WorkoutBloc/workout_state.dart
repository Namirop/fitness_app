import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/workout/exercise_entity.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';

// ============================================================================
// ENUMS POUR DIFFÉRENCIER LES ÉTATS
// ============================================================================

enum CacheStatus { initial, loading, found, ready, failure }

enum ExistingWorkoutsStatus { initial, loading, success, failure }

enum SearchExercisesStatus { initial, loading, success, failure }

enum SubmitWorkoutStatus { initial, saving, success, failure }

enum DeleteWorkoutStatus { initial, loading, success, failure }

// ============================================================================
// STATE UNIQUE
// ============================================================================

class WorkoutState extends Equatable {
  final CacheStatus cacheStatus;
  final WorkoutEntity
  currentWorkout; // Workout en cours d'ajout, ou en cours d'édition
  final String? cacheSuccessString;
  final String? cacheErrorString;
  final bool isEditingMode;

  final DateTime selectedCalendarDate;

  final ExistingWorkoutsStatus existingWorkoutsStatus;
  final List<WorkoutEntity> existingWorkouts;
  final String? existingWorkoutsErrorString;

  final SearchExercisesStatus searchExercisesStatus;
  final List<ExerciseEntity> exercisesList;
  final String? fetchExercisesErrorString;

  final SubmitWorkoutStatus submitWorkoutStatus;
  final String? saveWorkoutErrorString;
  final String? saveWorkoutSuccessString;

  final DeleteWorkoutStatus deleteWorkoutStatus;
  final String? deleteWorkoutSuccessString;
  final String? deleteWorkoutErrorString;

  const WorkoutState({
    this.cacheStatus = CacheStatus.initial,
    required this.currentWorkout,
    this.cacheSuccessString,
    this.cacheErrorString,
    this.isEditingMode = false,

    required this.selectedCalendarDate,

    this.existingWorkoutsStatus = ExistingWorkoutsStatus.initial,
    this.existingWorkouts = const [],
    this.existingWorkoutsErrorString,

    this.searchExercisesStatus = SearchExercisesStatus.initial,
    this.exercisesList = const [],
    this.fetchExercisesErrorString,

    this.submitWorkoutStatus = SubmitWorkoutStatus.initial,
    this.saveWorkoutSuccessString,
    this.saveWorkoutErrorString,

    this.deleteWorkoutStatus = DeleteWorkoutStatus.initial,
    this.deleteWorkoutSuccessString,
    this.deleteWorkoutErrorString,
  });

  WorkoutState copyWith({
    CacheStatus? cacheStatus,
    WorkoutEntity? currentWorkout,
    String? cacheSuccessString,
    String? cacheErrorString,
    bool? isEditingMode,

    DateTime? selectedCalendarDate,

    ExistingWorkoutsStatus? existingWorkoutsStatus,
    List<WorkoutEntity>? existingWorkouts,
    String? existingWorkoutsErrorString,

    SearchExercisesStatus? searchExercisesStatus,
    List<ExerciseEntity>? exercisesList,
    String? fetchExercisesErrorString,

    SubmitWorkoutStatus? submitWorkoutStatus,
    String? saveWorkoutSuccessString,
    String? saveWorkoutErrorString,

    DeleteWorkoutStatus? deleteWorkoutStatus,
    String? deleteWorkoutSuccessString,
    String? deleteWorkoutErrorString,
  }) {
    return WorkoutState(
      cacheStatus: cacheStatus ?? this.cacheStatus,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      isEditingMode: isEditingMode ?? this.isEditingMode,
      cacheSuccessString: cacheSuccessString,
      cacheErrorString: cacheErrorString,

      selectedCalendarDate: selectedCalendarDate ?? this.selectedCalendarDate,

      existingWorkoutsStatus:
          existingWorkoutsStatus ?? this.existingWorkoutsStatus,
      existingWorkouts: existingWorkouts ?? this.existingWorkouts,
      existingWorkoutsErrorString: existingWorkoutsErrorString,

      searchExercisesStatus:
          searchExercisesStatus ?? this.searchExercisesStatus,
      exercisesList: exercisesList ?? this.exercisesList,
      fetchExercisesErrorString: fetchExercisesErrorString,

      submitWorkoutStatus: submitWorkoutStatus ?? this.submitWorkoutStatus,
      saveWorkoutSuccessString: saveWorkoutSuccessString,
      saveWorkoutErrorString: saveWorkoutErrorString,

      deleteWorkoutStatus: deleteWorkoutStatus ?? this.deleteWorkoutStatus,
      deleteWorkoutSuccessString: deleteWorkoutSuccessString,
      deleteWorkoutErrorString: deleteWorkoutErrorString,
    );
  }

  Set<DateTime> get workoutDays {
    return existingWorkouts.map((w) {
      return DateTime(w.date.year, w.date.month, w.date.day);
    }).toSet();
  }

  WorkoutEntity? get getWorkoutForTheSelectedDate {
    return existingWorkouts.firstWhereOrNull(
      (w) =>
          w.date.year == selectedCalendarDate.year &&
          w.date.month == selectedCalendarDate.month &&
          w.date.day == selectedCalendarDate.day,
    );
  }

  WorkoutEntity? getWorkoutOfTheDay(DateTime date) {
    return existingWorkouts.firstWhereOrNull(
      (w) =>
          w.date.year == date.year &&
          w.date.month == date.month &&
          w.date.day == date.day,
    );
  }

  WorkoutEntity? getLastWorkout() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return existingWorkouts.where((w) {
          final workoutDate = DateTime(w.date.year, w.date.month, w.date.day);
          return workoutDate.isAtSameMomentAs(today);
        }).firstOrNull ??
        (existingWorkouts.isNotEmpty
            ? (existingWorkouts.toList()
                    ..sort((a, b) => b.date.compareTo(a.date)))
                  .first
            : null);
  }

  @override
  List<Object?> get props => [
    cacheStatus,
    currentWorkout,
    cacheSuccessString,
    cacheErrorString,
    isEditingMode,

    selectedCalendarDate,

    searchExercisesStatus,
    exercisesList,
    fetchExercisesErrorString,

    submitWorkoutStatus,
    saveWorkoutSuccessString,
    saveWorkoutErrorString,

    existingWorkoutsStatus,
    existingWorkouts,
    existingWorkoutsErrorString,

    deleteWorkoutStatus,
    deleteWorkoutSuccessString,
    deleteWorkoutErrorString,
  ];
}
