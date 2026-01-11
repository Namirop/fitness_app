import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:workout_app/data/dto/add_food_portion_dto.dart';
import 'package:workout_app/data/models/nutrition/food_model.dart';
import 'package:workout_app/data/models/nutrition/nutrition_day_model.dart';

class NutritionRepository {
  final baseUrl = "http://10.0.2.2:3000";
  Future<NutritionDayModel?> getNutritionDay(String currentDate) async {
    try {
      final url = Uri.parse('$baseUrl/nutritionday/$currentDate');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nutritionDayJson = data["nutritionDay"];
        return NutritionDayModel.fromJson(nutritionDayJson);
      } else if (response.statusCode >= 500) {
        throw Exception("Le serveur est indisponible");
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw Exception("Pas de connexion internet");
    } catch (e) {
      throw Exception("Impossible de récupérer le nutritionDay : $e");
    }
  }

  Future<List<FoodModel>> getFoodList(String query) async {
    try {
      final url = Uri.parse('$baseUrl/foods?q=$query');
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List foodList = data['foodList'];
        return foodList.map((food) => FoodModel.fromJson(food)).toList();
      } else if (response.statusCode == 503) {
        throw Exception("API OpenFoodFacts indisponible, réessaye plus tard");
      } else if (response.statusCode >= 500) {
        throw Exception("Le serveur est indisponible");
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception('API met trop de temps à répondre');
    } on SocketException {
      throw Exception("Pas de connexion internet");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }

  Future<NutritionDayModel> addFoodPortion(
    AddFoodPortionDto addFoodPortionDto,
  ) async {
    try {
      final url = Uri.parse(
        "$baseUrl/meals/${addFoodPortionDto.mealId}/food-portions",
      );
      final jsonBody = addFoodPortionDto.toJson();
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NutritionDayModel.fromJson(data['nutritionDay']);
      } else if (response.statusCode >= 500) {
        throw Exception("Le serveur est indisponible");
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw Exception("Pas de connexion internet");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }

  Future<NutritionDayModel> deleteFoodPortion(String foodPortionId) async {
    try {
      final url = Uri.parse("$baseUrl/food-portions/$foodPortionId");
      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NutritionDayModel.fromJson(data['nutritionDay']);
      } else if (response.statusCode >= 500) {
        throw Exception("Le serveur est indisponible");
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw Exception("Pas de connexion internet");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }
}
