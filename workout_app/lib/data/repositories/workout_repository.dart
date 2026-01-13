import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workout_app/core/errors/api_exception.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/models/workout/exercise_model.dart';
import 'package:workout_app/data/models/workout/workout_model.dart';
import 'package:workout_app/data/services/auth_service.dart';

class WorkoutRepository {
  final baseUrl = "http://10.0.2.2:3000/api";
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$baseUrl/workouts');
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List workoutsJson = data['workouts'];
        return workoutsJson
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
      }
      handleHttpError(response);
      // otherwise Dart is not happy
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<WorkoutModel> createWorkout(WorkoutEntity workout) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("$baseUrl/workout");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdWorkoutJson = data['workout'];
        return WorkoutModel.fromJson(createdWorkoutJson);
      }
      handleHttpError(response);
      throw UnimplementedError();
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<WorkoutModel> updateWorkout(WorkoutEntity workout) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("$baseUrl/workout/${workout.id}");
      final jsonBody = WorkoutModel.fromEntity(workout).toJson();
      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedWorkoutJson = data['workout'];
        return WorkoutModel.fromJson(updatedWorkoutJson);
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<List<WorkoutModel>> deleteWorkout(String workoutId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("$baseUrl/workout/$workoutId");
      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List updatedWorkoutsJson = data['workouts'];
        return updatedWorkoutsJson
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<List<ExerciseModel>> fetchExercisesFromQuery(String query) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$baseUrl/exercises?q=$query');
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List exercisesJson = data['exercises'];
        return exercisesJson.map((ex) => ExerciseModel.fromJson(ex)).toList();
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
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
