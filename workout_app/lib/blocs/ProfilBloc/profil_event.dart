abstract class ProfilEvent {}

class GetCachedProfil extends ProfilEvent {}

class EditProfilInformation extends ProfilEvent {
  final String? editedProfilName;
  final String? editedProfilGender;
  final int? editedProfilAge;
  final double? editedProfilWeight;
  final int? editedProfilHeight;
  final double? caloriesTarget;
  final double? carbsTarget;
  final double? proteinsTarget;
  final double? fatsTarget;
  final String? activityLevel;
  final String? goal;
  EditProfilInformation({
    this.editedProfilName,
    this.editedProfilGender,
    this.editedProfilAge,
    this.editedProfilWeight,
    this.editedProfilHeight,
    this.caloriesTarget,
    this.carbsTarget,
    this.proteinsTarget,
    this.fatsTarget,
    this.activityLevel,
    this.goal,
  });
}
