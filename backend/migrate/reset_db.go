package main

// dev_reset.go - ⚠️ DEV ONLY - Drops and recreates all tables

import (
	"go_api/initializers"
	entities "go_api/models/entities"
	"log"
)

func init() {
	initializers.LoadEnv()
	initializers.ConnectToDb()
}

func main() {
	log.Println("Début de la migration...")

	if err := initializers.DB.Migrator().DropTable(
		&entities.WorkoutExercise{},
		&entities.Workout{},
		&entities.Exercise{},

		&entities.FoodPortion{},
		&entities.Food{},
		&entities.Meal{},
		&entities.NutritionDay{},

		&entities.User{},
		&entities.Profil{},
	); err != nil {
		log.Fatal("Erreur lors de la suppression des tables:", err)
	}
	log.Println("Tables supprimées")

	if err := initializers.DB.AutoMigrate(
		&entities.Exercise{},
		&entities.Workout{},
		&entities.WorkoutExercise{},

		&entities.NutritionDay{},
		&entities.Meal{},
		&entities.Food{},
		&entities.FoodPortion{},

		&entities.User{},
		&entities.Profil{},
	); err != nil {
		log.Fatal("Erreur lors de la création des tables:", err)
	}
	log.Println("Tables recréées avec ON DELETE CASCADE")
}
