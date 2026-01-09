package main

import (
	"fmt"
	"go_api/controllers"
	"go_api/initializers"

	"github.com/gin-gonic/gin"
)

func init() {
	initializers.LoadEnv()
	initializers.ConnectToDb()
}

func main() {

	r := gin.Default()

	// Log middleware (even if the route does not exist)
	r.Use(func(c *gin.Context) {
		fmt.Println("Request received:", c.Request.Method, c.Request.URL.Path)
		c.Next()
	})

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	r.GET("/workouts", controllers.GetWorkouts)
	r.POST("/workout", controllers.CreateWorkout)
	r.PUT("/workout/:id", controllers.UpdateWorkout)
	r.DELETE("/workout/:id", controllers.DeleteWorkout)
	r.GET("/exercises", controllers.GetExercisesFromQuery)

	r.GET("/nutritionday/:date", controllers.GetNutritionDayByDate)
	r.GET("/foods", controllers.GetFoodsFromQuery)
	r.PUT("nutritionDay/:id", controllers.UpdateNutritionDay)

	r.GET("/profil", controllers.GetProfil)
	r.POST("/profil", controllers.CreateProfil)
	r.PUT("/profil/:id", controllers.UpdateProfil)

	r.Run("0.0.0.0:3000")
}
