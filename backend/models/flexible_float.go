package models

import (
	"encoding/json"
	"strconv"
)

type FlexibleFloat float64

func (f *FlexibleFloat) UnmarshalJSON(data []byte) error {
	// Essaie de parser comme float, exemple, gère "proteins": 12.3
	var num float64
	if err := json.Unmarshal(data, &num); err == nil {
		*f = FlexibleFloat(num)
		return nil
	}

	// Essaie de parser comme string, exemple, gère "proteins": "12.3"
	var str string
	if err := json.Unmarshal(data, &str); err == nil {
		if str == "" {
			*f = 0
			return nil
		}
		num, err := strconv.ParseFloat(str, 64)
		if err != nil {
			*f = 0
			return nil
		}
		*f = FlexibleFloat(num)
		return nil
	}

	// Gère un string vide ("proteins": "")
	*f = 0
	return nil

	// On ne gère pas de int car en json, "proteins": 12 est deja un float64 pour Go.
}
