package controllers

import (
	"go_api/initializers"
	"go_api/models/dto"
	"go_api/models/entities"
	"go_api/services"

	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

func GetNutritionDayByDate(c *gin.Context) {
	nutritionDayStringDate := c.Param("date")

	parsedDate, parseErr := time.Parse("2006-01-02", nutritionDayStringDate)
	if parseErr != nil {
		log.Printf("Format de date invalide: %s", nutritionDayStringDate)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}
	var nutritionDay entities.NutritionDay
	err := initializers.DB.
		Preload("Meals", func(db *gorm.DB) *gorm.DB {
			return db.Order("position ASC")
		}).
		Preload("Meals.FoodPortions.Food").
		Where("DATE(date) = DATE(?)", parsedDate).
		First(&nutritionDay).Error

	if err == gorm.ErrRecordNotFound {
		nutritionDay = entities.NutritionDay{
			Date:          parsedDate,
			TotalCalories: 0,
			TotalCarbs:    0,
			TotalProteins: 0,
			TotalFats:     0,
			Meals: []entities.Meal{
				{ID: uuid.New().String(), Type: "breakfast", Position: 1, TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []entities.FoodPortion{}},
				{ID: uuid.New().String(), Type: "lunch", Position: 2, TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []entities.FoodPortion{}},
				{ID: uuid.New().String(), Type: "dinner", Position: 3, TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []entities.FoodPortion{}},
				{ID: uuid.New().String(), Type: "snack", Position: 4, TotalCalories: 0, TotalCarbs: 0, TotalProteins: 0, TotalFats: 0, FoodPortions: []entities.FoodPortion{}},
			},
		}

		if err := initializers.DB.Session(&gorm.Session{FullSaveAssociations: true}).Create(&nutritionDay).Error; err != nil {
			log.Printf("Erreur création NutritionDay pour date %s: %v", parsedDate.Format("2006-01-02"), err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de créer le jour nutritionnel"})
			return
		}

		if err := initializers.DB.Preload("Meals", func(db *gorm.DB) *gorm.DB {
			return db.Order("position ASC")
		}).
			Preload("Meals.FoodPortions.Food").
			First(&nutritionDay, "id = ?", nutritionDay.ID).Error; err != nil {
			log.Printf("Erreur rechargement NutritionDay après création: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de charger le jour nutritionnel"})
			return
		}

	} else if err != nil {
		log.Printf("Erreur récupération NutritionDay pour date %s: %v", parsedDate.Format("2006-01-02"), err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de récupérer le jour nutritionnel"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "NutritionDay récupéré avec succès",
		"nutritionDay": nutritionDay,
	})
}

func GetFoodsFromQuery(c *gin.Context) {
	query := c.Query("q")

	if query == "" {
		log.Println("Paramètre de recherche manquant")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Veuillez effectuer une recherche"})
		return
	}
	fetchedFoodList, fetchErr := services.SearchFoods(query)

	if fetchErr != nil {
		log.Printf("Erreur recherche aliments pour query '%s': %v", query, fetchErr)
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "La recherche est temporairement indisponible"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "Liste de nourriture récupérées avec succès",
		"foodList": fetchedFoodList,
	})

}

func AddFoodPortion(c *gin.Context) {
	mealID := c.Param("meal_id")

	if mealID == "" {
		log.Println("ID meal manquant dans l'URL")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	var payload dto.AddFoodPortionDto
	if err := c.ShouldBindJSON(&payload); err != nil {
		log.Printf("JSON invalide: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	if payload.MealId != mealID {
		log.Printf("ID mismatch: payload=%s, url=%s", payload.MealId, mealID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	if payload.NutritionDayId == "" {
		log.Println("NutritionDayId manquant dans le payload")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	if payload.FoodID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Aucun aliment sélectionné"})
		return
	}

	if payload.Quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "La quantité doit être supérieure à 0"})
		return
	}

	tx := initializers.DB.Begin()

	if tx.Error != nil {
		log.Printf("Erreur démarrage transaction: %v", tx.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Service temporairement indisponible"})
		return
	}
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	var meal entities.Meal
	if err := tx.First(&meal, "id = ?", mealID).Error; err != nil {
		log.Printf("Erreur recherche Meal ID=%s: %v", mealID, err)
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Repas introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche du repas"})
		}
		return
	}

	var food entities.Food
	err := tx.First(&food, "id = ?", payload.FoodID).Error

	if err == gorm.ErrRecordNotFound {
		fetchedFood, fetchErr := services.FetchFoodByID(payload.FoodID)

		if fetchErr != nil {
			log.Printf("Erreur fetch OpenFoodFacts pour ID=%s: %v", payload.FoodID, fetchErr)
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"error": "Aliment introuvable"})
			return
		}

		if err := tx.Create(fetchedFood).Error; err != nil {
			log.Printf("Erreur création Food ID=%s: %v", fetchedFood.ID, err)
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de créer l'aliment"})
			return
		}
		food = *fetchedFood
	} else if err != nil {
		log.Printf("Erreur DB recherche Food ID=%s: %v", payload.FoodID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la vérification de l'aliment"})
		return
	}

	ratio := payload.Quantity / food.ReferenceQuantity

	calories := food.Calories * ratio
	carbs := food.Carbs * ratio
	proteins := food.Proteins * ratio
	fats := food.Fats * ratio

	portion := entities.FoodPortion{
		MealID:        meal.ID,
		FoodID:        food.ID,
		Quantity:      payload.Quantity,
		TotalCalories: calories,
		TotalCarbs:    carbs,
		TotalProteins: proteins,
		TotalFats:     fats,
	}

	if err := tx.Create(&portion).Error; err != nil {
		log.Printf("Erreur création FoodPortion pour Food ID=%s, Meal ID=%s: %v", food.ID, meal.ID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible d'ajouter la portion"})
		return
	}

	if err := tx.Model(&meal).Updates(map[string]interface{}{
		"total_calories": gorm.Expr("total_calories + ?", calories),
		"total_carbs":    gorm.Expr("total_carbs + ?", carbs),
		"total_proteins": gorm.Expr("total_proteins + ?", proteins),
		"total_fats":     gorm.Expr("total_fats + ?", fats),
	}).Error; err != nil {
		log.Printf("Erreur update Meal ID=%s: %v", meal.ID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour le repas"})
		return
	}

	if err := tx.Model(&entities.NutritionDay{}).
		Where("id = ?", payload.NutritionDayId).
		Updates(map[string]interface{}{
			"total_calories": gorm.Expr("total_calories + ?", calories),
			"total_carbs":    gorm.Expr("total_carbs + ?", carbs),
			"total_proteins": gorm.Expr("total_proteins + ?", proteins),
			"total_fats":     gorm.Expr("total_fats + ?", fats),
		}).Error; err != nil {
		log.Printf("Erreur update NutritionDay ID=%s: %v", payload.NutritionDayId, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour le jour nutritionnel"})
		return
	}

	var updatedNutritionDay = entities.NutritionDay{}
	if err := tx.Preload("Meals", func(db *gorm.DB) *gorm.DB {
		return db.Order("position ASC")
	}).
		Preload("Meals.FoodPortions.Food").
		First(&updatedNutritionDay, "id = ?", payload.NutritionDayId).
		Error; err != nil {
		log.Printf("Erreur rechargement NutritionDay ID=%s: %v", payload.NutritionDayId, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de charger le jour nutritionnel"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		log.Printf("Erreur commit transaction AddFoodPortion: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de sauvegarder les modifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Portion ajoutée",
		"nutritionDay": updatedNutritionDay,
	})
}

func DeleteFoodPortion(c *gin.Context) {
	foodPortionID := c.Param("food_portion_id")

	if foodPortionID == "" {
		log.Println("ID FoodPortion manquant dans l'URL")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	tx := initializers.DB.Begin()

	if tx.Error != nil {
		log.Printf("Erreur démarrage transaction: %v", tx.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Service temporairement indisponible"})
		return
	}
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	var portion entities.FoodPortion
	if err := tx.First(&portion, "id = ?", foodPortionID).Error; err != nil {
		log.Printf("Erreur recherche FoodPortion ID=%s: %v", foodPortionID, err)
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Portion introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche de la portion"})
		}
		return
	}
	var meal entities.Meal
	if err := tx.First(&meal, "id = ?", portion.MealID).Error; err != nil {
		log.Printf("Erreur recherche Meal ID=%s: %v", portion.MealID, err)
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Repas introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche du repas"})
		}
		return
	}

	if err := tx.Delete(&portion).Error; err != nil {
		log.Printf("Erreur suppression FoodPortion ID=%s: %v", foodPortionID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de supprimer la portion"})
		return
	}

	if err := tx.Model(&meal).Updates(map[string]interface{}{
		"total_calories": gorm.Expr("total_calories - ?", portion.TotalCalories),
		"total_carbs":    gorm.Expr("total_carbs - ?", portion.TotalCarbs),
		"total_proteins": gorm.Expr("total_proteins - ?", portion.TotalProteins),
		"total_fats":     gorm.Expr("total_fats - ?", portion.TotalFats),
	}).Error; err != nil {
		log.Printf("Erreur update Meal ID=%s après suppression: %v", meal.ID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour le repas"})
		return
	}

	if err := tx.Model(&entities.NutritionDay{}).
		Where("id = ?", meal.NutritionDayID).
		Updates(map[string]interface{}{
			"total_calories": gorm.Expr("total_calories - ?", portion.TotalCalories),
			"total_carbs":    gorm.Expr("total_carbs - ?", portion.TotalCarbs),
			"total_proteins": gorm.Expr("total_proteins - ?", portion.TotalProteins),
			"total_fats":     gorm.Expr("total_fats - ?", portion.TotalFats),
		}).Error; err != nil {
		log.Printf("Erreur update NutritionDay ID=%s après suppression: %v", meal.NutritionDayID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour le jour nutritionnel"})
		return
	}

	var updatedNutritionDay = entities.NutritionDay{}
	if err := tx.Preload("Meals", func(db *gorm.DB) *gorm.DB {
		return db.Order("position ASC")
	}).
		Preload("Meals.FoodPortions.Food").
		First(&updatedNutritionDay, "id = ?", meal.NutritionDayID).
		Error; err != nil {
		log.Printf("Erreur rechargement NutritionDay ID=%s: %v", meal.NutritionDayID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de charger le jour nutritionnel"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		log.Printf("Erreur commit transaction DeleteFoodPortion: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de sauvegarder les modifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Portion supprimée",
		"nutritionDay": updatedNutritionDay,
	})

}
