import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import '../models/credential.dart';

class StorageService {
  static const _keyName = 'encryption_key';
  static const _boxName = 'credentials_box';

  static final _secureStorage = FlutterSecureStorage();
  static late Box<Credential> credentialBox;

  static String? _currentUsername;

  static String get currentBoxName =>
      'credentials_box__${_currentUsername ?? ''}';
  static String get currentKeyName =>
      'encryption_key__${_currentUsername ?? ''}';

  static bool _adapterRegistered = false;

  static Future<void> init() async {
    developer.log('StorageService global init called', name: 'StorageService');
    await Hive.initFlutter();
    if (!_adapterRegistered) {
      Hive.registerAdapter(CredentialAdapter());
      _adapterRegistered = true;
    }
    final key = await _getEncryptionKey();
    developer.log('Global encryption key loaded', name: 'StorageService');
    credentialBox = await Hive.openBox<Credential>(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    developer.log('Global credentialBox opened', name: 'StorageService');
  }

  static Future<void> initForUser(String username) async {
    _currentUsername = username;
    developer.log(
      'StorageService initForUser called for username: $username',
      name: 'StorageService',
    );
    await Hive.initFlutter();
    if (!_adapterRegistered) {
      Hive.registerAdapter(CredentialAdapter());
      _adapterRegistered = true;
    }
    final key = await _getEncryptionKeyForUser(username);
    developer.log(
      'User encryption key loaded for $username',
      name: 'StorageService',
    );
    credentialBox = await Hive.openBox<Credential>(
      currentBoxName,
      encryptionCipher: HiveAesCipher(key),
    );
    developer.log(
      'User credentialBox opened for $username',
      name: 'StorageService',
    );
  }

  static Future<List<int>> _getEncryptionKey() async {
    developer.log('Getting global encryption key', name: 'StorageService');
    String? key = await _secureStorage.read(key: _keyName);

    if (key == null) {
      developer.log(
        'No global key found, generating new',
        name: 'StorageService',
      );
      final generatedKey = Hive.generateSecureKey();
      await _secureStorage.write(key: _keyName, value: generatedKey.join(','));
      return generatedKey;
    }

    developer.log('Global key found', name: 'StorageService');
    return key.split(',').map(int.parse).toList();
  }

  static Future<List<int>> _getEncryptionKeyForUser(String username) async {
    final userKeyName = currentKeyName;
    developer.log(
      'Getting encryption key for user: $username',
      name: 'StorageService',
    );
    String? key = await _secureStorage.read(key: userKeyName);
    if (key == null) {
      developer.log(
        'No key found for user $username, generating new',
        name: 'StorageService',
      );
      final generatedKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: userKeyName,
        value: generatedKey.join(','),
      );
      return generatedKey;
    }
    developer.log('Key found for user $username', name: 'StorageService');
    return key.split(',').map(int.parse).toList();
  }
}
