import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _usernameKey = 'username';
  static String _userPasswordKey(String username) =>
      'user_${username}_password';
  static final _secureStorage = FlutterSecureStorage();

  /// Save username and master password (used during signup)
  static Future<void> saveCredentials(String username, String password) async {
    developer.log(
      'Saving credentials for username: "$username"',
      name: 'AuthService',
    );
    await _secureStorage.write(
      key: _userPasswordKey(username),
      value: password,
    );
    developer.log(
      'Credentials saved for username: "$username"',
      name: 'AuthService',
    );
  }

  /// Login: checks if the entered username and password match the stored ones
  static Future<void> login(String username, String password) async {
    developer.log(
      'Attempting login for username: "$username"',
      name: 'AuthService',
    );
    final storedPassword = await _secureStorage.read(
      key: _userPasswordKey(username),
    );
    developer.log(
      'Stored password for username "$username": ${storedPassword ?? 'null'}',
      name: 'AuthService',
    );
    if (storedPassword == null || storedPassword != password) {
      developer.log(
        'Login failed for username: "$username"',
        name: 'AuthService',
      );
      throw Exception('Invalid username or password');
    }
    // Set the current username after successful login
    await _secureStorage.write(key: _usernameKey, value: username);
    developer.log(
      'Login successful for username: "$username"',
      name: 'AuthService',
    );
  }

  /// Optional: check if credentials exist (for onboarding)
  static Future<bool> hasCredentials([String? username]) async {
    developer.log(
      'Checking if credentials exist for username: ${username ?? 'null'}',
      name: 'AuthService',
    );
    if (username == null) {
      final storedUsername = await _secureStorage.read(key: _usernameKey);
      return storedUsername != null;
    }
    final storedPassword = await _secureStorage.read(
      key: _userPasswordKey(username),
    );
    return storedPassword != null;
  }

  /// Optional: logout (clear credentials)
  static Future<void> logout([String? username]) async {
    developer.log(
      'Logout called for username: ${username ?? 'null'}',
      name: 'AuthService',
    );
    if (username != null) {
      await _secureStorage.delete(key: _userPasswordKey(username));
    }
    await _secureStorage.delete(key: _usernameKey);
    developer.log('Logout complete', name: 'AuthService');
  }

  /// Get the currently logged-in username
  static Future<String?> getCurrentUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  /// Get the password for a given username (for internal use)
  static Future<String?> getPasswordForUsername(String username) async {
    final key = 'user_\u001f\u001f${username}_password';
    return await _secureStorage.read(key: key);
  }
}
