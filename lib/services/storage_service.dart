import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/credential.dart';

class StorageService {
  static const _keyName = 'encryption_key';
  static const _boxName = 'credentials_box';

  static final _secureStorage = FlutterSecureStorage();
  static late Box<Credential> credentialBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CredentialAdapter());

    final key = await _getEncryptionKey();
    credentialBox = await Hive.openBox<Credential>(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }

  static Future<List<int>> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _keyName);

    if (key == null) {
      final generatedKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: generatedKey.join(','),
      );
      return generatedKey;
    }

    return key.split(',').map(int.parse).toList();
  }
}
