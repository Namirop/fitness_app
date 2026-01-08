import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/screens/profil/widgets/number_picker_bottom_sheet.dart';

class ProfilInfoRow extends StatelessWidget {
  final String rowLabel;
  final double? rightPadding;
  final int currentValue;
  final String displayText;
  final String pickerTitle;
  final int minValue;
  final int maxValue;
  final IconData icon;
  final String unit;
  final ValueChanged<int> onValueChanged;
  final bool showDivider;
  final bool isLoading;
  const ProfilInfoRow({
    super.key,
    required this.rowLabel,
    required this.currentValue,
    this.rightPadding,
    required this.pickerTitle,
    required this.minValue,
    required this.maxValue,
    required this.icon,
    required this.onValueChanged,
    required this.unit,
    this.showDivider = true,
    required this.displayText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: rightPadding ?? 0),
          child: Row(
            children: [
              FaIcon((icon), size: 20),
              SizedBox(width: 15),
              Text("$rowLabel :", style: TextStyle(fontSize: 20)),
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
                        NumberPickerBottomSheet.show(
                          context: context,
                          title: pickerTitle,
                          minValue: minValue,
                          maxValue: maxValue,
                          currentValue: currentValue,
                          unit: unit,
                          onConfirm: onValueChanged,
                        );
                      },
                      child: Text(
                        displayText,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
            ],
          ),
        ),
        if (showDivider) Divider(),
      ],
    );
  }
}
