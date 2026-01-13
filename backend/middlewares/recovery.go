package middlewares

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func Recovery() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if r := recover(); r != nil {
				log.Printf("[PANIC RECOVERED] %v", r)

				c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
					"error": "Une erreur interne est survenue",
				})
			}

		}()

		c.Next()
	}
}
