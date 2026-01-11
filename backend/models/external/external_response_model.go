// external API responses
package external

type ExternalExerciseResponse struct {
	Exercises []Suggestions `json:"suggestions"`
}

type Suggestions struct {
	Data ExerciseData `json:"data"`
}

type ExerciseData struct {
	ExerciseId int    `json:"id"`
	Name       string `json:"name"`
	Image      string `json:"image"`
}

type ExternalExerciseDetailResponse struct {
	ExerciseId   int                    `json:"id"`
	Translations []ExternalTranslations `json:"translations"`
	Images       []ExternalImageDetails `json:"images"`
	Videos       []ExternalVideoDetails `json:"videos"`
}

type ExternalTranslations struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Language    int    `json:"language"`
}

type ExternalImageDetails struct {
	Image  string `json:"image"`
	IsMain bool   `json:"is_main"`
}

type ExternalVideoDetails struct {
	Video  string `json:"video"`
	IsMain bool   `json:"is_main"`
}

// -------------

type ExternalSearchFoodsResponse struct {
	Food []ExternalFood `json:"products"`
}

type ExternalSearchFoodIdResponse struct {
	Status int          `json:"status"`
	Food   ExternalFood `json:"product"`
}

type ExternalFood struct {
	FoodName      string                      `json:"product_name"`
	FoodID        string                      `json:"id"`
	ReferenceUnit string                      `json:"product_quantity_unit"`
	Store         string                      `json:"stores"`
	Nutriments    ExternalSearchFoodNutriment `json:"nutriments"`
}

type ExternalSearchFoodNutriment struct {
	Calories *FlexibleFloat `json:"energy-kcal"`
	Carbs    *FlexibleFloat `json:"carbohydrates"`
	Proteins *FlexibleFloat `json:"proteins"`
	Fats     *FlexibleFloat `json:"fat"`
}
