import 'package:flutter/material.dart';
import 'package:workout_app/core/constants/app_constants.dart';

class GenderPickerBottomSheet extends StatelessWidget {
  final String title;
  final ValueChanged<String> onGenderSelected;
  const GenderPickerBottomSheet({
    super.key,
    required this.title,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomSheetColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text("Homme", style: TextStyle(fontSize: 22)),
            onTap: () {
              onGenderSelected("Homme");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Femme", style: TextStyle(fontSize: 22)),
            onTap: () {
              onGenderSelected("Femme");
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required ValueChanged<String> onGenderSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return GenderPickerBottomSheet(
          title: title,
          onGenderSelected: onGenderSelected,
        );
      },
    );
  }
}
