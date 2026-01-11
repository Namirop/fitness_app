// internal API payloads
package dto

type AddFoodPortionDto struct {
	NutritionDayId string  `json:"nutritionDayId"`
	MealId         string  `json:"mealId"`
	FoodID         string  `json:"foodId"`
	Quantity       float64 `json:"quantity"`
}
