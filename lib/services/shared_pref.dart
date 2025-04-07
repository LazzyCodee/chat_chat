import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyUsername = "username";
  static const String _keyPhotoUrl = "photoUrl";
  static const String _keyEmail = "email";
  static const String _keyUserId = "id";
  static const String _usernameUpper = "username";

  // Сохранение имени пользователя
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  Future<void> setUserNameUpper(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameUpper, username);
  }

  // Получение имени пользователя
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<String?> getUserNameUpper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameUpper);
  }

  // Сохранение URL фото
  Future<void> setPhotoUrl(String photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhotoUrl, photoUrl);
  }

  // Получение URL фото
  Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhotoUrl);
  }

  // Сохранение email
  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  Future<void> setUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, uid);
  }

  // Получение email
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> getuserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Удаление всех данных
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
