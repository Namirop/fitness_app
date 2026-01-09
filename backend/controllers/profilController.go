package controllers

import (
	"go_api/initializers"
	"go_api/models"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GetProfil(c *gin.Context) {

	var profil models.Profil
	if err := initializers.DB.First(&profil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Pas de profil existant " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profil envoyé avec succès",
		"profil":  profil,
	})
}

func CreateProfil(c *gin.Context) {
	profil := models.Profil{
		Name:           "Utilisateur",
		Gender:         "Homme",
		Age:            25,
		Weight:         70,
		Height:         175,
		CaloriesTarget: 2000,
		CarbsTarget:    250,
		ProteinsTarget: 150,
		FatsTarget:     67,
		ActivityLevel:  "",
		Goal:           "",
	}

	if err := initializers.DB.Create(&profil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Erreur lors de la création du profil: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Profil crée et envoyé avec succès",
		"profil":  profil,
	})
}

func UpdateProfil(c *gin.Context) {
	profilID := c.Param("id")

	if profilID == "" {
		log.Println("ID manquant")
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID manquant"})
		return
	}

	var profil models.Profil
	if err := c.ShouldBindJSON(&profil); err != nil {
		log.Println("JSON invalide", err)

		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON invalide"})
		return
	}

	if strings.TrimSpace(profil.Name) == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le nom est obligatoire",
		})
		return
	}

	if len(profil.Name) > 100 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le nom ne peut pas dépasser 100 caractères",
		})
		return
	}

	if profil.Age < 10 || profil.Age > 120 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "L'âge doit être entre 10 et 120",
		})
		return
	}

	if profil.Weight <= 0 || profil.Weight > 300 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le poids doit être entre 1 et 300 kg",
		})
		return
	}

	if profil.Height < 100 || profil.Height > 250 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "La taille doit être entre 100 et 250 cm",
		})
		return
	}

	validGenders := []string{"Homme", "Femme", ""}
	if !contains(validGenders, profil.Gender) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Genre invalide (Homme, Femme ou vide)",
		})
		return
	}

	if profil.CaloriesTarget < 0 || profil.CaloriesTarget > 10000 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Calories invalides (0-10000)",
		})
		return
	}

	if profil.CarbsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Glucides doivent être >= 0",
		})
		return
	}

	if profil.ProteinsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Protéines doivent être >= 0",
		})
		return
	}

	if profil.FatsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Lipides doivent être >= 0",
		})
		return
	}

	var existing models.Profil
	if err := initializers.DB.First(&existing, "id = ?", profilID).Error; err != nil {
		log.Println("Profil introuvable", err)
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Profil introuvable",
			})
		} else {
			log.Println("Erreur base de données : ", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Erreur base de données : " + err.Error(),
			})
		}
		return
	}

	profil.ID = profilID

	if err := initializers.DB.Model(&existing).Updates(&profil).Error; err != nil {
		log.Println("Erreur lors de la mise à jour du profil : ", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Erreur lors de la mise à jour du profil : " + err.Error(),
		})
		return
	}

	var updatedProfil models.Profil
	if err := initializers.DB.First(&updatedProfil, "id = ?", profilID).Error; err != nil {
		log.Println("Erreur lors de la récupération du profil après modification:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Erreur lors de la récupération du profil après modification: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Profil modifié avec succès",
		"updatedProfil": updatedProfil,
	})
}

// Helper for enum validation
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}
