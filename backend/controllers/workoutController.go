package controllers

import (
	"encoding/json"
	"fmt"
	"go_api/initializers"
	"go_api/models"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GetWorkouts(c *gin.Context) {
	var existingWorkouts []models.Workout
	initializers.DB.Preload("Exercises.Exercise").Find(&existingWorkouts)
	c.JSON(http.StatusOK, gin.H{
		"message":          "Workouts récupérés avec succès",
		"existingWorkouts": existingWorkouts,
	})
}

func CreateWorkout(c *gin.Context) {

	var workout models.Workout
	if err := c.ShouldBindJSON(&workout); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Json invalide : " + err.Error(),
		})
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
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Erreur lors de la création du workout: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":        "Workout créé avec succès",
		"createdWorkout": workout,
	})
}

func UpdateWorkout(c *gin.Context) {
	workoutID := c.Param("id")

	var workoutReceived models.Workout
	if err := c.ShouldBindJSON(&workoutReceived); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "JSON invalide : " + err.Error(),
		})
		return
	}

	var updatedWorkout models.Workout
	if err := initializers.DB.Preload("Exercises").First(&updatedWorkout, "id = ?", workoutID).Error; err != nil {
		c.JSON(404, gin.H{"error": "Workout introuvable"})
		return
	}

	updatedWorkout.Title = workoutReceived.Title
	updatedWorkout.Note = workoutReceived.Note
	updatedWorkout.Date = workoutReceived.Date

	initializers.DB.Where("workout_id = ?", workoutID).Delete(&models.WorkoutExercise{})

	for i := range workoutReceived.Exercises {
		workoutReceived.Exercises[i].WorkoutID = updatedWorkout.ID
	}
	updatedWorkout.Exercises = workoutReceived.Exercises

	if err := initializers.DB.Save(&updatedWorkout).Error; err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":        "Workout modifié avec succès",
		"updatedWorkout": updatedWorkout,
	})
}

func DeleteWorkout(c *gin.Context) {

	workoutID := c.Param("id")

	if workoutID == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "ID manquant",
		})
		return
	}

	result := initializers.DB.Delete(&models.Workout{}, "id = ?", workoutID)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Workout introuvable",
		})
		return
	}

	var updatedWorkouts []models.Workout
	if err := initializers.DB.Preload("Exercises.Exercise").Find(&updatedWorkouts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	c.JSON(http.StatusOK, gin.H{
		"message":         "Workout supprimé avec succès",
		"updatedWorkouts": updatedWorkouts,
	})
}

func GetExercisesFromQuery(c *gin.Context) {
	query := c.Query("q")

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing query"})
		return
	}

	encodedQuery := url.QueryEscape(query)

	apiUrl := fmt.Sprintf("https://wger.de/api/v2/exercise/search/?term=%s", encodedQuery)

	res, err := http.Get(apiUrl)

	if err != nil {
		fmt.Println("❌ Erreur HTTP GET:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	defer res.Body.Close()

	if res.StatusCode == 429 {
		fmt.Println("⚠️ Rate limit atteint (429)")
		c.JSON(http.StatusTooManyRequests, gin.H{
			"error": "Too many requests to Exercise API. Please try again later.",
		})
		return
	}

	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println("❌ Erreur ReadAll:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response body : " + err.Error()})
		return
	}

	var externalExerciseResponse models.ExternalExerciseResponse
	if err := json.Unmarshal(body, &externalExerciseResponse); err != nil {
		fmt.Println("❌ Erreur Unmarshal:", err)
		c.JSON(500, gin.H{"error": "Failed to parse: " + err.Error()})
		return
	}

	exercisesList := []models.Exercise{}

	for _, externalExercise := range externalExerciseResponse.Exercises {
		exercise := models.Exercise{
			ID:       strconv.Itoa(externalExercise.Data.ExerciseId),
			Name:     externalExercise.Data.Name,
			ImageUrl: GetFullImageURL(externalExercise.Data.Image),
		}
		exercisesList = append(exercisesList, exercise)
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Exercises sur base de la requête, recupérés avec succès",
		"exercises": exercisesList,
	})
}

func getEnglishExerciseDescription(exercise models.ExternalExerciseDetailResponse) string {
	for _, translation := range exercise.Translations {
		if translation.Language == 2 {
			return translation.Description
		}
	}

	if len(exercise.Translations) > 0 {
		return exercise.Translations[0].Description
	}
	return ""
}

func getEnglishExerciseName(exercise models.ExternalExerciseDetailResponse) string {
	for _, translation := range exercise.Translations {
		if translation.Language == 12 {
			return translation.Name
		}
	}

	if len(exercise.Translations) > 0 {
		return exercise.Translations[0].Name
	}
	return ""
}

func getMainImage(exercise models.ExternalExerciseDetailResponse) string {
	for _, img := range exercise.Images {
		if img.IsMain {
			return img.Image
		}
	}
	if len(exercise.Images) > 0 {
		return exercise.Images[0].Image
	}
	return ""
}

func getMainVideo(exercise models.ExternalExerciseDetailResponse) string {
	for _, vid := range exercise.Videos {
		if vid.IsMain {
			return vid.Video
		}
	}
	if len(exercise.Videos) > 0 {
		return exercise.Videos[0].Video
	}
	return ""
}

func GetFullImageURL(imagePath string) string {
	if imagePath == "" {
		return ""
	}
	if strings.HasPrefix(imagePath, "http") {
		return imagePath
	}
	return "https://wger.de" + imagePath
}
