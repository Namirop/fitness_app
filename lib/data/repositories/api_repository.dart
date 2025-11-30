// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workout_app/data/entities/exercice_entity.dart';
import 'package:workout_app/data/entities/exercice_preview_entity.dart';
import 'package:workout_app/data/entities/workout_entity.dart';
import 'package:workout_app/data/models/workout_model.dart';

class ApiRepository {
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/workouts');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        // Ici, response.body → String JSON
        // jsonDecode(response.body) → List<Map<String, dynamic>> => chaque élément est une "Map", càd une clé-valeur
        final data = jsonDecode(response.body);
        final List workoutJson = data['workouts'];
        print(data['message']);
        // On transforme chaque élément JSON en WorkoutModel
        // ".map()" est une fonction qui transforme chaque élément de la liste en autre chose
        // "json" represente un élément de "workoutJson", donc un "Map<String, dynamic>"
        // pour chaque élément "json", on crée un objet "WorkoutModel" via "fromJson"
        // Cela donne une liste de WorkoutModel mais en Itarable (".map()" retourne un Iterable), il faut donc convertir en List (via ".toList()") utilisable dans l'UI.
        // => A la fin, on obient 'List<WorkoutModel>'.
        // EN GROS QUAND ON VEUT TRANSFORMER QQCH => MAP - POUR CHAQUE ELEMENT, ON APPELLERA UNE FONCTION.
        return workoutJson
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération de tout les workouts');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      // Ici on laisse le print pour le dev, mais en prod retirer car inutile
      // throw Exception est propagée au BLoC
      print("Erreur lors de la récupération de tout les workouts : $e");
      throw Exception(
        "Erreur lors de la récupération de tout les workouts : $e",
      );
    }
  }

  // PLUS TARD, PENSER A AJOUTER UNE VERIFICATION QUE LE WORKOUT CONTIENT UN TITRE ET DES EXO MAIS COTES API
  // POURQUOI ? => POUR LA SECURITE, FAIRE CA JUSTE COTE CLIENT N'EST PAS SUFFISANT ET UN ATTAQUANT PEUT LE CONTOURNER SI C'EST PAS GERER COTE API
  // Règle d'or :
  // Le client valide pour l'UX
  // L'API valide pour la sécurité.
  // => TOUJOURS valider côté serveur, même si le client valide
  Future<void> addWorkout(WorkoutEntity workout) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/createworkout");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .post(
            url,
            headers: {"Content-type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data['message']);
        return;
      } else {
        throw Exception("Problème de création du workout");
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de la création : $e");
      throw Exception("Erreur lors de la création : $e");
    }
  }

  Future<void> deleteAllWorkouts() async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/workouts");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['message']);
        return;
      } else {
        throw Exception('Erreur lors de la suppression de tous les workouts');
      }
    } catch (e) {
      print("Erreur lors de la suppresion : $e");
      throw Exception("Erreur lors de la suppresion : $e");
    }
  }

  Future<List<ExercisePreviewEntity>> fetchExercisesFromQuery(
    String query,
  ) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/exercices/$query');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List exercisesJson = data['exercises'];
        return exercisesJson
            .map(
              (ex) => ExercisePreviewEntity(
                exerciseId: ex['exerciseId'],
                name: ex['name'],
                imageUrl: ex['imageUrl'],
              ),
            )
            .toList();
      } else {
        throw Exception("Erreur lors du fetch des exercices");
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print('Erreur lors du fetch des exercices : $e');
      throw Exception('Erreur lors du fetch des exercices : $e');
    }
  }

  Future<ExerciceEntity> fetchExerciseById(String exerciseId) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/exercices/id/$exerciseId");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['message']);
        final exercicesJson = data['exercise_details'];
        return ExerciceEntity(
          id: exercicesJson['exerciseId'],
          name: exercicesJson['name'],
          description: exercicesJson['overview'],
          imageUrl: exercicesJson['imageUrl'],
        );
      } else {
        throw Exception(
          "Erreur lors de la récupération des détails de l'exercice",
        );
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de la récupération : $e");
      throw Exception("Erreur lors de la récupération : $e");
    }
  }
}
