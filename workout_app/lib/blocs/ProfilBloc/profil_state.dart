import 'package:equatable/equatable.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';

enum LoadProfilStatus { initial, loading, success, failure }

enum EditProfilStatus { initial, success, failure }

class ProfilState extends Equatable {
  final ProfilEntity currentProfil;
  final LoadProfilStatus loadProfilStatus;

  final EditProfilStatus editProfilStatus;
  final String? profilErrorString;

  const ProfilState({
    required this.currentProfil,
    this.editProfilStatus = EditProfilStatus.initial,
    this.profilErrorString,
    this.loadProfilStatus = LoadProfilStatus.initial,
  });

  ProfilState copyWith({
    ProfilEntity? currentProfil,
    LoadProfilStatus? loadProfilStatus,
    EditProfilStatus? editProfilStatus,
    String? profilErrorString,
  }) {
    return ProfilState(
      currentProfil: currentProfil ?? this.currentProfil,
      editProfilStatus: editProfilStatus ?? this.editProfilStatus,
      profilErrorString: profilErrorString,
      loadProfilStatus: loadProfilStatus ?? this.loadProfilStatus,
    );
  }

  @override
  List<Object?> get props => [
    currentProfil,
    loadProfilStatus,
    editProfilStatus,
    profilErrorString,
  ];
}
