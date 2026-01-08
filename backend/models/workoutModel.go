package models

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
	Title     string            `gorm:"type:varchar(255);not null" json:"title"`
	Note      string            `gorm:"type:text" json:"note"`
	Date      time.Time         `gorm:"not null;index" json:"date"` // 'index' pour queries par date
	Exercises []WorkoutExercise `gorm:"foreignKey:WorkoutID;constraint:OnDelete:CASCADE" json:"exercises"`
	CreatedAt time.Time         `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt time.Time         `gorm:"autoUpdateTime" json:"updatedAt"`
}

// Table pivot : GORM la gère automatiquement si on met "many2many", mais vu qu'on a des champs en plus (reps, sets et weight) il faut la créer explicitement.
type WorkoutExercise struct {

	// Les 2 colonnes suivantes composent une clé primaire composite (chaque paire WorkoutID + ExerciseID est unique)
	WorkoutID  string `gorm:"primaryKey;type:uuid;not null;index" json:"workoutId"`          // FK vers Workout.ID → identifie le workout associé
	ExerciseID string `gorm:"primaryKey;type:varchar(255);not null;index" json:"exerciseId"` // FK vers Exercise.ID → identifie l’exercice associé

	// Données spécifiques à l'association Workout-Exercise
	// Sets/Reps/Weight ne sont pas des propriétés globales de l’exercice, ce sont des param spé à une séance donnée => donc pas à mettre dans la struct "Exercise".
	Sets   int `gorm:"not null;check:sets > 0" json:"sets"`
	Reps   int `gorm:"not null;check:reps > 0" json:"reps"`
	Weight int `gorm:"default:0;check:weight >= 0" json:"weight"`

	// Workout contient l'objet Workout complet associé à cette relation
	// Elles permettent de récupérer directement les infos du Workout et de l’Exercice liés, GORM comprend les relations et peut les précharger avec Preload().
	// Ces champs sont utiles pour charger directement leurs détails sans faire de jointure manuelle.
	// Ces champs n'est pas enregistré dans la base de données : il sert uniquement à naviguer côté Go.
	Workout  Workout  `gorm:"foreignKey:WorkoutID;references:ID" json:"-"`         // Associe WorkoutExercise.WorkoutID à Workout.ID
	Exercise Exercise `gorm:"foreignKey:ExerciseID;references:ID" json:"exercise"` // Associe WorkoutExercise.ExerciseID à Exercise.ID

	CreatedAt time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}
