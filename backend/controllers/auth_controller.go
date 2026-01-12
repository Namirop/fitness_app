package controllers

import (
	"go_api/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthPayload struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func Register(c *gin.Context) {
	var payload AuthPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Payload invalide"})
		return
	}

	user, err := services.Register(payload.Email, payload.Password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"user_id": user.ID})
}

func Login(c *gin.Context) {
	var payload AuthPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Payload invalide"})
		return
	}

	token, err := services.Login(payload.Email, payload.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
