import 'dart:async';
import 'dart:convert';

import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:http/http.dart' as http;
import 'package:workout_app/data/models/profil/profil_model.dart';

class ProfilRepository {
  final baseUrl = "http://10.0.2.2:3000";
  Future<ProfilModel> getProfil() async {
    try {
      final url = Uri.parse("$baseUrl/profil");
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profilJson = data['profil'];
        return ProfilModel.fromJson(profilJson);
      } else {
        throw Exception('Erreur serveur : - ${response.statusCode} ');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception("Erreur lors de la récupération du profil : $e");
    }
  }

  Future<ProfilModel> createProfil() async {
    try {
      final url = Uri.parse("$baseUrl/profil");
      final response = await http
          .post(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final profilJson = data['profil'];
        return ProfilModel.fromJson(profilJson);
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception("Erreur lors de la création du profil : $e");
    }
  }

  Future<ProfilModel> updateProfil(ProfilEntity profil) async {
    try {
      final url = Uri.parse("$baseUrl/profil/${profil.id}");
      final jsonBody = ProfilModel.fromEntity(profil).toJson();
      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final updatedProfilJson = data['updatedProfil'];
        return ProfilModel.fromJson(updatedProfilJson);
      } else {
        final errorMessage = data['error'] ?? 'Erreur inconnue';
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre');
    } catch (e) {
      throw Exception("Erreur lors de la modification du profil : $e");
    }
  }
}
