import 'dart:async';
import 'dart:convert';

import 'package:workout_app/core/errors/api_exception.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:http/http.dart' as http;
import 'package:workout_app/data/models/profil/profil_model.dart';
import 'package:workout_app/data/services/auth_service.dart';

class ProfilRepository {
  final baseUrl = "http://10.0.2.2:3000/api";
  Future<ProfilModel> getProfil() async {
    try {
      final token = await AuthService.getToken();
      print("TOKEN RECUPERE: '$token'");
      final url = Uri.parse("$baseUrl/profil");
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profilJson = data['profil'];
        return ProfilModel.fromJson(profilJson);
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<ProfilModel> createProfil() async {
    try {
      final token = await AuthService.getToken();
      print("TOKEN RECUPERE: '$token'");
      final url = Uri.parse("$baseUrl/profil");
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final profilJson = data['profil'];
        return ProfilModel.fromJson(profilJson);
      }
      handleHttpError(response);
      throw StateError('Unreachable');
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre');
    }
  }

  Future<ProfilModel> updateProfil(ProfilEntity profil) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("$baseUrl/profil/${profil.id}");
      final jsonBody = ProfilModel.fromEntity(profil).toJson();
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

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final updatedProfilJson = data['updatedProfil'];
        return ProfilModel.fromJson(updatedProfilJson);
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
