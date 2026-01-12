import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:workout_app/core/errors/api_exception.dart';
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
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw ApiException("Pas de connexion internet");
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
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('API met trop de temps à répondre');
    } on SocketException {
      throw ApiException("Pas de connexion internet");
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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return NutritionDayModel.fromJson(data['nutritionDay']);
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw ApiException("Pas de connexion internet");
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
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    } on SocketException {
      throw ApiException("Pas de connexion internet");
    }
  }

  void handleHttpError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        throw ApiException(body['error'], statusCode: response.statusCode);
      }
    } catch (_) {}

    throw ApiException(
      'Erreur serveur (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
