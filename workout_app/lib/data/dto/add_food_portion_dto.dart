class AddFoodPortionDto {
  final String nutritionDayId;
  final String mealId;
  final String foodId;
  final double quantity;

  AddFoodPortionDto({
    required this.nutritionDayId,
    required this.mealId,
    required this.foodId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "nutritionDayId": nutritionDayId,
      "mealId": mealId,
      "foodId": foodId,
      "quantity": quantity,
    };
  }
}
