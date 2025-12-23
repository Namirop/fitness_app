// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/models/workout/exercise_model.dart';
import 'package:workout_app/data/models/workout/exercise_preview_model.dart';
import 'package:workout_app/data/models/workout/workout_model.dart';

class WorkoutRepository {
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/workouts');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        // Ici, response.body → String JSON
        // jsonDecode(response.body) → List<Map<String, dynamic>> => chaque élément est une "Map", càd une clé-valeur
        final data = jsonDecode(response.body);
        final List workoutJson = data['workouts'];
        print("Serveur : ${data['message']}");
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
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      // Ici on laisse le print pour le dev, mais en prod retirer car inutile
      print("Erreur lors de la récupération de tous les workouts : $e");
      // throw Exception est propagée )
      throw Exception(
        "Erreur lors de la récupération de tous les workouts : $e",
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
      final url = Uri.parse("http://10.0.2.2:3000/workout");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .post(url, body: jsonEncode(jsonBody))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        return;
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de la création du workout ${workout.title} : $e");
      throw Exception(
        "Erreur lors de la création du workout ${workout.title} : $e",
      );
    }
  }

  Future<void> updateWorkout(WorkoutEntity workout) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/workout/${workout.id}");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .put(url, body: jsonEncode(jsonBody))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // retourner plus tard le workout modifié (standard)
        print("Serveur : ${data['message']}");
        return;
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de la modification du workout ${workout.title} : $e");
      throw Exception(
        "Erreur lors de la modification du workout ${workout.title} : $e",
      );
    }
  }

  // Ici on va pas s'embeter à renvoyer le workout delete, car c'est suffisant et on ne le "transforme" pas en soit coté serveur
  Future<void> deleteWorkout(String id) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/workout/$id");
      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        return;
      }
      throw Exception('Erreur serveur : ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Impossible de supprimer le workout : $e");
      throw Exception("Impossible de supprimer le workout : $e");
    }
  }

  Future<void> deleteAllWorkouts() async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/workouts");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        return;
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur lors de la suppresion des workouts de la semaine : $e");
    }
  }

  Future<List<ExercisePreviewModel>> fetchExercisesFromQuery(
    String query,
  ) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/exercises?q=$query');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List exercisesJson = data['exercises'];
        return exercisesJson
            .map((ex) => ExercisePreviewModel.fromJson(ex))
            .toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print('Erreur lors du fetch des exercices : $e');
      throw Exception('Erreur lors du fetch des exercices : $e');
    }
  }

  Future<ExerciseModel> fetchExerciseById(String exerciseId) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/exercise/$exerciseId");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Serveur : ${data['message']}");
        final exercicesJson = data['exercise_details'];
        return ExerciseModel.fromJson(exercicesJson);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      print("Erreur lors de la récupération : $e");
      throw Exception("Erreur lors de la récupération : $e");
    }
  }
}
