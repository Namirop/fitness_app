package entities

import (
	"time"
)

type Exercise struct {
	ID          string    `gorm:"primaryKey;type:varchar(255)" json:"id"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Description string    `gorm:"type:text" json:"description"`
	ImageUrl    string    `gorm:"type:varchar(500)" json:"imageUrl"`
	VideoUrl    string    `gorm:"type:varchar(500)" json:"videoUrl"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}

type Workout struct {
	ID        string            `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID    uint              `gorm:"index;not null"`
	Title     string            `gorm:"type:varchar(255);not null" json:"title"`
	Note      string            `gorm:"type:text" json:"note"`
	Date      time.Time         `gorm:"not null;index" json:"date"` // ‘index’ for queries by date
	Exercises []WorkoutExercise `gorm:"foreignKey:WorkoutID;constraint:OnDelete:CASCADE" json:"exercises"`
	CreatedAt time.Time         `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt time.Time         `gorm:"autoUpdateTime" json:"updatedAt"`
}

type WorkoutExercise struct {
	WorkoutID  string `gorm:"primaryKey;type:uuid;not null;index" json:"workoutId"`          // FK to Workout.ID → identifies the associated workout
	ExerciseID string `gorm:"primaryKey;type:varchar(255);not null;index" json:"exerciseId"` // FK to Exercise.ID → identifies the associated exercise

	Sets   int `gorm:"not null;check:sets > 0" json:"sets"`
	Reps   int `gorm:"not null;check:reps > 0" json:"reps"`
	Weight int `gorm:"default:0;check:weight >= 0" json:"weight"`

	Workout  Workout  `gorm:"foreignKey:WorkoutID;references:ID" json:"-"`         // Associates WorkoutExercise.WorkoutID with Workout.ID
	Exercise Exercise `gorm:"foreignKey:ExerciseID;references:ID" json:"exercise"` // Associates WorkoutExercise.ExerciseID with Exercise.ID

	CreatedAt time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}
