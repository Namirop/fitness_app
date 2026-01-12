package main

import (
	"go_api/controllers"
	"go_api/initializers"
	"go_api/middlewares"
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

	auth := r.Group("/auth")
	{
		auth.POST("/register", controllers.Register)
		auth.POST("/login", controllers.Login)
	}

	api := r.Group("/api")
	api.Use(middlewares.AuthRequired())
	{
		api.GET("/workouts", controllers.GetWorkouts)
		api.POST("/workout", controllers.CreateWorkout)
		api.PUT("/workout/:workout_id", controllers.UpdateWorkout)
		api.DELETE("/workout/:workout_id", controllers.DeleteWorkout)

		api.GET("/exercises", controllers.GetExercisesFromQuery)

		api.GET("/nutritionday/:date", controllers.GetNutritionDayByDate)
		api.GET("/foods", controllers.GetFoodsFromQuery)
		api.POST("/meals/:meal_id/food-portions", controllers.AddFoodPortion)
		api.DELETE("food-portions/:food_portion_id", controllers.DeleteFoodPortion)

		api.GET("/profil", controllers.GetProfil)
		api.POST("/profil", controllers.CreateProfil)
		api.PUT("/profil/:profil_id", controllers.UpdateProfil)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server starting on :%s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}

}
