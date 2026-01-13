import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = "http://10.0.2.2:3000";
  static Future<String?> autoLogin() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token != null) {
      return token;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': 'dev@test.com', 'password': 'dev123'}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return token;
      }
    } catch (e) {
      print("Erreur auto-login : $e");
    }
    return null;
  }

  // Récupérer le token stocké
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Déconnexion (pour plus tard)
  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
