package main

import (
	"go_api/initializers"
	"go_api/models"
	"log"
)

func init() {
	initializers.LoadEnv()
	initializers.ConnectToDb()
}

func main() {
	log.Println("🔄 Début de la migration...")

	if err := initializers.DB.Migrator().DropTable(
		&models.WorkoutExercise{},
		&models.Workout{},
		&models.Exercise{},
		&models.FoodPortion{},
		&models.Food{},
		&models.Meal{},
		&models.NutritionDay{},
		//&models.Profil{},
	); err != nil {
		log.Fatal("❌ Erreur lors de la suppression des tables:", err)
	}
	log.Println("✅ Tables supprimées")

	if err := initializers.DB.AutoMigrate(
		&models.Exercise{},
		&models.Workout{},
		&models.WorkoutExercise{},

		&models.NutritionDay{},
		&models.Meal{},
		&models.Food{},
		&models.FoodPortion{},

		&models.Profil{},
	); err != nil {
		log.Fatal("❌ Erreur lors de la création des tables:", err)
	}
	log.Println("✅ Tables recréées avec ON DELETE CASCADE")
}
