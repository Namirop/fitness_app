import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/errors/api_exception.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/data/repositories/workout_repository.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;
  final WorkoutCacheService cacheService;
  WorkoutBloc({required this.repository, required this.cacheService})
    : super(
        WorkoutState(
          currentWorkout: WorkoutEntity.empty(),
          selectedCalendarDate: DateTime.now(),
        ),
      ) {
    // ---------------------------------------------------------------------------
    // WORKOUT MANAGEMENT
    // ---------------------------------------------------------------------------
    on<GetExistingWorkouts>((event, emit) async {
      emit(
        state.copyWith(
          existingWorkoutsStatus: ExistingWorkoutsStatus.loading,
          existingWorkoutsErrorString: null,
        ),
      );
      try {
        final existingWorkout = await repository.getWorkouts();
        emit(
          state.copyWith(
            existingWorkoutsStatus: ExistingWorkoutsStatus.success,
            existingWorkouts: existingWorkout,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            existingWorkoutsStatus: ExistingWorkoutsStatus.failure,
            existingWorkoutsErrorString: e.toString(),
          ),
        );
      }
    });

    on<SubmitWorkout>((event, emit) async {
      final currentWorkout = state.currentWorkout;
      emit(
        state.copyWith(
          submitWorkoutStatus: SubmitWorkoutStatus.saving,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
        ),
      );
      if (currentWorkout.title.trim().isEmpty) {
        emit(
          state.copyWith(
            submitWorkoutStatus: SubmitWorkoutStatus.failure,
            saveWorkoutErrorString: "Ajoutez un titre au workout",
            saveWorkoutSuccessString: null,
          ),
        );
        return;
      }

      if (currentWorkout.exercises.isEmpty) {
        emit(
          state.copyWith(
            submitWorkoutStatus: SubmitWorkoutStatus.failure,
            saveWorkoutErrorString: "Ajoutez au moins un exercice au workout",
            saveWorkoutSuccessString: null,
          ),
        );
        return;
      }
      try {
        final List<WorkoutEntity> updatedWorkouts;
        final String successMessage;
        if (state.isEditingMode) {
          final updatedWorkout = await repository.updateWorkout(currentWorkout);
          updatedWorkouts = state.existingWorkouts.map((w) {
            return w.id == updatedWorkout.id ? updatedWorkout : w;
          }).toList();
          successMessage = "Workout modifié avec succès !";
        } else {
          await cacheService.clearCachedWorkout();
          final createdWorkout = await repository.createWorkout(currentWorkout);
          updatedWorkouts = [...state.existingWorkouts, createdWorkout];
          successMessage = "Workout crée avec succès !";
        }
        emit(
          state.copyWith(
            submitWorkoutStatus: SubmitWorkoutStatus.success,
            saveWorkoutSuccessString: successMessage,
            saveWorkoutErrorString: null,
            currentWorkout: WorkoutEntity.empty(),
            existingWorkoutsStatus: ExistingWorkoutsStatus.success,
            existingWorkouts: updatedWorkouts,
            isEditingMode: false,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            submitWorkoutStatus: SubmitWorkoutStatus.failure,
            saveWorkoutErrorString: e.toString(),
            saveWorkoutSuccessString: null,
          ),
        );
      }
    });

    on<UpdateWorkoutDetails>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.loading,
          cacheErrorString: null,
          cacheSuccessString: null,
        ),
      );
      final currentWorkout = state.currentWorkout;
      try {
        final updatedWorkout = currentWorkout.copyWith(
          title: event.title,
          note: event.note,
          date: event.date,
        );
        if (state.isEditingMode == false) {
          await cacheService.saveCachedWorkout(updatedWorkout);
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            currentWorkout: updatedWorkout,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            cacheErrorString: "Modification impossible du workout",
            cacheSuccessString: null,
          ),
        );
      }
    });

    on<DeleteWorkout>((event, emit) async {
      emit(
        state.copyWith(
          deleteWorkoutStatus: DeleteWorkoutStatus.loading,
          deleteWorkoutSuccessString: null,
          deleteWorkoutErrorString: null,
        ),
      );
      try {
        final updatedWorkouts = await repository.deleteWorkout(
          event.workout.id,
        );
        emit(
          state.copyWith(
            deleteWorkoutStatus: DeleteWorkoutStatus.success,
            deleteWorkoutSuccessString: "Workout supprimé",
            deleteWorkoutErrorString: null,
            currentWorkout: WorkoutEntity.empty(),
            existingWorkoutsStatus: ExistingWorkoutsStatus.success,
            existingWorkouts: updatedWorkouts,
            isEditingMode: false,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            deleteWorkoutStatus: DeleteWorkoutStatus.failure,
            deleteWorkoutErrorString: e.toString(),
            deleteWorkoutSuccessString: null,
          ),
        );
      }
    });

    on<SetSelectedCalendarDate>((event, emit) async {
      emit(state.copyWith(selectedCalendarDate: event.date));
    });

    on<SetEditingWorkout>((event, emit) async {
      emit(
        state.copyWith(
          currentWorkout:
              event.workout ??
              WorkoutEntity.empty().copyWith(date: state.selectedCalendarDate),
          isEditingMode: event.isEditingMode,
          cacheStatus: CacheStatus.ready,
          existingWorkoutsStatus: ExistingWorkoutsStatus.initial,
          searchExercisesStatus: SearchExercisesStatus.initial,
          submitWorkoutStatus: SubmitWorkoutStatus.initial,
          deleteWorkoutStatus: DeleteWorkoutStatus.initial,
        ),
      );
    });

    // ---------------------------------------------------------------------------
    // CACHE MANAGEMENT
    // ---------------------------------------------------------------------------

    on<HasCache>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.loading,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
        ),
      );
      if (state.isEditingMode == true) {
        emit(state.copyWith(cacheStatus: CacheStatus.ready));
        return;
      }
      var cachedWorkout = cacheService.getCachedWorkout();
      try {
        if (cachedWorkout != null) {
          emit(
            state.copyWith(
              cacheStatus: CacheStatus.found,
              submitWorkoutStatus: SubmitWorkoutStatus.initial,
              currentWorkout: cachedWorkout,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            submitWorkoutStatus: SubmitWorkoutStatus.initial,
            currentWorkout: WorkoutEntity.empty(),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: "Erreur lors de la récupération du cache",
            cacheSuccessString: null,
          ),
        );
      }
    });

    on<NewCache>((event, emit) async {
      await cacheService.clearCachedWorkout();
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.ready,
          currentWorkout: WorkoutEntity.empty(),
        ),
      );
    });

    // ---------------------------------------------------------------------------
    // EXERCISE MANAGEMENT
    // ---------------------------------------------------------------------------

    on<SearchExercises>((event, emit) async {
      emit(
        state.copyWith(
          searchExercisesStatus: SearchExercisesStatus.loading,
          fetchExercisesErrorString: null,
        ),
      );
      try {
        final exercises = await repository.fetchExercisesFromQuery(event.query);
        emit(
          state.copyWith(
            searchExercisesStatus: SearchExercisesStatus.success,
            exercisesList: exercises,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            searchExercisesStatus: SearchExercisesStatus.failure,
            fetchExercisesErrorString: e.toString(),
          ),
        );
      }
    });

    on<AddExercise>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.loading,
          cacheSuccessString: null,
          cacheErrorString: null,
        ),
      );
      final currentWorkout = state.currentWorkout;
      try {
        // peut être gardé pour rapidité UI
        final workoutExercice = WorkoutExerciseEntity(exercise: event.exercise);
        final updatedWorkout = currentWorkout.copyWith(
          exercises: [...currentWorkout.exercises, workoutExercice],
        );
        if (state.isEditingMode == false) {
          await cacheService.saveCachedWorkout(updatedWorkout);
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            currentWorkout: updatedWorkout,
            cacheSuccessString: "Exercice ajouté",
            cacheErrorString: null,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: "Ajout de l'exercice impossible",
            cacheSuccessString: null,
          ),
        );
      }
    });

    on<UpdateExerciseDetails>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.loading,
          cacheSuccessString: null,
          cacheErrorString: null,
        ),
      );
      final currentWorkout = state.currentWorkout;
      final index = event.exIndex;
      try {
        final updatedExercises = List<WorkoutExerciseEntity>.from(
          currentWorkout.exercises,
        );

        updatedExercises[index] = updatedExercises[index].copyWith(
          sets: event.sets,
          reps: event.reps,
          weight: event.weight,
        );

        final updatedWorkout = currentWorkout.copyWith(
          exercises: updatedExercises,
        );
        if (state.isEditingMode == false) {
          await cacheService.saveCachedWorkout(updatedWorkout);
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            currentWorkout: updatedWorkout,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: "Modification impossible de l'exercice",
            cacheSuccessString: null,
          ),
        );
      }
    });

    on<RemoveExercise>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.loading,
          cacheSuccessString: null,
          cacheErrorString: null,
        ),
      );
      final currentWorkout = state.currentWorkout;
      try {
        final updatedExercises = currentWorkout.exercises
            .where((workoutEx) => workoutEx.exercise.id != event.exerciseId)
            .toList();

        final updatedWorkout = currentWorkout.copyWith(
          exercises: updatedExercises,
        );
        if (state.isEditingMode == false) {
          await cacheService.saveCachedWorkout(updatedWorkout);
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            currentWorkout: updatedWorkout,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: "Impossible de supprimer cette exercice",
            cacheSuccessString: null,
          ),
        );
      }
    });

    // ---------------------------------------------------------------------------
    // OTHER
    // ---------------------------------------------------------------------------

    on<ResetToEmptyWorkout>((event, emit) async {
      emit(
        state.copyWith(
          currentWorkout: WorkoutEntity.empty(),
          cacheStatus: CacheStatus.ready,
          existingWorkoutsStatus: ExistingWorkoutsStatus.initial,
          searchExercisesStatus: SearchExercisesStatus.initial,
          submitWorkoutStatus: SubmitWorkoutStatus.initial,
          deleteWorkoutStatus: DeleteWorkoutStatus.initial,
          isEditingMode: false,
        ),
      );
    });
  }
}
