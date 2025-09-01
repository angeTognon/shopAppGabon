import 'dart:convert';
import 'package:gabon_client_app/const.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<User> fetchUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/get_clientt.php?id=$id'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final user = User.fromJson(data['user']);
      await saveUser(user); // Mets à jour le local aussi
      return user;
    } else {
      throw Exception(data['error'] ?? 'Erreur lors de la récupération');
    }
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool('has_seen_onboarding', false);
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login_clients.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final user = User.fromJson(data['user']);
      await saveUser(user);
      return user;
    } else {
      throw Exception(data['error'] ?? 'Erreur de connexion');
    }
  }

  static Future<User> register(Map<String, String> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register_clients.php'),
      body: userData,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Après inscription, tu peux faire un login automatique ou demander à l'utilisateur de se connecter
      return await login(userData['email']!, userData['password']!);
    } else {
      throw Exception(data['error'] ?? 'Erreur d\'inscription');
    }
  }

  /// Rafraîchit les infos du user depuis l'API et met à jour le local
  static Future<User?> refreshCurrentUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      return await fetchUserById(currentUser.id);
    }
    return null;
  }

  /// Met à jour les points du user localement (ne touche pas à l'API)
  static Future<void> updateUserPoints(User user, int pointsToAdd) async {
    final updatedUser = user.copyWith(points: user.points + pointsToAdd);
    await saveUser(updatedUser);
  }
}