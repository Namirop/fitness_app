import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/data/repositories/workout_repository.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;
  final WorkoutCacheService cacheService;
  // Constructeur du bloc, qui a besoin du repo et du cache à son intialisation, on les injectera à sa création dans le main.
  WorkoutBloc({required this.repository, required this.cacheService})
    : super(WorkoutState(currentWorkout: WorkoutEntity.empty())) {
    on<GetExistingWorkouts>((event, emit) async {
      try {
        emit(
          state.copyWith(
            existingWorkoutsStatus: ExistingWorkoutsStatus.loading,
          ),
        );
        final existingWorkout = await repository.getWorkouts();
        // On peut retouner un List<WorkoutModel> là où on attend une List<WorkoutEntity>, parce que chaque WorkoutModel est compatible avec WorkoutEntity
        emit(
          state.copyWith(
            existingWorkoutsStatus: ExistingWorkoutsStatus.success,
            existingWorkouts: existingWorkout,
          ),
        );
      } catch (e) {
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

      // Quand on émet un status (success/failure), reset TOUJOURS les messages opposés.
      // => garantit un état toujours cohérent.
      if (currentWorkout.title.trim().isEmpty) {
        emit(
          state.copyWith(
            saveWorkoutStatus: SaveWorkoutStatus.failure,
            saveWorkoutErrorString: "Ajoutez un titre au workout",
            saveWorkoutSuccessString: null,
          ),
        );
        return;
      }

      // 1. Vérifier que y'a un titre et un exo
      if (currentWorkout.exercices.isEmpty) {
        emit(
          state.copyWith(
            saveWorkoutStatus: SaveWorkoutStatus.failure,
            saveWorkoutErrorString: "Ajoutez au moins un exercice au workout",
            saveWorkoutSuccessString: null,
          ),
        );
        return;
      }
      emit(state.copyWith(saveWorkoutStatus: SaveWorkoutStatus.saving));
      try {
        if (state.isEditingMode == false) {
          await repository.addWorkout(currentWorkout);
          await cacheService.clearCachedWorkout();
        } else {
          await repository.updateWorkout(currentWorkout);
        }
        emit(
          state.copyWith(
            saveWorkoutStatus: SaveWorkoutStatus.success,
            saveWorkoutSuccessString: state.isEditingMode == true
                ? "Workout modifié avec succès !"
                : "Workout crée avec succès !",
            saveWorkoutErrorString: null,
            currentWorkout: WorkoutEntity.empty(),
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            saveWorkoutStatus: SaveWorkoutStatus.failure,
            saveWorkoutErrorString: e.toString(),
            saveWorkoutSuccessString: null,
          ),
        );
      }
    });

    on<UpdateWorkoutDetails>((event, emit) async {
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
            cacheErrorString:
                "Impossible de modifier les détails du workout ${currentWorkout.title}",
            cacheSuccessString: null,
            currentWorkout: currentWorkout,
          ),
        );
        print(e);
      }
    });

    on<DeleteWorkout>((event, emit) async {
      try {
        await repository.deleteWorkout(event.workout.id);
        emit(
          state.copyWith(
            deleteWorkoutStatus: DeleteWorkoutStatus.success,
            deletedWorkout: event.workout,
            deleteWorkoutSuccessString:
                "Workout ${event.workout.title} supprimé",
            deleteWorkoutErrorString: null,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            deleteWorkoutStatus: DeleteWorkoutStatus.failure,
            deleteWorkoutErrorString: e.toString(),
            deleteWorkoutSuccessString: null,
          ),
        );
      }
    });

    // Cette fonction ne sera pas en prod donc pas important à gere correctement (message confirmation, etc.)
    on<DeleteAllWorkouts>((event, emit) async {
      await repository.deleteAllWorkouts();
    });

    on<HasCache>((event, emit) async {
      emit(state.copyWith(cacheStatus: CacheStatus.loading));
      var cachedWorkout = cacheService.getCachedWorkout();
      try {
        // Depuis le calendrier (pas de cache)
        if (event.initialDate != null) {
          emit(
            state.copyWith(
              cacheStatus: CacheStatus.ready,
              saveWorkoutStatus: SaveWorkoutStatus
                  .initial, // on reset l'état du saveWorkout dans le contexte ou on aurait une erreur de save (pas de titre par exemple) et qu'on reviendrait sur la page par la suite (le status serait du coup 'failure' si pas de reset à initial)
              currentWorkout: WorkoutEntity.empty().copyWith(
                date: event.initialDate,
              ),
              saveWorkoutErrorString: null,
              saveWorkoutSuccessString: null,
              isEditingMode: false,
            ),
          );
          return;
        }

        // Cache trouvé
        if (cachedWorkout != null) {
          emit(
            state.copyWith(
              cacheStatus: CacheStatus.found,
              saveWorkoutStatus: SaveWorkoutStatus.initial,
              currentWorkout: cachedWorkout,
              saveWorkoutErrorString: null,
              saveWorkoutSuccessString: null,
              isEditingMode: false,
            ),
          );
          return;
        }

        // Pas de cache
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            saveWorkoutStatus: SaveWorkoutStatus.initial,
            currentWorkout: WorkoutEntity.empty(),
            saveWorkoutErrorString: null,
            saveWorkoutSuccessString: null,
            isEditingMode: false,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: 'Erreur cache : $e',
            cacheSuccessString: null,
          ),
        );
      }
    });

    on<ResumeCache>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.ready,
          saveWorkoutStatus: SaveWorkoutStatus.initial,
          currentWorkout: state.currentWorkout,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
          isEditingMode: false,
        ),
      );
    });

    on<NewCache>((event, emit) async {
      await cacheService.clearCachedWorkout();
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.ready,
          saveWorkoutStatus: SaveWorkoutStatus.initial,
          currentWorkout: WorkoutEntity.empty(),
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
          isEditingMode: false,
        ),
      );
    });

    on<AddExercise>((event, emit) async {
      final currentWorkout = state.currentWorkout;
      try {
        final exercise = await repository.fetchExerciseById(event.exerciseId);
        final workoutExercice = WorkoutExerciseEntity(exercise: exercise);
        final updatedWorkout = currentWorkout.copyWith(
          exercices: [...currentWorkout.exercices, workoutExercice],
        );
        if (state.isEditingMode == false) {
          await cacheService.saveCachedWorkout(updatedWorkout);
        }
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.ready,
            cacheSuccessString: "Exercice ${exercise.name} ajouté",
            cacheErrorString: null,
            currentWorkout: updatedWorkout,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            cacheStatus: CacheStatus.failure,
            cacheErrorString: e.toString(),
            cacheSuccessString: null,
            currentWorkout: currentWorkout,
          ),
        );
      }
    });

    on<UpdateExerciseDetails>((event, emit) async {
      final currentWorkout = state.currentWorkout;
      final index = event.exIndex;
      try {
        final updatedExercises = List<WorkoutExerciseEntity>.from(
          currentWorkout.exercices,
        );

        updatedExercises[index] = updatedExercises[index].copyWith(
          sets: event.sets,
          reps: event.reps,
          weight: event.weight,
        );

        final updatedWorkout = currentWorkout.copyWith(
          exercices: updatedExercises,
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
            cacheErrorString:
                "Impossible de modifier les détails de cette exercice : $e",
            cacheSuccessString: null,
            currentWorkout: currentWorkout,
          ),
        );
        print(e);
      }
    });

    on<RemoveExercise>((event, emit) async {
      final currentWorkout = state.currentWorkout;
      try {
        // Ici on récupère tout les exercices qui n'ont pas un id équivalent à celui que l'on veut supp (facon "pro" de supprimer quoi)
        final updatedExercises = currentWorkout.exercices
            .where((workoutEx) => workoutEx.exercise.id != event.exerciseId)
            .toList();

        final updatedWorkout = currentWorkout.copyWith(
          exercices: updatedExercises,
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
            cacheErrorString: "Impossible de supprimer cette exercice : $e",
            cacheSuccessString: null,
            currentWorkout: currentWorkout,
          ),
        );
        print(e);
      }
    });

    on<FetchExercises>((event, emit) async {
      try {
        emit(
          state.copyWith(fetchExercisesStatus: FetchExercisesStatus.loading),
        );
        final exercisesFromQuery = await repository.fetchExercisesFromQuery(
          event.query,
        );
        emit(
          state.copyWith(
            fetchExercisesStatus: FetchExercisesStatus.success,
            exercises: exercisesFromQuery,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            fetchExercisesStatus: FetchExercisesStatus.failure,
            fetchExercisesErrorString: e.toString(),
            fetchExercisesSuccessString: null,
          ),
        );
      }
    });

    on<ResetSaveStatus>((event, emit) {
      emit(
        state.copyWith(
          saveWorkoutStatus: SaveWorkoutStatus.initial,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
        ),
      );
    });

    on<ResetDeleteStatus>((event, emit) {
      emit(
        state.copyWith(
          deleteWorkoutStatus: DeleteWorkoutStatus.initial,
          deleteWorkoutErrorString: null,
          deleteWorkoutSuccessString: null,
        ),
      );
    });

    on<ResetExistingWorkoutStatus>((event, emit) {
      emit(
        state.copyWith(
          existingWorkoutsStatus: ExistingWorkoutsStatus.initial,
          existingWorkoutsSuccessString: null,
          existingWorkoutsErrorString: null,
        ),
      );
    });

    on<LoadWorkoutForEdit>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.ready,
          currentWorkout: event.workoutToEdit,
          saveWorkoutStatus: SaveWorkoutStatus.initial,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
          isEditingMode: true,
        ),
      );
    });

    on<ResetToEmptyWorkout>((event, emit) async {
      emit(
        state.copyWith(
          cacheStatus: CacheStatus.ready,
          currentWorkout: WorkoutEntity.empty(),
          saveWorkoutStatus: SaveWorkoutStatus.initial,
          saveWorkoutErrorString: null,
          saveWorkoutSuccessString: null,
          isEditingMode: false,
        ),
      );
    });
  }
}
