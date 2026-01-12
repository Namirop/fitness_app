package services

import (
	"errors"
	"go_api/initializers"
	"go_api/models/entities"
	"go_api/utils"
)

func Register(email, password string) (*entities.User, error) {
	hashed, err := utils.HashPassword(password)
	if err != nil {
		return nil, err
	}

	user := entities.User{
		Email:    email,
		Password: hashed,
	}

	if err := initializers.DB.Create(&user).Error; err != nil {
		return nil, err
	}

	return &user, nil
}

func Login(email, password string) (string, error) {
	var user entities.User

	if err := initializers.DB.Where("email = ?", email).First(&user).Error; err != nil {
		return "", errors.New("identifiants invalides")
	}

	if !utils.CheckPassword(password, user.Password) {
		return "", errors.New("identifiants invalides")
	}

	return utils.GenerateJWT(user.ID)
}
