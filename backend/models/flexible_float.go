package models

import (
	"encoding/json"
	"strconv"
)

type FlexibleFloat float64

func (f *FlexibleFloat) UnmarshalJSON(data []byte) error {
	// Try to parse as float, example, handles “proteins”: 12.3.
	var num float64
	if err := json.Unmarshal(data, &num); err == nil {
		*f = FlexibleFloat(num)
		return nil
	}

	// Try to parse as a string, for example, handle “proteins”: “12.3”
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

	// Handles an empty string (“proteins”: “”)
	*f = 0
	return nil

	// We don't handle int because in JSON, “proteins”: 12 is already a float64 for Go.
}
