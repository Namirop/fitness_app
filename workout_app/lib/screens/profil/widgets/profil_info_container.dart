import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_event.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/screens/profil/widgets/profil_gender_row.dart';
import 'package:workout_app/screens/profil/widgets/profil_info_row.dart';
import 'package:workout_app/screens/profil/widgets/profil_text_field_row.dart';

class ProfilInfoContainer extends StatelessWidget {
  final ProfilEntity currentProfil;
  final bool isLoading;
  const ProfilInfoContainer({
    super.key,
    required this.currentProfil,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.widgetBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 20, 10),
        child: Column(
          children: [
            ProfilTextFieldRow(
              rowLabel: "Prénom",
              icon: FontAwesomeIcons.person,
              displayText: currentProfil.displayName,
              isLoading: isLoading,
              onTextFieldChanged: (value) {
                context.read<ProfilBloc>().add(
                  EditProfilInformation(editedProfilName: value),
                );
              },
            ),
            ProfilGenderRow(
              title: "Sélectionner votre sexe :",
              displayText: currentProfil.displayGender,
              isLoading: isLoading,
              onGenderSelected: (selectedGender) {
                context.read<ProfilBloc>().add(
                  EditProfilInformation(editedProfilGender: selectedGender),
                );
              },
              icon: Icons.people,
            ),
            ProfilInfoRow(
              rowLabel: "Age",
              icon: Icons.numbers,
              currentValue: currentProfil.age,
              displayText: currentProfil.displayAge,
              pickerTitle: "Sélectionner votre âge :",
              isLoading: isLoading,
              minValue: 10,
              maxValue: 120,
              unit: "ans",
              onValueChanged: (selectedAge) {
                context.read<ProfilBloc>().add(
                  EditProfilInformation(editedProfilAge: selectedAge),
                );
              },
            ),
            ProfilInfoRow(
              rowLabel: "Poids (kg)",
              currentValue: currentProfil.weight.toInt(),
              displayText: currentProfil.displayWeight,
              pickerTitle: "Sélectionner votre poids :",
              isLoading: isLoading,
              minValue: 30,
              maxValue: 200,
              icon: FontAwesomeIcons.weight,
              unit: "kg",
              onValueChanged: (selectedWeight) {
                context.read<ProfilBloc>().add(
                  EditProfilInformation(
                    editedProfilWeight: selectedWeight.toDouble(),
                  ),
                );
              },
            ),
            ProfilInfoRow(
              rowLabel: "Taille (cm)",
              currentValue: currentProfil.height,
              displayText: currentProfil.displayHeight,
              pickerTitle: "Sélectionner votre taille :",
              isLoading: isLoading,
              minValue: 100,
              maxValue: 220,
              icon: FontAwesomeIcons.textHeight,
              unit: "cm",
              onValueChanged: (selectedHeight) {
                context.read<ProfilBloc>().add(
                  EditProfilInformation(editedProfilHeight: selectedHeight),
                );
              },
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
