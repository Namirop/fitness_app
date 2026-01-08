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

	// On utilise Preload pour charger les relations entre les tables en une seule requête SQL.
	// "Exercises" = charge tous les WorkoutExercise liés à chaque Workout.
	// "Exercises.Exercise" = pour chaque WorkoutExercise, charge aussi les données complètes de l'exercice associé.
	// Sans ce Preload imbriqué, GORM laisserait le champ "exercise" vide dans le JSON.
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

	// GORM insère le record dans la DB.
	// "Session(&gorm.Session{FullSaveAssociations: true})" => Pourquoi ?
	// Mon struct Go Workout contient un slice de WorkoutExercise. Avec juste DB.Create(&workout), GORM va créer le workout, mais il ne va pas automatiquement créer les lignes dans la table pivot workout_exercices avec les sets/reps/weight.
	// Il faut dire explicitement à GORM « quand tu crées un workout, crée aussi toutes les associations avec les exercices et remplis la table workout_exercises » => Preload/Associations
	// "FullSaveAssociations" true indique à GORM de sauver aussi toutes les structs imbriquées (ici WorkoutExercise) dans leur table respective.

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

	// Charge le workout existant avec ses exercices
	var updatedWorkout models.Workout
	if err := initializers.DB.Preload("Exercises").First(&updatedWorkout, "id = ?", workoutID).Error; err != nil {
		c.JSON(404, gin.H{"error": "Workout introuvable"})
		return
	}

	// Update les champs simples
	updatedWorkout.Title = workoutReceived.Title
	updatedWorkout.Note = workoutReceived.Note
	updatedWorkout.Date = workoutReceived.Date

	// Supprime les anciens exercices
	initializers.DB.Where("workout_id = ?", workoutID).Delete(&models.WorkoutExercise{})

	// Ajoute les nouveaux exercices avec le bon WorkoutID
	for i := range workoutReceived.Exercises {
		workoutReceived.Exercises[i].WorkoutID = updatedWorkout.ID
	}
	updatedWorkout.Exercises = workoutReceived.Exercises

	// Save tout
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

	// Ici on peut avoir une slice vide, cela supprimera quand meme dans la db au bon endroit car mention d'un WHERE.
	// L'exemple avec le cas où on veut supprimer tous les workouts, comme pas de where, le code en comm ne marche pas (sécurité gorm) => du coup on a utilisé un 'AllowGlobalUpdate'
	result := initializers.DB.Delete(&models.Workout{}, "id = ?", workoutID)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	// Vérifie si au moins une ligne a été supprimée
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

func DeleteWorkouts(c *gin.Context) {
	// var workouts []models.Workout
	// initializers.DB.Delete(&workouts)
	// c.JSON(200, "")
	// => pas correcte, il faut remplir le slice

	// Méthode la plus sécurisé :
	result := initializers.DB.Session(&gorm.Session{
		AllowGlobalUpdate: true,
	}).Delete(&models.Workout{})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": result.Error.Error(),
		})
		return
	}

	// Nettoie les exercices orphelins
	// => RETIRER PLUS TARD SI ON VEUT EXPLOITER LA TABLE 'Exercises'
	initializers.DB.Exec(`
		DELETE FROM exercises 
		WHERE id NOT IN (
			SELECT DISTINCT exercise_id FROM workout_exercises
		)
	`)

	c.JSON(http.StatusOK, gin.H{
		"message": "Tous les workouts ont été supprimé avec succès",
	})

	// Pourquoi la meilleur ? :
	// ❌ Bloqué par GORM (erreur)
	// DB.Delete(&models.Workout{})

	// ✅ Autorisé explicitement
	// DB.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&models.Workout{})

	// => GORM bloque par défaut les DELETE/UPDATE sans WHERE pour éviter les suppressions accidentelles. D'ou l'utilisation du AllowGlobalUpdate

	// Autre méthode plus classique mais correcte et conventionnelle (ou l'on rempli le slice):

	// var workouts []models.Workout
	// if err := initializers.DB.Find(&workouts).Error; err != nil {
	// 	c.JSON(500, gin.H{"error": err.Error()})
	// 	return
	// }

	// result := initializers.DB.Delete(&workouts)

	// if result.Error != nil {
	// 	c.JSON(500, gin.H{"error": result.Error.Error()})
	// 	return
	// }

	// c.JSON(200, gin.H{
	//     "message": "All workouts deleted",
	//     "deleted_count": result.RowsAffected,
	// })

}

func GetExercisesFromQuery(c *gin.Context) {
	query := c.Query("q")

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing query"})
		return
	}

	// Encode les espaces, etc. et permet d'éviter tout souci de caractères spéciaux-
	encodedQuery := url.QueryEscape(query)

	// 'fmt.Sprintf' permet de construire dynamiquement une chaîne de texte en insérant la variable 'query' dans '%s'.
	// '%s' veut dire 'à cet endroit, insère la chaîne passée en paramètre'
	// apiUrl := fmt.Sprintf("https://v2.exercisedb.dev/api/v1/exercises/search?search=%s", encodedQuery)

	apiUrl := fmt.Sprintf("https://wger.de/api/v2/exercise/search/?term=%s", encodedQuery)

	res, err := http.Get(apiUrl)

	// Gestion de l'erreur de la requete http
	if err != nil {
		fmt.Println("❌ Erreur HTTP GET:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Gestion de la réponse de la requête http
	// 'defer' => exécute cette ligne à la fin de la fonction, peu importe si erreur ou pas => bonne pratique, évite les fuites de ressources
	// 'res.Body' représente le flux de données renvoyé par le serveur HTTP (la réponse)
	// 'Close()' ferme ce flux pour libérer de la mémoire
	defer res.Body.Close()

	if res.StatusCode == 429 {
		fmt.Println("⚠️ Rate limit atteint (429)")
		c.JSON(http.StatusTooManyRequests, gin.H{
			"error": "Too many requests to Exercise API. Please try again later.",
		})
		return
	}

	// Cette ligne lit tout le contenu du res.Body et le stocke dans la variable body.
	// body est un []byte, donc il faut souvent le convertir en string ou le décoder en JSON ensuite.
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println("❌ Erreur ReadAll:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response body : " + err.Error()})
		return
	}

	// On aurait pu faire :
	// body, _ := io.ReadAll(res.Body)
	// io.ReadAll() renvoie deux valeurs.
	// le '_' sert souvent à ignorer une valeur qu’on ne veut pas, ici par exemple l’erreur, mais mieux vaut toujours la vérifier.

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

	// ------------------ AUTRE METHODE MAIS MOINS CONVENTIONNEL (je garde pour la compréhension de la syntaxe Golang) ------------------

	// Cette ligne signifie une collection clé-valeur où les clés sont des string, et les valeurs peuvent être de n'importe quel type
	// On l’utilise ici pour décoder un JSON dont on ne connaît pas exactement la structure complète ou dont on veut juste prendre certains champs.
	//var result map[string]interface{}

	// 'Unmarshal' convertit un JSON en structures Go
	// '&result' passe l’adresse de notre map pour que Unmarshal y écrive les données.
	// En gros, le body de la réponse :
	/* {
		"success": true,
		"data": [ ... ]
	} */
	// après le Unmarshal :
	// result["success"] // true
	// result["data"]    // []interface{} contenant chaque exercice
	/* if err := json.Unmarshal(body, &result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse JSON : " + err.Error()})
	} */

	// On récupère la clé data du map result
	// La syntaxe .(type) en Go est un type assertion, elle permet de convertir un interface{} en type concret.
	// []interface{} correspond à un tableau JSON (JSON array) dont les éléments sont de type générique.
	//data, ok := result["data"].([]interface{})
	// On gère la conversion
	/* if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid data format"})
		return
	} */

	/* var exercises []models.Exercise
	for _, item := range data {
		exMap := item.(map[string]interface{}) // chaque exercice est un map

		exercise := models.Exercise{
			ID:          fmt.Sprintf("%v", exMap["exerciseId"]),
			Name:        fmt.Sprintf("%v", exMap["name"]),
			Description: "", // pas dispo dans l'API
		}
		exercises = append(exercises, exercise)
	} */

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
	// Si c'est déjà une URL complète
	if strings.HasPrefix(imagePath, "http") {
		return imagePath
	}
	// Sinon ajoute le domaine
	return "https://wger.de" + imagePath
}
