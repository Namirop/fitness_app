package services

import (
	"encoding/json"
	"fmt"
	"go_api/models/entities"
	"go_api/models/external"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
)

func SearchExercises(query string) ([]entities.Exercise, error) {

	encodedQuery := url.QueryEscape(query)

	baseURL := os.Getenv("WGER_API_URL")
	if baseURL == "" {
		log.Fatal("WGER_API_URL manquant")
	}

	apiURL := fmt.Sprintf("%s2/exercise/search/?term=%s", baseURL, encodedQuery)

	res, err := http.Get(apiURL)
	if err != nil {
		return nil, fmt.Errorf("Wger API indisponible: %w", err)
	}
	defer res.Body.Close()

	if res.StatusCode == 429 {
		return nil, fmt.Errorf("Rate limit atteint sur API Wger (429): %d", res.StatusCode)
	}

	if res.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Wger API erreur: status %d", res.StatusCode)
	}

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("Erreur lecture réponse: %w", err)
	}

	var externalExerciseResponse external.ExternalExerciseResponse
	if err := json.Unmarshal(body, &externalExerciseResponse); err != nil {
		return nil, fmt.Errorf("Erreur parsing JSON: %w", err)
	}

	exercisesList := []entities.Exercise{}
	for _, externalExercise := range externalExerciseResponse.Exercises {
		exercise := entities.Exercise{
			ID:       strconv.Itoa(externalExercise.Data.ExerciseId),
			Name:     externalExercise.Data.Name,
			ImageUrl: GetFullImageURL(externalExercise.Data.Image),
		}
		exercisesList = append(exercisesList, exercise)
	}

	return exercisesList, nil

}
