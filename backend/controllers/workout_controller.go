package controllers

import (
	"go_api/initializers"
	"go_api/models/entities"
	"go_api/services"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GetWorkouts(c *gin.Context) {
	var workouts []entities.Workout
	if err := initializers.DB.Preload("Exercises.Exercise").Find(&workouts).Error; err != nil {
		log.Printf("Erreur récupération workouts: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de récupérer les entraînements"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message":  "Entraînements récupérés avec succès",
		"workouts": workouts,
	})
}

func CreateWorkout(c *gin.Context) {
	var workout entities.Workout
	if err := c.ShouldBindJSON(&workout); err != nil {
		log.Printf("JSON invalide: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	if strings.TrimSpace(workout.Title) == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le titre est obligatoire",
		})
		return
	}

	if workout.Date.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "La date est obligatoire",
		})
		return
	}

	if len(workout.Exercises) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Au moins un exercice est requis",
		})
		return
	}

	if err := initializers.DB.Session(&gorm.Session{FullSaveAssociations: true}).Create(&workout).Error; err != nil {
		log.Printf("Erreur création workout: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de créer l'entraînement"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Entraînement créé avec succès",
		"workout": workout,
	})
}

func UpdateWorkout(c *gin.Context) {
	workoutID := c.Param("workout_id")

	if workoutID == "" {
		log.Println("ID workout manquant dans l'URL")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	var payload entities.Workout
	if err := c.ShouldBindJSON(&payload); err != nil {
		log.Printf("JSON invalide: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	if payload.ID != workoutID {
		log.Printf("ID mismatch: payload=%s, url=%s", payload.ID, workoutID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	if strings.TrimSpace(payload.Title) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Le titre est obligatoire"})
		return
	}

	if payload.Date.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "La date est obligatoire"})
		return
	}

	if len(payload.Exercises) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Au moins un exercice est requis"})
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

	var existingWorkout entities.Workout
	if err := tx.First(&existingWorkout, "id = ?", workoutID).Error; err != nil {
		log.Printf("Erreur recherche workout ID=%s: %v", workoutID, err)
		tx.Rollback()
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Entraînement introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche de l'entraînement"})
		}
		return
	}
	// if err := tx.Preload("Exercises").First(&existingWorkout, "id = ?", workoutID).Error; err != nil {
	// 	log.Printf("Erreur recherche workout ID=%s: %v", workoutID, err)
	// 	tx.Rollback()
	// 	if err == gorm.ErrRecordNotFound {
	// 		c.JSON(http.StatusNotFound, gin.H{"error": "Entraînement introuvable"})
	// 	} else {
	// 		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche de l'entraînement"})
	// 	}
	// 	return
	// }

	existingWorkout.Title = payload.Title
	existingWorkout.Note = payload.Note
	existingWorkout.Date = payload.Date

	if err := tx.Where("workout_id = ?", workoutID).Delete(&entities.WorkoutExercise{}).Error; err != nil {
		log.Printf("Erreur suppression exercices pour workout ID=%s: %v", workoutID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour les exercices"})
		return
	}

	for i := range payload.Exercises {
		payload.Exercises[i].WorkoutID = existingWorkout.ID
	}
	existingWorkout.Exercises = payload.Exercises

	if err := tx.Save(&existingWorkout).Error; err != nil {
		log.Printf("Erreur sauvegarde workout ID=%s: %v", workoutID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de sauvegarder l'entraînement"})
		return
	}

	var workout entities.Workout
	if err := tx.Preload("Exercises.Exercise").First(&workout, "id = ?", workoutID).Error; err != nil {
		log.Printf("Erreur rechargement workout ID=%s: %v", workoutID, err)
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de charger l'entraînement mis à jour"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		log.Printf("Erreur commit transaction UpdateWorkout: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de sauvegarder les modifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Entraînement modifié avec succès",
		"workout": workout,
	})
}

func DeleteWorkout(c *gin.Context) {
	workoutID := c.Param("workout_id")

	if workoutID == "" {
		log.Println("ID workout manquant dans l'URL")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	result := initializers.DB.Delete(&entities.Workout{}, "id = ?", workoutID)

	if result.Error != nil {
		log.Printf("Erreur suppression workout ID=%s: %v", workoutID, result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de supprimer l'entraînement"})
		return
	}

	if result.RowsAffected == 0 {
		log.Printf("Workout ID=%s introuvable", workoutID)
		c.JSON(http.StatusNotFound, gin.H{"error": "Entraînement introuvable"})
		return
	}

	var workouts []entities.Workout
	if err := initializers.DB.Preload("Exercises.Exercise").Find(&workouts).Error; err != nil {
		log.Printf("Erreur récupération workouts après suppression: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de récupérer les entraînements"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "Entraînement supprimé avec succès",
		"workouts": workouts,
	})
}

func GetExercisesFromQuery(c *gin.Context) {
	query := c.Query("q")

	if query == "" {
		log.Println("Paramètre de recherche manquant")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Veuillez effectuer une recherche"})
		return
	}

	fetchedExerciseList, fetchErr := services.SearchExercises(query)

	if fetchErr != nil {
		log.Printf("Erreur recherche exercices pour query '%s': %v", query, fetchErr)
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "La recherche est temporairement indisponible"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Exercices récupérés avec succès",
		"exercises": fetchedExerciseList,
	})
}
