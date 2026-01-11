package main

import (
	"go_api/controllers"
	"go_api/initializers"
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

func init() {
	initializers.LoadEnv()
	initializers.ConnectToDb()
}

func main() {
	if os.Getenv("ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.GET("/workouts", controllers.GetWorkouts)
	r.POST("/workout", controllers.CreateWorkout)
	r.PUT("/workout/:workout_id", controllers.UpdateWorkout)
	r.DELETE("/workout/:workout_id", controllers.DeleteWorkout)
	r.GET("/exercises", controllers.GetExercisesFromQuery)

	r.GET("/nutritionday/:date", controllers.GetNutritionDayByDate)
	r.GET("/foods", controllers.GetFoodsFromQuery)
	r.POST("/meals/:meal_id/food-portions", controllers.AddFoodPortion)
	r.DELETE("food-portions/:food_portion_id", controllers.DeleteFoodPortion)

	r.GET("/profil", controllers.GetProfil)
	r.POST("/profil", controllers.CreateProfil)
	r.PUT("/profil/:profil_id", controllers.UpdateProfil)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server starting on :%s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}

}
