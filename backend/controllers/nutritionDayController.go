package controllers

import (
	"encoding/json"
	"fmt"
	"go_api/initializers"
	"go_api/models"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

func GetNutritionDayByDate(c *gin.Context) {
	nutritionDayStringDate := c.Param("date")

	// Parse la date recu dans le format 'yyyy-MM-dd' (dejà fais coté client mais survérification + pour sql)
	parsedDate, parseErr := time.Parse("2006-01-02", nutritionDayStringDate)
	if parseErr != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format de date invalide"})
		return
	}

	var nutritionDay models.NutritionDay
	err := initializers.DB.
		Preload("Meals.FoodPortions.Food"). // 'Preload' assure que les tables liés à ce NutritionDay sont chargés automatiquement
		Where("DATE(date) = DATE(?)", parsedDate).
		First(&nutritionDay).Error

	fmt.Printf("nutritionDay %s,", nutritionDay.Date)

	if err == gorm.ErrRecordNotFound {
		nutritionDay = models.NutritionDay{
			Date:          parsedDate,
			TotalCalories: 0,
			TotalCarbs:    0,
			TotalProteins: 0,
			TotalFats:     0,
			Meals: []models.Meal{
				{ID: uuid.New().String(), Type: "breakfast", TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []models.FoodPortion{}},
				{ID: uuid.New().String(), Type: "lunch", TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []models.FoodPortion{}},
				{ID: uuid.New().String(), Type: "dinner", TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []models.FoodPortion{}},
				{ID: uuid.New().String(), Type: "snack", TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []models.FoodPortion{}},
			},
		}

		if err := initializers.DB.Session(&gorm.Session{FullSaveAssociations: true}).Create(&nutritionDay).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la création du nutritionDay"})
			return
		}

		initializers.DB.Preload("Meals.FoodPortions.Food").First(&nutritionDay, "id = ?", nutritionDay.ID)

	} else if err != nil {
		c.JSON(500, gin.H{"error": "Erreur serveur"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "NutrtionDay récupéré avec succès",
		"nutritionDay": nutritionDay,
	})
}

func GetFoodsFromQuery(c *gin.Context) {
	query := c.Query("q")

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Paramètre query manquant"})
		return
	}

	encodedQuery := url.QueryEscape(query)

	// "search_simple=1" est indispensable car permet une recherche fiable. Sans ca, recherche plus flou, moins cohérente, etc.
	// "json=1" = indique à OFF de renvoyer du JSON (car peut renvoyer aussi du HTML, XML ou jQuery)
	apiUrl := fmt.Sprintf("https://world.openfoodfacts.org/cgi/search.pl?search_terms=%s&search_simple=1&page_size=20&json=1&fields=product_name,id,nutriments,product_quantity_unit,stores", encodedQuery)

	res, err := http.Get(apiUrl)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "OpenFoodFacts API indisponible : " + err.Error()}) // Erreur 503, API externe down
		return
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lecture réponse : " + err.Error()})
		return
	}

	var externalSearchFoodResponse models.ExternalSearchFoodResponse
	if err := json.Unmarshal(body, &externalSearchFoodResponse); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur parsing JSON OpenFoodFacts : " + err.Error()})
		return
	}

	foodList := []models.Food{}

	for _, product := range externalSearchFoodResponse.Food {
		food := models.Food{
			ID:                product.FoodID,
			Name:              product.FoodName,
			ReferenceQuantity: 100,
			ReferenceUnit:     product.ReferenceUnit,
			Store:             product.Store,
			Calories:          safeDouble(product.Nutriments.Calories),
			Carbs:             safeDouble(product.Nutriments.Carbs),
			Proteins:          safeDouble(product.Nutriments.Proteins),
			Fats:              safeDouble(product.Nutriments.Fats),
			IsFavorite:        false,
		}
		foodList = append(foodList, food)
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "Liste de nourriture récupérées avec succès",
		"foodList": foodList,
	})

}

func UpdateNutritionDay(c *gin.Context) {
	id := c.Param("id")

	var existingNutritionDay models.NutritionDay
	if err := c.ShouldBindJSON(&existingNutritionDay); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Json invalide : " + err.Error(),
		})
		return
	}

	if existingNutritionDay.ID != id {
		c.JSON(400, gin.H{"error": "ID mismatch"})
		return
	}

	// ✅ 1. Supprime TOUS les meals et leurs portions associés
	initializers.DB.Exec("DELETE FROM food_portions WHERE meal_id IN (SELECT id FROM meals WHERE nutrition_day_id = ?)", id)
	initializers.DB.Exec("DELETE FROM meals WHERE nutrition_day_id = ?", id)

	// Génère IDs manquants
	for i := range existingNutritionDay.Meals {
		if existingNutritionDay.Meals[i].ID == "" {
			existingNutritionDay.Meals[i].ID = uuid.New().String()
		}
		for j := range existingNutritionDay.Meals[i].FoodPortions {
			if existingNutritionDay.Meals[i].FoodPortions[j].ID == "" {
				existingNutritionDay.Meals[i].FoodPortions[j].ID = uuid.New().String()
			}
		}
	}

	// ✅ 3. Sauvegarde (va recréer tous les meals et portions)
	if err := initializers.DB.Save(&existingNutritionDay).Error; err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	// Recharge
	var updatedNutritionDay models.NutritionDay
	initializers.DB.
		Preload("Meals").
		Preload("Meals.FoodPortions").
		Preload("Meals.FoodPortions.Food").
		First(&updatedNutritionDay, "id = ?", id)

	c.JSON(http.StatusOK, gin.H{
		"message":      "NutritionDay modifié",
		"nutritionDay": updatedNutritionDay,
	})
}

func safeDouble(f *models.FlexibleFloat) float64 {
	if f == nil {
		return 0.0
	}
	return float64(*f)
}
