package services

import (
	"go_api/models/external"
	"strings"
)

func getEnglishExerciseDescription(exercise external.ExternalExerciseDetailResponse) string {
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

func getEnglishExerciseName(exercise external.ExternalExerciseDetailResponse) string {
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

func getMainImage(exercise external.ExternalExerciseDetailResponse) string {
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

func getMainVideo(exercise external.ExternalExerciseDetailResponse) string {
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
