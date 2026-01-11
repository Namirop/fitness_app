package services

import (
	"encoding/json"
	"fmt"
	"go_api/models/entities"
	"go_api/models/external"
	"go_api/utils"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
)

func SearchFoods(query string) ([]entities.Food, error) {
	encodedQuery := url.QueryEscape(query)

	baseURL := os.Getenv("OPENFOODFACTS_API_URL")
	if baseURL == "" {
		log.Fatal("OPENFOODFACTS_API_URL manquant")
	}
	/// “search_simple=1” is essential because it enables reliable searching. Without it, searching is more vague, less consistent, etc.
	// “json=1” = tells OFF to return JSON (because it can also return HTML, XML, or jQuery)
	apiURL := fmt.Sprintf(
		"%s/search.pl?search_terms=%s&search_simple=1&page_size=20&json=1&fields=product_name,id,nutriments,product_quantity_unit,stores",
		baseURL,
		encodedQuery,
	)

	res, err := http.Get(apiURL)
	if err != nil {
		return nil, fmt.Errorf("OpenFoodFacts API indisponible: %w", err)
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("OpenFoodFacts API erreur: status %d", res.StatusCode)
	}

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("Erreur lecture réponse: %w", err)
	}

	var externalSearchFoodResponse external.ExternalSearchFoodsResponse
	if err := json.Unmarshal(body, &externalSearchFoodResponse); err != nil {
		return nil, fmt.Errorf("Erreur parsing JSON: %w", err)
	}

	foodList := make([]entities.Food, 0, len(externalSearchFoodResponse.Food))

	for _, externalFood := range externalSearchFoodResponse.Food {
		food := entities.Food{
			ID:                externalFood.FoodID,
			Name:              externalFood.FoodName,
			ReferenceQuantity: 100,
			ReferenceUnit:     externalFood.ReferenceUnit,
			Store:             externalFood.Store,
			Calories:          utils.SafeDouble(externalFood.Nutriments.Calories),
			Carbs:             utils.SafeDouble(externalFood.Nutriments.Carbs),
			Proteins:          utils.SafeDouble(externalFood.Nutriments.Proteins),
			Fats:              utils.SafeDouble(externalFood.Nutriments.Fats),
			IsFavorite:        false,
		}
		foodList = append(foodList, food)
	}

	return foodList, nil
}

func FetchFoodByID(foodID string) (*entities.Food, error) {
	apiURL := fmt.Sprintf("https://world.openfoodfacts.org/api/v2/product/%s?fields=product_name,id,nutriments,product_quantity_unit,stores", foodID)

	res, err := http.Get(apiURL)
	if err != nil {
		return nil, fmt.Errorf("OpenFoodFacts API indisponible: %w", err)
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("Erreur lecture réponse: %w", err)
	}

	var externalFood external.ExternalSearchFoodIdResponse
	if err := json.Unmarshal(body, &externalFood); err != nil {
		return nil, fmt.Errorf("Erreur parsing JSON: %w", err)
	}

	food := &entities.Food{
		ID:                externalFood.Food.FoodID,
		Name:              externalFood.Food.FoodName,
		Calories:          utils.SafeDouble(externalFood.Food.Nutriments.Calories),
		Carbs:             utils.SafeDouble(externalFood.Food.Nutriments.Carbs),
		Proteins:          utils.SafeDouble(externalFood.Food.Nutriments.Proteins),
		Fats:              utils.SafeDouble(externalFood.Food.Nutriments.Fats),
		ReferenceQuantity: 100,
		ReferenceUnit:     externalFood.Food.ReferenceUnit,
	}

	return food, nil
}
