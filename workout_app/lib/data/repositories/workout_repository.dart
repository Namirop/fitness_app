import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/models/workout/exercise_model.dart';
import 'package:workout_app/data/models/workout/workout_model.dart';

class WorkoutRepository {
  final baseUrl = "http://10.0.2.2:3000";
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final url = Uri.parse('$baseUrl/workouts');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List workoutsJson = data['existingWorkouts'];
        return workoutsJson
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception(
        "Erreur lors de la récupération de tous les workouts : $e",
      );
    }
  }

  Future<WorkoutModel> createWorkout(WorkoutEntity workout) async {
    try {
      final url = Uri.parse("$baseUrl/workout");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdWorkoutJson = data['createdWorkout'];
        return WorkoutModel.fromJson(createdWorkoutJson);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception(
        "Erreur lors de la création du workout ${workout.title} : $e",
      );
    }
  }

  Future<WorkoutModel> updateWorkout(WorkoutEntity workout) async {
    try {
      final url = Uri.parse("$baseUrl/workout/${workout.id}");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedWorkoutJson = data['updatedWorkout'];
        return WorkoutModel.fromJson(updatedWorkoutJson);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception(
        "Erreur lors de la modification du workout ${workout.title} : $e",
      );
    }
  }

  Future<List<WorkoutModel>> deleteWorkout(String id) async {
    try {
      final url = Uri.parse("$baseUrl/workout/$id");
      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List updatedWorkoutsJson = data['updatedWorkouts'];
        return updatedWorkoutsJson
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
      }
      throw Exception('Erreur serveur : ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception("Impossible de supprimer le workout : $e");
    }
  }

  Future<List<ExerciseModel>> fetchExercisesFromQuery(String query) async {
    try {
      final url = Uri.parse('$baseUrl/exercises?q=$query');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List exercisesJson = data['exercises'];
        return exercisesJson.map((ex) => ExerciseModel.fromJson(ex)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception('Erreur lors du fetch des exercices : $e');
    }
  }
}
