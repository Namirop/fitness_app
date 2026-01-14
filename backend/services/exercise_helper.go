package services

import (
	"strings"
)

func GetFullImageURL(imagePath string) string {
	if imagePath == "" {
		return ""
	}
	if strings.HasPrefix(imagePath, "http") {
		return imagePath
	}
	return "https://wger.de" + imagePath
}
