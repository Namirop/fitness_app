import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';

enum LoadProfilInfosStatus { initial, loading, success, failure }

enum EditProfilInfoStatus { initial, loading, success, failure }

class ProfilState extends Equatable {
  final ProfilEntity currentProfil;

  final EditProfilInfoStatus editProfilInfoStatus;
  final String? profilInfoErrorString;

  final LoadProfilInfosStatus loadProfilInfosStatus;

  ProfilState({
    required this.currentProfil,
    this.editProfilInfoStatus = EditProfilInfoStatus.initial,
    this.profilInfoErrorString,
    this.loadProfilInfosStatus = LoadProfilInfosStatus.initial,
  });

  ProfilState copyWith({
    ProfilEntity? currentProfil,
    EditProfilInfoStatus? editProfilInfoStatus,
    String? profilInfoErrorString,
    LoadProfilInfosStatus? loadProfilInfosStatus,
  }) {
    return ProfilState(
      currentProfil: currentProfil ?? this.currentProfil,
      editProfilInfoStatus: editProfilInfoStatus ?? this.editProfilInfoStatus,
      profilInfoErrorString:
          profilInfoErrorString ?? this.profilInfoErrorString,
      loadProfilInfosStatus:
          loadProfilInfosStatus ?? this.loadProfilInfosStatus,
    );
  }

  @override
  List<Object?> get props => [
    currentProfil,
    editProfilInfoStatus,
    profilInfoErrorString,
  ];
}
