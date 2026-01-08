import 'package:flutter/material.dart';

enum MealType { none, breakfast, lunch, dinner, snack, custom }

extension MealTypExtension on MealType {
  String get label {
    switch (this) {
      case MealType.none:
        return "None";
      case MealType.breakfast:
        return 'Petit-déjeuner';
      case MealType.lunch:
        return 'Diner';
      case MealType.dinner:
        return 'Souper';
      case MealType.snack:
        return 'Collation';
      case MealType.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.custom:
        return Icons.edit;
      case MealType.none:
        return Icons.help_outline;
    }
  }
}
