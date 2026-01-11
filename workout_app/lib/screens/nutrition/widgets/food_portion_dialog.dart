// complete functional unit, not a helper.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/nutrition/food_entity.dart';

class FoodPortionDialog extends StatefulWidget {
  final FoodEntity food;
  const FoodPortionDialog({super.key, required this.food});

  @override
  State<FoodPortionDialog> createState() => _FoodPortionDialogState();
}

class _FoodPortionDialogState extends State<FoodPortionDialog> {
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.food.referenceQuantity;
  }

  double get _ratio => _quantity / widget.food.referenceQuantity;

  double get calories => widget.food.calories * _ratio;
  double get carbs => widget.food.carbs * _ratio;
  double get proteins => widget.food.proteins * _ratio;
  double get fats => widget.food.fats * _ratio;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.widgetBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(width: 3, color: AppColors.containerBorderColor),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.food.name} - ${widget.food.primaryStore}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19),
            ),
            const SizedBox(height: 8),
            Text(
              "G: ${carbs.toStringAsFixed(1)} "
              "P: ${proteins.toStringAsFixed(1)} "
              "L: ${fats.toStringAsFixed(1)} "
              "- ${calories.toStringAsFixed(0)} kcal",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildQuantityInput(),
            const SizedBox(height: 12),
            _buildButtonsAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(124, 217, 218, 217),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 15, 0),
        child: Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  cursorColor: Colors.black,
                  cursorWidth: 1.0,
                  cursorHeight: 20.0,
                  decoration: InputDecoration(
                    hintText: widget.food.referenceQuantity.toString(),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) return;
                    setState(() => _quantity = parsed);
                  },
                ),
              ),
            ),
            Text(widget.food.referenceUnit, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsAction(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context, null),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                "Annuler",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context, _quantity),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                "Valider la portion",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
