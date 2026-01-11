package entities

import (
	"time"

	"gorm.io/gorm"
)

type Profil struct {
	ID             string         `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	Name           string         `gorm:"type:varchar(100);not null" json:"name"`
	Gender         string         `gorm:"type:varchar(10);not null" json:"gender"`
	Age            int            `gorm:"not null;check:age >= 10 AND age <= 120" json:"age"`
	Weight         float32        `gorm:"not null;check:weight >= 30 AND weight <= 200" json:"weight"`
	Height         int            `gorm:"not null;check:height >= 100 AND height <= 220" json:"height"`
	CaloriesTarget float64        `gorm:"not null;check:calories_target >= 0" json:"caloriesTarget"`
	CarbsTarget    float64        `gorm:"not null;check:carbs_target >= 0" json:"carbsTarget"` // CarbsTarget → carbs_target
	ProteinsTarget float64        `gorm:"not null;check:proteins_target >= 0" json:"proteinsTarget"`
	FatsTarget     float64        `gorm:"not null;check:fats_target >= 0" json:"fatsTarget"`
	ActivityLevel  string         `gorm:"type:varchar(50)" json:"activityLevel"`
	Goal           string         `gorm:"type:varchar(50)" json:"goal"`
	CreatedAt      time.Time      `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt      time.Time      `gorm:"autoUpdateTime" json:"updatedAt"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}
