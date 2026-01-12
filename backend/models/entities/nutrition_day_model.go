// DB structs (GORM)
package entities

import "time"

type NutritionDay struct {
	ID            string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID        uint      `gorm:"index;not null"`
	Date          time.Time `gorm:"not null;uniqueIndex" json:"date"`
	TotalCalories float64   `gorm:"default:0;check:total_calories >= 0" json:"totalCalories"`
	TotalCarbs    float64   `gorm:"default:0;check:total_carbs >= 0" json:"totalCarbs"`
	TotalProteins float64   `gorm:"default:0;check:total_proteins >= 0" json:"totalProteins"`
	TotalFats     float64   `gorm:"default:0;check:total_fats >= 0" json:"totalFats"`
	Meals         []Meal    `gorm:"foreignKey:NutritionDayID;constraint:OnDelete:CASCADE" json:"meals"`
	CreatedAt     time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}

type Meal struct {
	ID             string        `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	NutritionDayID string        `gorm:"type:uuid;not null;index" json:"-"`
	Type           string        `gorm:"type:varchar(50);not null" json:"type"`
	CustomName     *string       `gorm:"type:varchar(100)" json:"customName,omitempty"`
	Position       int           `gorm:"default:0" json:"-"`
	TotalCalories  float64       `gorm:"default:0;check:total_calories >= 0" json:"totalCalories"`
	TotalCarbs     float64       `gorm:"default:0;check:total_carbs >= 0" json:"totalCarbs"`
	TotalProteins  float64       `gorm:"default:0;check:total_proteins >= 0" json:"totalProteins"`
	TotalFats      float64       `gorm:"default:0;check:total_fats >= 0" json:"totalFats"`
	FoodPortions   []FoodPortion `gorm:"foreignKey:MealID;constraint:OnDelete:CASCADE" json:"foodPortions"`
	CreatedAt      time.Time     `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt      time.Time     `gorm:"autoUpdateTime" json:"updatedAt"`
}

type FoodPortion struct {
	ID            string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID        uint      `gorm:"index;not null"`
	MealID        string    `gorm:"type:uuid;not null;index" json:"-"`
	FoodID        string    `gorm:"type:varchar(255);not null;index" json:"-"`
	Quantity      float64   `gorm:"not null;check:quantity > 0" json:"quantity"`
	TotalCalories float64   `gorm:"default:0;check:total_calories >= 0" json:"totalCalories"`
	TotalCarbs    float64   `gorm:"default:0;check:total_carbs >= 0" json:"totalCarbs"`
	TotalProteins float64   `gorm:"default:0;check:total_proteins >= 0" json:"totalProteins"`
	TotalFats     float64   `gorm:"default:0;check:total_fats >= 0" json:"totalFats"`
	Food          Food      `gorm:"foreignKey:FoodID" json:"food"`
	CreatedAt     time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}

type Food struct {
	ID                string    `gorm:"primaryKey;type:varchar(255)" json:"id"`
	Name              string    `gorm:"type:varchar(255);not null" json:"name"`
	ReferenceQuantity float64   `gorm:"not null;check:reference_quantity > 0" json:"referenceQuantity"`
	ReferenceUnit     string    `gorm:"type:varchar(50);not null" json:"referenceUnit"`
	Store             string    `gorm:"type:varchar(100)" json:"store"`
	Calories          float64   `gorm:"default:0;check:calories >= 0" json:"calories"`
	Carbs             float64   `gorm:"default:0;check:carbs >= 0" json:"carbs"`
	Proteins          float64   `gorm:"default:0;check:proteins >= 0" json:"proteins"`
	Fats              float64   `gorm:"default:0;check:fats >= 0" json:"fats"`
	IsFavorite        bool      `gorm:"default:false" json:"isFavorite"`
	CreatedAt         time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt         time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}
