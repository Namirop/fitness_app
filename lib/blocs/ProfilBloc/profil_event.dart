abstract class ProfilEvent {}

class GetCachedProfil extends ProfilEvent {}

class EditProfilInformation extends ProfilEvent {
  final String? editedProfilName;
  final String? editedProfilGender;
  final int? editedProfilAge;
  final double? editedProfilWeight;
  final int? editedProfilHeight;
  EditProfilInformation({
    this.editedProfilName,
    this.editedProfilGender,
    this.editedProfilAge,
    this.editedProfilWeight,
    this.editedProfilHeight,
  });
}
