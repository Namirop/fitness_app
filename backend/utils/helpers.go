package utils

import "go_api/models/external"

// Helper for enum validation
func Contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func SafeDouble(f *external.FlexibleFloat) float64 {
	if f == nil {
		return 0.0
	}
	return float64(*f)
}
