package controllers

import (
	"go_api/initializers"
	"go_api/models/entities"
	"go_api/utils"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GetProfil(c *gin.Context) {

	var profil entities.Profil
	if err := initializers.DB.First(&profil).Error; err != nil {
		log.Printf("Erreur récupération profil: %v", err)
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Profil introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de récupérer le profil"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profil envoyé avec succès",
		"profil":  profil,
	})
}

func CreateProfil(c *gin.Context) {
	profil := entities.Profil{
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
		log.Printf("Erreur création profil: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de créer le profil"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Profil crée et envoyé avec succès",
		"profil":  profil,
	})
}

func UpdateProfil(c *gin.Context) {
	profilID := c.Param("profil_id")

	if profilID == "" {
		log.Println("ID profil manquant dans l'URL")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Requête invalide"})
		return
	}

	var payload entities.Profil
	if err := c.ShouldBindJSON(&payload); err != nil {
		log.Printf("JSON invalide: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	if strings.TrimSpace(payload.Name) == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le nom est obligatoire",
		})
		return
	}

	if len(payload.Name) > 100 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le nom ne peut pas dépasser 100 caractères",
		})
		return
	}

	if payload.Age < 10 || payload.Age > 120 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "L'âge doit être entre 10 et 120",
		})
		return
	}

	if payload.Weight <= 0 || payload.Weight > 300 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Le poids doit être entre 1 et 300 kg",
		})
		return
	}

	if payload.Height < 100 || payload.Height > 250 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "La taille doit être entre 100 et 250 cm",
		})
		return
	}

	validGenders := []string{"Homme", "Femme", ""}
	if !utils.Contains(validGenders, payload.Gender) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Genre invalide (Homme, Femme ou vide)",
		})
		return
	}

	if payload.CaloriesTarget < 0 || payload.CaloriesTarget > 10000 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Calories invalides (0-10000)",
		})
		return
	}

	if payload.CarbsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Glucides doivent être >= 0",
		})
		return
	}

	if payload.ProteinsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Protéines doivent être >= 0",
		})
		return
	}

	if payload.FatsTarget < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Lipides doivent être >= 0",
		})
		return
	}

	var existing entities.Profil
	if err := initializers.DB.First(&existing, "id = ?", profilID).Error; err != nil {
		log.Printf("Erreur recherche profil ID=%s: %v", profilID, err)
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Profil introuvable"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la recherche du profil"})
		}
		return
	}

	payload.ID = profilID

	if err := initializers.DB.Model(&existing).Updates(&payload).Error; err != nil {
		log.Printf("Erreur update profil ID=%s: %v", profilID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de mettre à jour le profil"})
		return
	}

	var updatedProfil entities.Profil
	if err := initializers.DB.First(&updatedProfil, "id = ?", profilID).Error; err != nil {
		log.Printf("Erreur rechargement profil ID=%s: %v", profilID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de charger le profil mis à jour"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Profil modifié avec succès",
		"updatedProfil": updatedProfil,
	})
}
