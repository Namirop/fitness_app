import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workout_app/data/entities/nutrition/nutrition_day_entity.dart';
import 'package:workout_app/data/models/nutrition/food_model.dart';
import 'package:workout_app/data/models/nutrition/nutrition_day_model.dart';

class NutritionRepository {
  Future<NutritionDayModel?> getNutritionDay(String currentDate) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/nutritionday/${currentDate}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        if (data['nutritionDay'] == null) {
          return null;
        }
        final nutritionDayJson = data["nutritionDay"];
        return NutritionDayModel.fromJson(nutritionDayJson);
      } else {
        throw Exception(
          'Erreur serveur : ${response.statusCode} + ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Impossible de récupérer le nutritionDay : $e");
      throw Exception("Impossible de récupérer le nutritionDay : $e");
    }
  }

  Future<List<FoodModel>> getFoodList(String query) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/foods?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        final List foodList = data['foodList'];
        return foodList.map((food) => FoodModel.fromJson(food)).toList();
      } else {
        throw Exception(
          'Erreur serveur : ${response.statusCode} + ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('API met trop de temps à répondre');
    } catch (e) {
      print(
        "Impossible de récupérer la liste de nourriture sur base de la query : $e",
      );
      throw Exception(
        "Impossible de récupérer la liste de nourriture sur base de la query : $e",
      );
    }
  }

  Future<NutritionDayModel> saveNutritionDay(NutritionDayEntity nutritionDay) {
    if (nutritionDay.id.isEmpty) {
      return createNutritionDay(nutritionDay);
    } else {
      return updateNutritionDay(nutritionDay);
    }
  }

  Future<NutritionDayModel> createNutritionDay(
    NutritionDayEntity nutritionDay,
  ) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/nutritionDay");
      final jsonBody = NutritionDayModel.fromEntity(nutritionDay).toJson();
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        return NutritionDayModel.fromJson(data['nutritionDay']);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de l'ajout du meal au nutrition day");
      throw Exception("Erreur lors de l'ajout du meal au nutrition day");
    }
  }

  Future<NutritionDayModel> updateNutritionDay(
    NutritionDayEntity nutritionDay,
  ) async {
    try {
      final url = Uri.parse(
        "http://10.0.2.2:3000/nutritionDay/${nutritionDay.id}",
      );
      final jsonBody = NutritionDayModel.fromEntity(nutritionDay).toJson();
      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        return NutritionDayModel.fromJson(data['nutritionDay']);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de l'ajout du meal au nutrition day");
      throw Exception("Erreur lors de l'ajout du meal au nutrition day");
    }
  }
}
