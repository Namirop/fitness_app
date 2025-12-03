import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout_entity.dart';
import 'package:workout_app/data/entities/workout_exercice_entity.dart';
import 'package:workout_app/data/repositories/api_repository.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final ApiRepository repository;
  final WorkoutCacheService cacheService;
  // Constructeur du bloc, qui a besoin du repo et du cache à son intialisation, on les injectera à sa création dans le main.
  WorkoutBloc({required this.repository, required this.cacheService})
    : super(WorkoutInitialState()) {
    on<GetExistingWorkouts>((event, emit) async {
      try {
        emit(GetExistingWorkoutsLoading());
        final workouts = await repository.getWorkouts();
        // On peut retouner un List<WorkoutModel> là où on attend une List<WorkoutEntity>, parce que chaque WorkoutModel est compatible avec WorkoutEntity
        emit(GetExistingWorkoutsSuccess(workouts));
      } catch (e) {
        emit(
          GetExistingWorkoutsFailure(
            'Récupération des workouts existants impossible : $e',
          ),
        );
      }
    });

    on<AddWorkout>((event, emit) async {
      final currentWorkout = state.workout ?? WorkoutEntity.empty();
      print("ID WORKOUT : ${currentWorkout.id}");
      if (currentWorkout.title.trim().isEmpty) {
        emit(WorkoutValidationError("Veuillez ajouter un titre"));
        emit(CacheReady(currentWorkout));
        return;
      }

      // 1. Vérifier que y'a un titre et un exo
      if (currentWorkout.exercices.isEmpty) {
        emit(WorkoutValidationError("Veuillez ajouter un exercice"));
        emit(CacheReady(currentWorkout));
        return;
      }

      // // ✅ Validation des détails des exercices (optionnel)
      // final hasInvalidExercise = currentWorkout.exercices.any(
      //   (ex) => ex.sets == 0 || ex.reps == 0,
      // );

      // if (hasInvalidExercise) {
      //   emit(WorkoutValidationError('Remplis les sets/reps pour tous les exercices'));
      //   return;
      // }

      emit(SavingWorkout());
      try {
        await repository.addWorkout(currentWorkout);
        await cacheService.clearCache();

        emit(WorkoutSaved("Workout crée avec succès !"));
      } catch (e) {
        // le 'e' vient du throw Exception plus bas, de l'API.
        emit(WorkoutSavedError(e.toString()));
      }
    });

    on<UpdateWorkoutDetails>((event, emit) async {
      final currentWorkout = state.workout ?? WorkoutEntity.empty();
      final updatedWorkout = currentWorkout.copyWith(
        title: event.title,
        note: event.note,
        date: event.date,
      );
      await cacheService.saveCachedWorkout(updatedWorkout);
      emit(CacheReady(updatedWorkout));
    });

    on<DeleteWorkout>((event, emit) async {});

    on<DeleteAllWorkouts>((event, emit) async {
      try {
        await repository.deleteAllWorkouts();
      } catch (e) {}
    });

    // 1. On vérifie s'il y a un workout présent dans le cache
    on<HasCache>((event, emit) async {
      emit(CacheLoading());
      var cachedWorkout = cacheService.getCachedWorkout();
      try {
        // Si ya un workout, on l'assigne
        if (cachedWorkout != null) {
          emit(CacheFound(cachedWorkout));
          // Si pas, on initialise un nouveau
        } else {
          emit(CacheReady(WorkoutEntity.empty()));
        }
      } catch (e) {
        emit(CacheFailure('Erreur cache : $e'));
      }
    });

    on<ResumeCache>((event, emit) async {
      emit(CacheReady(state.workout ?? WorkoutEntity.empty()));
    });

    on<NewCache>((event, emit) async {
      await cacheService.clearCache();
      emit(CacheReady(WorkoutEntity.empty()));
    });

    on<AddExerciseToCache>((event, emit) async {
      //emit(CacheLoading(workout: state.workout));
      try {
        // 1. Récupérer le workout actuel depuis le state
        final currentWorkout = state.workout ?? WorkoutEntity.empty();

        // 2. Fetch l'exercice depuis l'API (délégation au repository)
        final exercise = await repository.fetchExerciseById(event.exerciseId);

        // 3. Logique métier : ajouter l'exercice au workout (cette logique est dans le BLoC car c'est du business logic)
        final workoutExercice = WorkoutExerciceEntity(exercise: exercise);
        final updatedWorkout = currentWorkout.copyWith(
          exercices: [...currentWorkout.exercices, workoutExercice],
        );

        // 4. Sauvegarder en cache (délégation au service)
        await cacheService.saveCachedWorkout(updatedWorkout);
        emit(CacheReady(updatedWorkout));
      } catch (e) {
        // Gestion d'erreur : on garde le workout actuel et on informe l'utilisateur
        final currentWorkout = state.workout ?? WorkoutEntity.empty();
        emit(CacheReady(currentWorkout));
        // TODO: Ajouter un SnackBar ou ErrorState pour notifier l'user
      }
    });

    on<UpdateExerciseDetails>((event, emit) async {
      final currentWorkout = state.workout ?? WorkoutEntity.empty();
      final index = event.exIndex;

      // On récupère la liste d'exercices du workout courant.
      final updatedExercises = List<WorkoutExerciceEntity>.from(
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
      await cacheService.saveCachedWorkout(updatedWorkout);
      emit(CacheReady(updatedWorkout));
    });

    on<RemoveExercise>((event, emit) async {
      try {
        final currentWorkout = state.workout!;

        // Ici on récupère tout les exercices qui n'ont pas un id équivalent à celui que l'on veut supp (facon "pro" de supprimer quoi)
        final updatedExercises = currentWorkout.exercices
            .where((workoutEx) => workoutEx.exercise.id != event.exerciseId)
            .toList();

        final updatedWorkout = currentWorkout.copyWith(
          exercices: updatedExercises,
        );
        await cacheService.saveCachedWorkout(updatedWorkout);
        emit(CacheReady(updatedWorkout));
      } catch (e) {
        // Gestion d'erreur : on garde le workout actuel et on informe l'utilisateur
        final currentWorkout = state.workout ?? WorkoutEntity.empty();
        emit(CacheReady(currentWorkout));
        // TODO: Ajouter un SnackBar ou ErrorState pour notifier l'user
      }
    });

    on<FetchExercices>((event, emit) async {
      final workout = state.workout;
      try {
        emit(FetchExercicesLoading(workout: workout));
        final exercisesFromQuery = await repository.fetchExercisesFromQuery(
          event.query,
        );
        emit(FetchExercicesSuccess(exercisesFromQuery, workout: workout));
      } catch (e) {
        emit(
          FetchExercicesFailure(
            'Récupération des exercices depuis API interne impossible : $e',
          ),
        );
      }
    });
  }
}
