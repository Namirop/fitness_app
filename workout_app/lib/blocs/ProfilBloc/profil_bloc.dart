import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/core/errors/api_exception.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/data/repositories/profil_repository.dart';
import 'package:workout_app/data/services/profil_cache_service.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final ProfilCacheService cacheService;
  final ProfilRepository repository;
  ProfilBloc({required this.cacheService, required this.repository})
    : super(ProfilState(currentProfil: ProfilEntity.empty())) {
    on<GetCachedProfil>((event, emit) async {
      emit(
        state.copyWith(
          loadProfilStatus: LoadProfilStatus.loading,
          profilErrorString: null,
        ),
      );
      try {
        var cachedProfil = cacheService.getCachedProfil();
        if (cachedProfil != null) {
          emit(
            state.copyWith(
              currentProfil: cachedProfil,
              loadProfilStatus: LoadProfilStatus.success,
            ),
          );
        }

        var profil = cachedProfil != null
            ? await repository.getProfil()
            : await repository.createProfil();

        await cacheService.saveCachedProfil(profil);
        emit(
          state.copyWith(
            currentProfil: profil,
            loadProfilStatus: LoadProfilStatus.success,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            profilErrorString: e.toString(),
            loadProfilStatus: LoadProfilStatus.failure,
            currentProfil: ProfilEntity.empty(),
          ),
        );
      }
    });

    on<EditProfilInformation>((event, emit) async {
      emit(state.copyWith(profilErrorString: null));
      try {
        final currentProfil = state.currentProfil;
        final updatedProfil = currentProfil.copyWith(
          name: event.editedProfilName,
          gender: event.editedProfilGender,
          age: event.editedProfilAge,
          weight: event.editedProfilWeight,
          height: event.editedProfilHeight,
          caloriesTarget: event.caloriesTarget,
          carbsTarget: event.carbsTarget,
          proteinsTarget: event.proteinsTarget,
          fatsTarget: event.fatsTarget,
          activityLevel: event.activityLevel,
          goal: event.goal,
        );

        await cacheService.saveCachedProfil(updatedProfil);
        final receivedProfil = await repository.updateProfil(updatedProfil);
        emit(
          state.copyWith(
            editProfilStatus: EditProfilStatus.success,
            currentProfil: receivedProfil,
          ),
        );
      } on ApiException catch (e) {
        emit(
          state.copyWith(
            editProfilStatus: EditProfilStatus.failure,
            profilErrorString: e.toString(),
          ),
        );
      }
    });
  }
}
