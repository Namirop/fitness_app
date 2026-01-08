package main

// SIMPLEMENT FAIRE UN 'go run migrate/migrate.go' POUR MIGRER LES NOUVELLES INFOS.

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

	// Supprime les tables (DANS LE BON ORDRE, enfants d'abord) => pour faire la migration proprement
	// Si plus tard on souhaite save les infos de la DB, voir Claude.
	// Dans le cas ou on ajouterai encore d'autres tables mais qu'on veut garder les tables de Workout et de NutritionDay, simplement les enlever du 'DropTable' et les laisser dans 'AutoMigrate' => juste commenter 'DropTable'
	if err := initializers.DB.Migrator().DropTable(
		&models.WorkoutExercise{},
		&models.Workout{},
		&models.Exercise{},
		// Tables nutrition (ordre important: enfants → parents)
		&models.FoodPortion{},
		&models.Food{},
		&models.Meal{},
		&models.NutritionDay{},
		//&models.Profil{},
	); err != nil {
		log.Fatal("❌ Erreur lors de la suppression des tables:", err)
	}
	log.Println("✅ Tables supprimées")

	// Toujours migrer toutes les tables lors d'une modif d'une struc (ajout de champs, etc.) pour ne pas éviter les problèmes.
	// De toute façon,'AutoMigrate' ne touche pas aux tables existantes si elles n'ont pas changé, il ajoute juste ce qui manque.
	if err := initializers.DB.AutoMigrate(
		&models.Exercise{},
		&models.Workout{},
		&models.WorkoutExercise{},
		// Tables nutrition (ordre important: parents → enfants)
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
