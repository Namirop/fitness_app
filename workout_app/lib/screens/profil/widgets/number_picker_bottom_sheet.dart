import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/core/constants/app_constants.dart';

class NumberPickerBottomSheet extends StatelessWidget {
  final String title;
  final int currentValue;
  final int minValue;
  final int maxValue;
  final String unit;
  final ValueChanged<int> onConfirm;
  const NumberPickerBottomSheet({
    super.key,
    required this.title,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.onConfirm,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    int selectedValue = currentValue;
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: currentValue - minValue);
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
          SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: CupertinoPicker(
              scrollController: scrollController,
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                selectedValue = index + minValue;
              },
              children: List.generate(
                maxValue - minValue + 1,
                (index) => Center(
                  child: Text(
                    "${index + minValue} $unit",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              onConfirm(selectedValue);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  color: const Color.fromARGB(255, 68, 62, 62),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check, size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Valider",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required int minValue,
    required int maxValue,
    required int currentValue,
    required String unit,
    required ValueChanged<int> onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => NumberPickerBottomSheet(
        title: title,
        currentValue: currentValue,
        minValue: minValue,
        maxValue: maxValue,
        unit: unit,
        onConfirm: onConfirm,
      ),
    );
  }
}


// For age: 
// Current age of the user, let's say 32
    //int selectedAge = currentAge;
    // Corresponding index in the picker
    // final initialIndex = currentAge - 10;
    // The picker will be positioned on index 22
    // Which displays: 22 + 10 = “32 years old” 
    // General formula: initialIndex = currentValue - minValue