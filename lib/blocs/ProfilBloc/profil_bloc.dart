import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_state.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/data/services/profil_cache_service.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final ProfilCacheService cacheService;
  ProfilBloc({required this.cacheService})
    : super(ProfilState(currentProfil: ProfilEntity.empty())) {
    on<GetCachedProfil>((event, emit) {
      try {
        final cachedProfil =
            cacheService.getCachedProfil() ?? ProfilEntity.empty();
        emit(
          state.copyWith(
            currentProfil: cachedProfil,
            loadProfilInfosStatus: LoadProfilInfosStatus.success,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            profilInfoErrorString: e.toString(),
            loadProfilInfosStatus: LoadProfilInfosStatus.failure,
          ),
        );
      }
    });

    on<EditProfilInformation>((event, emit) async {
      emit(state.copyWith(editProfilInfoStatus: EditProfilInfoStatus.initial));
      try {
        final currentProfil = state.currentProfil;
        final updatedProfil = currentProfil.copyWith(
          name: event.editedProfilName,
          gender: event.editedProfilGender,
          age: event.editedProfilAge,
          weight: event.editedProfilWeight,
          height: event.editedProfilHeight,
        );

        await cacheService.saveCachedProfil(updatedProfil);
        emit(
          state.copyWith(
            editProfilInfoStatus: EditProfilInfoStatus.success,
            currentProfil: updatedProfil,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            editProfilInfoStatus: EditProfilInfoStatus.failure,
            profilInfoErrorString: e.toString(),
          ),
        );
      }
    });
  }
}
