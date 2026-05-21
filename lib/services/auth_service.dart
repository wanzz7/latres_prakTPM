import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoggedUsername = 'logged_username';

  /// Simpan akun baru (register)
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Cek apakah username sudah ada
    final existingUser = prefs.getString(_keyUsername);
    if (existingUser == username) {
      return false; // username sudah terdaftar
    }

    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
    return true;
  }

  /// Login dengan username dan password
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final savedUsername = prefs.getString(_keyUsername);
    final savedPassword = prefs.getString(_keyPassword);

    if (savedUsername == username && savedPassword == password) {
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyLoggedUsername, username);
      return true;
    }
    return false;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyLoggedUsername);
  }

  /// Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Ambil username yang sedang login
  static Future<String> getLoggedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedUsername) ?? '';
  }
}
