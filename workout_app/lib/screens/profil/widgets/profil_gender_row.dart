import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/screens/profil/widgets/gender_picker_bottom_sheet.dart';

class ProfilGenderRow extends StatelessWidget {
  final String title;
  final String displayText;
  final ValueChanged<String> onGenderSelected;
  final IconData icon;
  final bool isLoading;
  const ProfilGenderRow({
    super.key,
    required this.title,
    required this.displayText,
    required this.onGenderSelected,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FaIcon((icon), size: 20),
            SizedBox(width: 15),
            Text("Sexe :", style: TextStyle(fontSize: 20)),
            Spacer(),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: AppColors.widgetBackground,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      GenderPickerBottomSheet.show(
                        context: context,
                        title: title,
                        onGenderSelected: onGenderSelected,
                      );
                    },
                    child: Text(
                      displayText,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
